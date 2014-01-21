###
  Element class

  This is basically a simple parser for individual elements. It's primarily concerned with getting character index info about the opening tag's attributes.
###

IN_TAG_NAME            = 1
LOOSE_IN_TAG           = 2
IN_ATTRIBUTE_NAME      = 3
AFTER_ATTRIBUTE_NAME   = 4
BEFORE_ATTRIBUTE_VALUE = 5
IN_ATTRIBUTE_VALUE_DQ  = 6
IN_ATTRIBUTE_VALUE_SQ  = 7
IN_ATTRIBUTE_VALUE_NQ  = 8

module.exports = class Element

  constructor: (@_string) ->

  getAttributes: ->
    return @_attributes if @_attributes?

    @_attributes = []

    if @_string.charAt(0) != '<'
      throw new Error 'First character of tag should be "<"'

    # Now just walk through the string and build up the attributes...
    i = 0
    state = IN_TAG_NAME
    currentAttrStart = null
    while ++i < @_string.length - 1
      char = @_string.charAt(i)

      switch state

        when IN_TAG_NAME
          if char is ' '
            state = LOOSE_IN_TAG

        when LOOSE_IN_TAG
          if char is '/' or char is '>' # End of tag
            break
          else if not /\s/.test char # Beginning of an attr name
            state = IN_ATTRIBUTE_NAME
            currentAttrStart = i
          # else still loose in tag

        when IN_ATTRIBUTE_NAME
          if char is '=' # Equals sign directly after attr name
            state = BEFORE_ATTRIBUTE_VALUE
          else if /\s/.test char # Either now waiting for an (invalidly-spaced) equals sign, or a boolean value has just been completed
            state = AFTER_ATTRIBUTE_NAME
          else if /[\>\/]/ # End of tag
            break
          # else we're still in the attribute name.

        when AFTER_ATTRIBUTE_NAME
            if char == '=' # Equals sign after (invalid) intra-attr space
              state = BEFORE_ATTRIBUTE_VALUE
            else if not /\s/.test char # Last boolean attribute was completed
              # Current attribute completed; add it
              if not currentAttrStart?
                throw new Error 'Bug: currentAttrStart should exist at this point'
              i-- while /\s/.test @_string.charAt(i - 1) # Roll index back to the last space
              @_attributes.push
                start: currentAttrStart
                end: i
                # boolean: true # (not needed)
              state = LOOSE_IN_TAG
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
            @_attributes.push
              start: currentAttrStart
              end: i + 1
            currentAttrStart = null
            state = LOOSE_IN_TAG

        when IN_ATTRIBUTE_VALUE_SQ
          if char is "'"
            @_attributes.push
              start: currentAttrStart
              end: i + 1
            currentAttrStart = null
            state = LOOSE_IN_TAG

        when IN_ATTRIBUTE_VALUE_NQ
          if /[\s\>\/]/.test char
            @_attributes.push
              start: currentAttrStart
              end: i
            currentAttrStart = null
            state = LOOSE_IN_TAG
        
        else throw new Error 'Bug in here somewhere'

    if currentAttrStart
      while /[\>\/]/.test @_string.charAt(i)
        i--
      i++
      @_attributes.push
        start: currentAttrStart
        end: i
      currentAttrStart = null

    return @_attributes
