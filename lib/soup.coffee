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
          startIndex: parser.startIndex
          id: tagId
        openingTag = @_string.substring(parser.startIndex, parser.endIndex+1)
        modifiedOpeningTag = do =>
          endOfTagNameIndex = openingTag.indexOf ' '
          if endOfTagNameIndex == -1
            endOfTagNameIndex = openingTag.indexOf '/'
          if endOfTagNameIndex == -1
            endOfTagNameIndex = openingTag.indexOf '>'
          if endOfTagNameIndex == -1
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
        if correspondingOpeningTag.startIndex == 1 && @_string.charAt(1) != '<'
          correspondingOpeningTag.startIndex = 0

        endIndex = parser.endIndex + 1

        @_elements[correspondingOpeningTag.id] =
          # string: @_string.substring(
          #   correspondingOpeningTag.startIndex,
          #   endIndex
          # ) # TODO: get this lazily instead, to improve memory usage
          startIndex: correspondingOpeningTag.startIndex
          endIndex: endIndex

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

  setAttribute: (selector, name, value) ->
    selection = @_select selector

    for element in selection
      openingTagString = @_string.substring(
        element.startIndex,
        element.endIndex
      )
      attributes = (new Element(openingTagString)).attributes

      for attrDetails in attributes
        attrString = openingTagString.substring(attrDetails.start, attrDetails.end)
        attr = new Attribute attrString

        if attr.name() is name
          if attr.hasValue()
            # Replace the existing value
            quoteType = attr.quoteType()
            valStart = (
              element.startIndex +
              attrDetails.start +
              attr.valueStartIndex()
            )
            valEnd = valStart + attr.valueWithoutQuotes().length
            switch quoteType
              when '"', "'"
                # It's quoted already; just replace the value inside the quotes
                @_string = (
                  @_string.substring(0, valStart) +
                  (
                    if quoteType is '"' then value.replace('"', '&quot;')
                    else value.replace("'", '&apos;')
                  ) +
                  @_string.substring(valEnd)
                )
              when null
                # It's not quoted.
                # Replace the existing value, and add quotes only if necessary
                if /[\s\'\"]/.test value
                  # Needs quotes added
                  @_string = (
                    @_string.substring(0, valStart) +
                    '"' +
                    value.replace('"', '&quot;') +
                    '"' +
                    @_string.substring(valEnd)
                  )
                else
                  # OK to leave it quoteless
                  @_string = (
                    @_string.substring(0, valStart) +
                    value +
                    @_string.substring(valEnd)
                  )
              else throw new Error "Unknown quote type: #{quoteType}"

          else
            # It's a boolean attribute.
            # Add the value after it, in double quotes
            endOfAttributeIndex = (
              element.startIndex +
              attrDetails.end
            )
            @_string = (
              @_string.substring(0, endOfAttributeIndex) +
              '="' +
              value.replace('"', '&quot;') +
              '"' +
              @_string.substring(endOfAttributeIndex)
            )
          return this

  toString: ->
    @_string;
