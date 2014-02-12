htmlparser = require 'htmlparser2'
cheerio = require 'cheerio'
Element = require './element'
Attribute = require './attribute'

module.exports = class Soup

  constructor: (_string) ->
    @_string = _string.toString()

  _build: ->
    # This constructor builds the _$ref document and the _elements hash, which together allow finding elements in the markup string by CSS selector.

    @_splicings = []
    @_lookupAttrName = "data-souplookup-#{Date.now()}"
    refString = ''
    lastIndex = 0
    tagId = 0
    @_elements = {}
    tagStack = []

    parser = new htmlparser.Parser
      onopentag: (tagName, attributes) =>
        tagId++
        tagStack.push
          start: parser.startIndex
          end: parser._tokenizer._index + 1
          id: tagId

        if parser.endIndex <= parser.startIndex
          openingTag = @_string.substring(
            parser.startIndex,
            parser._tokenizer._index
          )
        else
          openingTag = @_string.substring(
            parser.startIndex,
            parser.endIndex + 1
          )

        modifiedOpeningTag = do =>
          endOfTagNameIndex = openingTag.indexOf ' '
          if endOfTagNameIndex == -1
            endOfTagNameIndex = openingTag.indexOf '/'
          if endOfTagNameIndex == -1
            endOfTagNameIndex = openingTag.indexOf '>'
          if endOfTagNameIndex == -1
            # console.log "\n\n__#{openingTag}__"
            # console.log parser
            throw new Error 'Should not happen :)'
          openingTag = (
            openingTag.substring(0, endOfTagNameIndex) +
            " #{@_lookupAttrName}='#{tagId}'" +
            openingTag.substring(endOfTagNameIndex)
          )
        refString += (
          @_string.substring(lastIndex, parser.startIndex) +
          modifiedOpeningTag
        )
        lastIndex = parser.endIndex + 1

      onclosetag: (tagName) =>
        correspondingOpeningTag = tagStack.pop()

        # Hack to fix problem where parser is at index=1 if the very first character was the beginning of an element
        if correspondingOpeningTag.start == 1 && @_string.charAt(1) != '<'
          correspondingOpeningTag.start = 0

        selfClosingTag = (parser.startIndex == correspondingOpeningTag.start)

        @_elements[correspondingOpeningTag.id] =
          start: correspondingOpeningTag.start
          contentStart: correspondingOpeningTag.end
          contentEnd: (
            if selfClosingTag
              correspondingOpeningTag.end
            else parser.startIndex
          )
          end: parser.endIndex + 1

      onend: =>
        refString += @_string.substring lastIndex

    parser.write @_string
    parser.end()

    @_$ref = cheerio.load refString

  _select: (selector) ->
    _$ref = @_$ref
    lookupAttrName = @_lookupAttrName
    elements = @_elements
    foundElements = []
    _$ref(selector).each ->
      id = _$ref(this).attr(lookupAttrName)
      foundElements.push elements[id]
    foundElements

  getAttribute: (selector, name, callback) ->
    @setAttribute selector, name, (value, start, end) ->
      callback(value, start, end)
      _value = value
      return null # ensure we don't actually set anything

  setAttribute: (selector, name, _value) ->
    @_build()

    for element in @_select selector
      openingTagString = @_string.substring(
        element.start,
        element.end
      )
      attributes = (new Element(openingTagString)).getAttributes()

      # Go through existing attributes, find the right one, and update it
      attrGotUpdated = false
      for attrDetails in attributes
        attrString = openingTagString.substring(attrDetails.start, attrDetails.end)
        attr = new Attribute attrString

        if attr.name() is name
          # Generate the new value if necessary
          type = typeof _value
          switch type
            when 'function'
              absoluteStart = element.start + attrDetails.start
              absoluteEnd = element.start + attrDetails.end
              value = _value(attr.valueWithoutQuotes(), absoluteStart, absoluteEnd)
            when 'string', 'boolean', 'undefined'
              value = _value
            else
              if _value?
                throw new Error "Unexpected type: #{type}"
              value = null

          switch value
            when true
              # Remove any existing value, turning it into a boolean attribute
              @_splicings.push
                start: element.start + attrDetails.start
                content: attr.name()
                end: element.start + attrDetails.end
            when false
              # Remove the whole attribute
              @_splicings.push
                start: element.start + attrDetails.start - 1
                content: ''
                end: element.start + attrDetails.end
            when null, undefined
              # Do nothing :)
            else
              # It's a string.
              # Replace or add the value
              if attr.hasValue()
                # Replace the existing value
                quoteType = attr.quoteType()
                valStart = (
                  element.start +
                  attrDetails.start +
                  attr.valueStartIndex()
                )
                valEnd = valStart + attr.valueWithoutQuotes().length
                switch quoteType
                  when '"', "'"
                    # It's quoted already; just add the value
                    # just replace the value inside the quotes
                    @_splicings.push
                      start: valStart
                      content: (
                        if quoteType is '"' then value.replace('"', '&quot;')
                        else value.replace("'", '&apos;')
                      )
                      end: valEnd
                  when null
                    # It's not quoted.
                    # Replace the existing value, and add quotes only if necessary
                    if /[\s\'\"]/.test value
                      # Needs quotes added
                      @_splicings.push
                        start: valStart
                        content: '"' + value.replace('"', '&quot;') + '"'
                        end: valEnd
                    else
                      # OK to leave it quoteless
                      @_splicings.push
                        start: valStart
                        content: value
                        end: valEnd
                  else throw new Error "Unknown quote type: #{quoteType}"

              else
                # It's a boolean attribute.
                # Add the value after it, in double quotes
                endOfAttributeIndex = (
                  element.start +
                  attrDetails.end
                )
                @_splicings.push
                  start: endOfAttributeIndex
                  content: '="' + value.replace('"', '&quot;') + '"'
                  end: endOfAttributeIndex

          attrGotUpdated = true
          continue # No need to check if any more attributes match

      # If nothing got updated, the attribute must not have been found.
      if not attrGotUpdated
        # The attribute didn't already exist; we need to insert it.
        # Generate the new attribute to insert
        newAttrString = do ->
          type = typeof _value
          switch type
            when 'function'
              value = _value(null, null, null)
            when 'string', 'boolean'
              value = _value
            else throw new Error "Unexpected type: #{type}"

          switch value
            # when false # ...means "remove", but it doesn't exist, so do nothing
            # when null # ...means "cancel making any change", so do nothing
            when true # means "set as boolean attr"
              return name
            else
              if typeof value isnt 'string'
                throw new Error "Unexpected type: #{typeof value} (#{value}"
              # Set the value to this string
              return "#{name}=\"#{value.replace('"', '&quot;')}\""

        # Insert it as the last attribute
        endInsideOpeningTag = (element.contentStart - 1)
        if @_string.charAt(endInsideOpeningTag - 1) is '/'
          endInsideOpeningTag--
        @_splicings.push
          start: endInsideOpeningTag
          content: " #{newAttrString}"
          end: endInsideOpeningTag

    @_execute()

  getInnerHTML: (selector, callback) ->
    @setInnerHTML selector, (value, start, end) ->
      callback(value, start, end)
      _value = value
      return null # ensure we don't actually set anything

  setInnerHTML: (selector, _newHTML) ->
    @_build()

    type = typeof _newHTML
    for element in @_select selector
      newHTML = null
      switch type
        when 'function'
          oldHTML = @_string.substring element.contentStart, element.contentEnd
          newHTML = _newHTML(oldHTML, element.contentStart, element.contentEnd)
        when 'string'
          newHTML = _newHTML
        else
          if _newHTML?
            throw new Error "Unexpected type: #{type}"
      if newHTML?
        @_splicings.push
          start: element.contentStart
          content: newHTML
          end: element.contentEnd

    @_execute()

  _execute: ->
    if @_splicings.length
      lastIndex = 0
      newString = ''
      for splicing, i in @_splicings
        newString += (
          @_string.substring(
            lastIndex, splicing.start
          ) +
          splicing.content
        )
        lastIndex = splicing.end
      newString += @_string.substring(lastIndex)
      @_string = newString
    null

  toString: ->
    @_string
