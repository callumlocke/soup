###
  Attribute class

  Constructs an object that can provide information about the given attribute string, such as whether it is quoted, etc.
###

module.exports = class Attribute

  constructor: (@string) ->

  name: ->
    if not @hasValue()
      @string
    else @string.substring 0, @string.indexOf('=')

  hasValue: ->
    @string.indexOf('=') != -1

  valueStartIndex: ->
    index = @string.indexOf('=') + 1
    if index is -1
      null
    else if @valueIsQuoted()
      index + 1
    else
      index

  valueEndIndex: ->
    @valueStartIndex() + @valueWithoutQuotes().length

  valueWithoutQuotes: ->
    if @valueIsQuoted()
      val = @valueIncludingQuotes().trim()
      val.substring(1, val.length-1)
    else @valueIncludingQuotes()

  valueIsQuoted: ->
    !!(@hasValue() && (@string.indexOf('"') != -1 || @string.indexOf("'") != -1))

  quoteType: ->
    if @hasValue() && @valueIsQuoted()
      @valueIncludingQuotes().charAt(0)
    else null

  valueIncludingQuotes: ->
    if @hasValue
      @string.substring(@string.indexOf('=') + 1).trim()
    else null
