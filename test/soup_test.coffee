Soup = require '../lib/soup'
fs = require 'fs'

module.exports =

  'Soup class':

    'constructor':
      'correctly identifies the start positions of all the elements': (test) ->
        html = '<img>asdf<br>'
        soup = new Soup html
        test.strictEqual soup._elements[1].startIndex, 0
        test.strictEqual soup._elements[2].startIndex, 9
        test.done()

    '#_select':
      'selects all the right elements': (test) ->
        html = '<img><br hi><br><p>Hi</p>'
        soup = new Soup html
        test.strictEqual soup._select('img').length, 1
        test.strictEqual soup._select('br').length, 2
        test.strictEqual soup._select('br[hi]').length, 1
        test.strictEqual soup._select('img,br').length, 3
        test.done()

    'selection':
      'selecting the very first element in the string': (test) ->
        html = '<img>'
        soup = new Soup html
        selection = soup._select 'img'
        test.strictEqual selection.length, 1
        test.done()

    '#setAttribute':
      'updating non-quoted value':
        'with a new value that also doesn\'t need quotes': (test) ->
          soup = new Soup '<img data-foo=bar>'
          soup.setAttribute 'img', 'data-foo', 'wow'
          test.equal soup.toString(), '<img data-foo=wow>'
          test.done()

        'with a new value that DOES need quotes': (test) ->
          soup = new Soup '<br><img data-foo=bar>'
          soup.setAttribute 'img', 'data-foo', 'new " \' value'
          test.equal soup.toString(), '<br><img data-foo="new &quot; \' value">'
          test.done()

      'updating a quoted value':
        'with double quotes': (test) ->
          soup = new Soup '<br><img data-foo="bar">'
          soup.setAttribute 'img', 'data-foo', 'new " \' value'
          test.equal soup.toString(), '<br><img data-foo="new &quot; \' value">'
          test.done()
        'with single quotes': (test) ->
          soup = new Soup "<br><img data-foo='bar'>"
          soup.setAttribute 'img', 'data-foo', 'new " \' value'
          test.equal soup.toString(), "<br><img data-foo='new \" &apos; value'>"
          test.done()

      'adding a value to a boolean attribute': (test) ->
        soup = new Soup '<br><img data-foo>'
        soup.setAttribute 'img', 'data-foo', 'bar'
        test.strictEqual soup.toString(), '<br><img data-foo="bar">'
        test.done()

      'passing a function to generate the new value': (test) ->
        soup = new Soup '<br><img src=bar.jpg>'
        soup.setAttribute 'img', 'src', (oldValue) ->
          test.strictEqual oldValue, 'bar.jpg'
          return oldValue + '?12345'

        test.strictEqual soup.toString(), '<br><img src=bar.jpg?12345>'
        test.done()
