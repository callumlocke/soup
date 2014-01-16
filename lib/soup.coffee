htmlparser = require 'htmlparser2'
cheerio = require 'cheerio'
Element = require './element'
Attribute = require './attribute'

module.exports = class Soup

  constructor: (@_string) ->
    # This constructor builds the _$ref document and the _elements hash, which together allow finding elements in the markup string by CSS selector.

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
            console.log '\n\nEHHHH\n', "__#{openingTag}__"
            console.log parser
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

  setAttribute: (selector, name, _value) ->
    splicings = []

    for element in @_select selector
      openingTagString = @_string.substring(
        element.start,
        element.end
      )
      attributes = (new Element(openingTagString)).getAttributes()

      for attrDetails in attributes
        attrString = openingTagString.substring(attrDetails.start, attrDetails.end)
        attr = new Attribute attrString

        if attr.name() is name
          # Generate the new value if necessary
          switch typeof _value
            when 'function'
              value = _value(attr.valueWithoutQuotes())
            when 'string'
              value = _value
            else throw new Error "Unexpected type: #{typeof _value}"

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
                # It's quoted already; just replace the value inside the quotes
                splicings.push
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
                  splicings.push
                    start: valStart
                    content: (
                      '"' +
                      value.replace('"', '&quot;') +
                      '"'
                    )
                    end: valEnd
                else
                  # OK to leave it quoteless
                  splicings.push
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
            splicings.push
              start: endOfAttributeIndex
              content: (
                '="' +
                value.replace('"', '&quot;') +
                '"'
              )
              end: endOfAttributeIndex

          continue # No need to check if any more attributes match

    @_performSplicings splicings


  setInnerHTML: (selector, _newHTML) ->
    splicings = []

    for element in @_select selector
      console.log 'element', element

      switch typeof _newHTML
        when 'function'
          oldHTML = @_string.substring element.contentStart, element.contentEnd
          newHTML = _newHTML(oldHTML)
        when 'string'
          newHTML = _newHTML
        else throw new Error "Unexpected type: #{typeof _newHTML}"

      splicings.push
        start: element.contentStart
        content: newHTML
        end: element.contentEnd

    @_performSplicings splicings


  _performSplicings: (splicings) ->
    if splicings.length
      lastIndex = 0
      newString = ''
      for splicing, i in splicings
        newString += (
          @_string.substring(
            lastIndex, splicing.start
          ) +
          splicing.content
        )
        lastIndex = splicing.end
      newString += @_string.substring(lastIndex)

      @_string = newString

  toString: ->
    @_string;
