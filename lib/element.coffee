###
  Element class

  This is basically a simple parser for individual elements. It's primarily concerned with giving you information about the element's attributes.
###

IN_TAG_NAME            = 1
BEFORE_ATTRIBUTE_NAME  = 2
IN_ATTRIBUTE_NAME      = 3
AFTER_ATTRIBUTE_NAME   = 4
BEFORE_ATTRIBUTE_VALUE = 5
IN_ATTRIBUTE_VALUE_DQ  = 6
IN_ATTRIBUTE_VALUE_SQ  = 7
IN_ATTRIBUTE_VALUE_NQ  = 8

module.exports = class Element

  constructor: (@string) ->
    @attributes = []

    if @string[0] != '<'
      throw new Error 'First character of tag should be "<"'

    # Now just walk through the string and build up the attributes...
    i = 0
    state = IN_TAG_NAME
    currentAttrStart = null
    while ++i < @string.length - 1
      char = @string[i]

      switch state

        when IN_TAG_NAME
          if char is ' '
            state = BEFORE_ATTRIBUTE_NAME

        when BEFORE_ATTRIBUTE_NAME
          # or possibly before the end of the tag!
          if char is '/' or char is '>'
            break # Done!
          else if not /\s/.test char
            state = IN_ATTRIBUTE_NAME
            currentAttrStart = i
          # else state hasn't changed

        when IN_ATTRIBUTE_NAME
          if char is '='
            state = BEFORE_ATTRIBUTE_VALUE
          else if /\s/.test char
            state = AFTER_ATTRIBUTE_NAME
          else if /[\>\/]/
            break # Done!
          # else we're still in the attribute name.

        when AFTER_ATTRIBUTE_NAME
            # This is the space after an attribute name, where it's either invalid space between the name and the equals sign, or it's valid space after a boolean attribute.
            if char == '='
              state = BEFORE_ATTRIBUTE_VALUE
            else if not /\s/.test char
              # Roll the i back to the last space
              while /\s/.test @string.charAt(i - 1)
                i--
              @attributes.push
                start: currentAttrStart
                end: i
                # boolean: true # not needed
              state = BEFORE_ATTRIBUTE_NAME
              currentAttrStart = null

        when BEFORE_ATTRIBUTE_VALUE
          if char == '"'
            state = IN_ATTRIBUTE_VALUE_DQ
          else if char == "'"
            state = IN_ATTRIBUTE_VALUE_SQ
          else if not /\s/.test char
            state = IN_ATTRIBUTE_VALUE_NQ

        when IN_ATTRIBUTE_VALUE_DQ
          if char == '"'
            @attributes.push
              start: currentAttrStart
              end: i + 1
            currentAttrStart = null
            state = BEFORE_ATTRIBUTE_NAME

        when IN_ATTRIBUTE_VALUE_SQ
          if char is "'"
            @attributes.push
              start: currentAttrStart
              end: i + 1
            currentAttrStart = null
            state = BEFORE_ATTRIBUTE_NAME

        when IN_ATTRIBUTE_VALUE_NQ
          if /[\s\>\/]/.test char
            @attributes.push
              start: currentAttrStart
              end: i
            currentAttrStart = null
            state = BEFORE_ATTRIBUTE_NAME
        
        else throw new Error 'Bug in here somewhere'

    if currentAttrStart
      while /[\>\/]/.test @string.charAt(i)
        i--
      i++
      @attributes.push
        start: currentAttrStart
        end: i
      currentAttrStart = null
