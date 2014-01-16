Element = require '../lib/element'

# Shorthand for use in assertions
tag = (str) -> new Element str

module.exports =

  'Element class':
    'works with dodgy markup': (test) ->
      dodgy = """<thing   id="unno" hey="ho" crumb  some=thing foo=bar class="mish"title="mash" whoa='no' foo= bar won ton  lon  empty=""   >"""

      ot = new Element dodgy

      expectedAttributes = [
        'id="unno"'
        'hey="ho"'
        'crumb'
        'some=thing'
        'foo=bar'
        'class="mish"'
        'title="mash"'
        "whoa='no'"
        'foo= bar'
        'won'
        'ton'
        'lon'
        'empty=""'
      ]

      test.strictEqual expectedAttributes.length, ot.attributes.length

      for expected, i in expectedAttributes
        attr = ot.attributes[i]
        result = dodgy.substring attr.start, attr.end
        test.strictEqual result, expected

      test.done()

    'works with single attribute':
      'boolean': (test) ->
        dodgy = '<img data-asdf>'
        ot = new Element dodgy
        test.strictEqual ot.attributes.length, 1
        test.strictEqual dodgy.substring(ot.attributes[0].start, ot.attributes[0].end), 'data-asdf'
        test.done()
