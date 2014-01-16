Attribute = require '../lib/attribute'

# Shorthand for use in assertions
attr = (str) -> new Attribute str

module.exports =

  'Attribute class':

    'constructor sets the string': (test) ->
      test.strictEqual attr('src="yo"').string, 'src="yo"'
      test.done()

    '#hasValue':
      'works correctly': (test) ->
        test.strictEqual  true,  attr('src="yo"').hasValue()
        test.strictEqual  true,  attr('src=yo').hasValue()
        test.strictEqual  true,  attr("src='yo'").hasValue()
        test.strictEqual  false, attr('src').hasValue()
        test.done()

    '#valueIsQuoted':
      'says whether or not the value is quoted': (test) ->
        test.strictEqual  true,   attr('src="yo"').valueIsQuoted()
        test.strictEqual  false,  attr('src=yo').valueIsQuoted()
        test.strictEqual  true,   attr("src='yo'").valueIsQuoted()
        test.strictEqual  false,  attr('src').valueIsQuoted()
        test.done()

    '#valueIncludingQuotes':
      'works when the value is quoted': (test) ->
        test.strictEqual  '"yo"',  attr('src="yo"').valueIncludingQuotes()
        test.strictEqual  "'yo'",  attr("src='yo'").valueIncludingQuotes()
        test.strictEqual  '"yo"',  attr('src= "yo" ').valueIncludingQuotes(),  'must not return trailing whitespace'
        test.done()

      'works when the value is not quoted': (test) ->
        test.strictEqual  'yo',  attr('src=yo').valueIncludingQuotes()
        test.strictEqual  'yo',  attr('src=yo ').valueIncludingQuotes(),  'must not return trailing whitespace'
        test.done()

    '#valueWithoutQuotes returns the value itself, without the quotes':
      'for quoted values': (test) ->
        test.strictEqual  attr('src="yo"').valueWithoutQuotes(),     'yo'
        test.strictEqual  attr(' href="yo" ').valueWithoutQuotes(),  'yo'
        test.strictEqual  attr("href='yo'").valueWithoutQuotes(),    'yo'
        test.done()
      'for unquoted values': (test) ->
        test.strictEqual  attr('src=yo').valueWithoutQuotes(),      'yo'
        test.strictEqual  attr('href=yo').valueWithoutQuotes(),     'yo'
        test.strictEqual  attr(' href=yo  ').valueWithoutQuotes(),  'yo'
        test.done()

    '#quoteType':
      'returns the type of quotes used on the value': (test) ->
        test.strictEqual  '"',   attr('src="yo"').quoteType()
        test.strictEqual  null,  attr('src=yo').quoteType()
        test.strictEqual  "'",   attr("src='yo'").quoteType()
        test.strictEqual  null,  attr('src').quoteType()
        test.done()

    '#valueStartIndex returns the start index of the actual value':
      'for quoted values': (test) ->
        test.strictEqual  attr('src="yo"').valueStartIndex(),   5
        test.strictEqual  attr('href="yo"').valueStartIndex(),  6
        test.strictEqual  attr("href='yo'").valueStartIndex(),  6
        test.done()

      'for unquoted values': (test) ->
        test.strictEqual  attr('src=yo').valueStartIndex(),    4
        test.strictEqual  attr('href=yo').valueStartIndex(),   5
        test.strictEqual  attr(' href=yo ').valueStartIndex(), 6
        test.done()

    '#valueEndIndex returns the end index of the actual value':
      'for quoted values': (test) ->
        test.strictEqual  attr('src="yo"').valueEndIndex(),   7
        test.strictEqual  attr('href="yo"').valueEndIndex(),  8
        test.strictEqual  attr("href='yo'").valueEndIndex(),  8
        test.done()

      'for unquoted values': (test) ->
        test.strictEqual  attr('src=yo').valueEndIndex(),     6
        test.strictEqual  attr('href=yo').valueEndIndex(),    7
        test.strictEqual  attr(' href=yo ').valueEndIndex(),  8
        test.done()
