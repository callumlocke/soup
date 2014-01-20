Attribute = require '../lib/attribute'

# Shorthand for use in assertions
attr = (str) -> new Attribute str

module.exports =

  'Attribute class':

    'constructor sets the string': (test) ->
      test.strictEqual      attr('src="yo"').string,                    'src="yo"'
      test.done()

    '#hasValue':
      'works correctly': (test) ->
        test.strictEqual    attr('src="yo"').hasValue(),                true, 
        test.strictEqual    attr('src=yo').hasValue(),                  true, 
        test.strictEqual    attr("src='yo'").hasValue(),                true, 
        test.strictEqual    attr('src').hasValue(),                     false,
        test.done()

    '#valueIsQuoted':
      'says whether or not the value is quoted': (test) ->
        test.strictEqual    attr('src="yo"').valueIsQuoted(),           true, 
        test.strictEqual    attr('src=yo').valueIsQuoted(),             false,
        test.strictEqual    attr("src='yo'").valueIsQuoted(),           true, 
        test.strictEqual    attr('src').valueIsQuoted(),                false,
        test.done()

    '#valueIncludingQuotes':
      'works when the value is quoted': (test) ->
        test.strictEqual    attr('src="yo"').valueIncludingQuotes(),    '"yo"'
        test.strictEqual    attr("src='yo'").valueIncludingQuotes(),    "'yo'"
        test.strictEqual    attr('src= "yo" ').valueIncludingQuotes(),  '"yo"', '(must not return trailing whitespace)'
        test.done()

      'works when the value is not quoted': (test) ->
        test.strictEqual    attr('src=yo ').valueIncludingQuotes(),     'yo',  '(must not return trailing whitespace)'
        test.done()

    '#valueWithoutQuotes returns the value itself, without the quotes':
      'for quoted values': (test) ->
        test.strictEqual    attr('src="yo"').valueWithoutQuotes(),      'yo'
        test.strictEqual    attr(' href="yo" ').valueWithoutQuotes(),   'yo'
        test.strictEqual    attr("href='yo'").valueWithoutQuotes(),     'yo'
        test.done()
      'for unquoted values': (test) ->
        test.strictEqual    attr('src=yo').valueWithoutQuotes(),        'yo'
        test.strictEqual    attr('href=yo').valueWithoutQuotes(),       'yo'
        test.strictEqual    attr(' href=yo  ').valueWithoutQuotes(),    'yo'
        test.done()

    '#quoteType':
      'returns the type of quotes used on the value': (test) ->
        test.strictEqual    attr('src="yo"').quoteType(),               '"',
        test.strictEqual    attr('src=yo').quoteType(),                 null
        test.strictEqual    attr("src='yo'").quoteType(),               "'",
        test.strictEqual    attr('src').quoteType(),                    null
        test.done()

    '#valueStartIndex returns the start index of the actual value':
      'for quoted values': (test) ->
        test.strictEqual    attr('src="yo"').valueStartIndex(),         5
        test.strictEqual    attr('href="yo"').valueStartIndex(),        6
        test.strictEqual    attr("href='yo'").valueStartIndex(),        6
        test.done()

      'for unquoted values': (test) ->
        test.strictEqual    attr('src=yo').valueStartIndex(),           4
        test.strictEqual    attr('href=yo').valueStartIndex(),          5
        test.strictEqual    attr(' href=yo ').valueStartIndex(),        6
        test.done()

    '#valueEndIndex returns the end index of the actual value':
      'for quoted values': (test) ->
        test.strictEqual    attr('src="yo"').valueEndIndex(),           7
        test.strictEqual    attr('href="yo"').valueEndIndex(),          8
        test.strictEqual    attr("href='yo'").valueEndIndex(),          8
        test.done()

      'for unquoted values': (test) ->
        test.strictEqual    attr('src=yo').valueEndIndex(),             6
        test.strictEqual    attr('href=yo').valueEndIndex(),            7
        test.strictEqual    attr(' href=yo ').valueEndIndex(),          8
        test.done()
