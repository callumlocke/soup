Soup = require '../src/soup'
fs = require 'fs'

module.exports =

  'Soup class':

    '#_build':
      'correctly establishes the key indexes of all the elements': (test) ->
        html = '<p classs=hi><span class="yo" ><img>asdf<br></span></p>'

        soup = new Soup html
        soup._build()

        # <p>
        pEl = soup._elements[1]
        pTag = html.substring(pEl.start, pEl.contentStart)
        test.strictEqual pTag, '<p classs=hi>'
        pContent = html.substring pEl.contentStart, pEl.contentEnd
        test.strictEqual pContent, '<span class="yo" ><img>asdf<br></span>'

        # <span>
        spanEl = soup._elements[2]
        spanTag = html.substring(spanEl.start, spanEl.contentStart)
        test.strictEqual spanTag, '<span class="yo" >'
        spanContent = html.substring spanEl.contentStart, spanEl.contentEnd
        test.strictEqual spanContent, '<img>asdf<br>'

        # <img>
        imgEl = soup._elements[3]
        imgTag = html.substring(imgEl.start, imgEl.contentStart)
        test.strictEqual imgTag, '<img>'
        imgContent = html.substring imgEl.contentStart, imgEl.contentEnd
        test.strictEqual imgContent, ''

        # <br>
        brEl = soup._elements[4]
        brTag = html.substring(brEl.start, brEl.contentStart)
        test.strictEqual brTag, '<br>'
        brContent = html.substring brEl.contentStart, brEl.contentEnd
        test.strictEqual brContent, ''

        test.done()

      'establishes correct indexes even when closing tags are omitted': (test) ->
        html = """
        <head>
          <title>Test</title>
        <body>
        <ul>
          <li>Item 1
          <li>Item 2
          <li>Item 3
        </ul>
        """

        soup = new Soup html
        soup._build()

        head = soup._elements[1]
        title = soup._elements[2]
        body = soup._elements[3]
        ul = soup._elements[4]
        li1 = soup._elements[5]
        li2 = soup._elements[6]
        li3 = soup._elements[7]

        headContent = html.substring head.contentStart, head.contentEnd
        test.strictEqual headContent, '\n  <title>Test</title>\n'

        li2Content = html.substring li2.contentStart, li2.contentEnd
        test.strictEqual li2Content, 'Item 2\n  '
        test.done()

    '#_select':
      'selects all the right elements': (test) ->
        html = '<img><br hi><br><p>Hi</p>'
        soup = new Soup html
        soup._build()
        test.strictEqual soup._select('img').length, 1
        test.strictEqual soup._select('br').length, 2
        test.strictEqual soup._select('br[hi]').length, 1
        test.strictEqual soup._select('img,br').length, 3
        test.done()
      'selecting the very first element in the string works OK': (test) ->
        # This was to fix a bug.
        html = '<img>'
        soup = new Soup html
        soup._build()
        selection = soup._select 'img'
        test.strictEqual selection.length, 1
        test.done()

    '#getAttribute':
      'finds the character index of the attribute': (test) ->
        soup = new Soup '  <br> <img data-foo=bar>'
        soup.getAttribute 'img', 'data-foo', (value, index) ->
          test.equal index, 12
        test.done()

      'does not update the value': (test) ->
        soup = new Soup '  <br><img data-foo=bar>'
        soup.getAttribute 'img', 'data-foo', (value) ->
          return 'ignoreme'
        test.equal soup.toString(), '  <br><img data-foo=bar>'
        test.done()

    '#setAttribute':
      'updating existing attribute':
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

        'making no change to an attribute': (test) ->
          soup = new Soup '<br><img data-foo>'
          soup.setAttribute 'img', 'data-foo', null
          soup.setAttribute 'img', 'data-foo', undefined
          test.strictEqual soup.toString(), '<br><img data-foo>'
          test.done()

        'passing a function to generate the new value': (test) ->
          soup = new Soup '<br><img src=bar.jpg>'
          soup.setAttribute 'img', 'src', (oldValue) ->
            test.strictEqual oldValue, 'bar.jpg'
            return oldValue + '?12345'

          test.strictEqual soup.toString(), '<br><img src=bar.jpg?12345>'
          test.done()

        'passing a function that elects to make no change': (test) ->
          soup = new Soup '<br><img src=bar.jpg>'
          soup.setAttribute 'img', 'src', (oldValue) ->
            test.strictEqual oldValue, 'bar.jpg'
            return null
          test.strictEqual soup.toString(), '<br><img src=bar.jpg>'
          test.done()

        'finding out the character index of the attribute': (test) ->
          soup = new Soup '  <br> <img data-foo=bar>'
          soup.setAttribute 'img', 'data-foo', (value, index) ->
            test.equal index, 12
            null
          test.done()

        'turning it into a boolean attribute (passing `true`)':
          'when already boolean (no change)': {}
          'when it has an existing value': (test) ->
            soup = new Soup '<br><img hey="ho">'
            soup.setAttribute 'img', 'hey', true
            test.strictEqual soup.toString(), '<br><img hey>'
            test.done()
        'removing the attribute': (test) ->
          soup = new Soup '<br><img hey="ho" yo>'
          soup.setAttribute 'img', 'hey', false
          test.strictEqual soup.toString(), '<br><img yo>'
          test.done()

        'updating multiple elements in one go': (test) ->
          html = """
            test
            <p class=para>Paragraph 1</p>
            <p class="para">Paragraph 2</p>
            """
          soup = new Soup html
          soup.setAttribute 'p', 'class', 'foo'
          test.strictEqual soup.toString(), """
            test
            <p class=foo>Paragraph 1</p>
            <p class="foo">Paragraph 2</p>
            """
          test.done()

      'adding a new attribute that isn\'t there':
        'normal': (test) ->
          soup = new Soup '<br><img data-foo>'
          soup.setAttribute 'img', 'src', 'hi.jpg'
          test.strictEqual soup.toString(), '<br><img data-foo src="hi.jpg">'
          test.done()

        'with self-closing slash': (test) ->
          soup = new Soup '<br><img data-foo/>'
          soup.setAttribute 'img', 'src', 'hi.jpg'
          test.strictEqual soup.toString(), '<br><img data-foo src="hi.jpg"/>'
          test.done()
        
        # 'with self-closing slash after space': (test) ->
        #   soup = new Soup '<br><img data-foo />'
        #   soup.setAttribute 'img', 'src', 'hi.jpg'
        #   test.strictEqual soup.toString(), '<br><img data-foo src="hi.jpg" />'
        #   test.done()

        'adding boolean attribute that isnt there': (test) ->
          soup = new Soup '<button><img data-foo/>'
          soup.setAttribute 'button', 'disabled', true
          test.strictEqual soup.toString(), '<button disabled><img data-foo/>'
          test.done()

      'making a few changes, one after another': (test) ->
        soup = new Soup '<br><img src="foo">'
        soup.setAttribute 'br', 'class', 'pigs'
        soup.setAttribute 'img', 'src', 'temporary'
        soup.setAttribute 'img', 'src', 'bar'
        test.strictEqual soup.toString(), '<br class="pigs"><img src="bar">'
        test.done()

      # 'handles multiple changes across nested elements': (test) ->
      #   html = """
      #     <div class=abc>
      #       <span class=abc>
      #         <span class=abc>Hey</span>
      #       </span>
      #     </div>
      #     """

      #   soup = new Soup html
      #   results = soup._select '.abc'
      #   console.log '\n\nRESULTS\n', results

      #   soup.setAttribute '.abc', 'class', 'hello'

      #   test.strictEqual soup.toString(), """
      #     <div class=hello>
      #       <span class=hello>
      #         <span class=hello>Hey</span>
      #       </span>
      #     </div>
      #     """

      #   test.done()

    '#setInnerHTML':
      'works with a single element': (test) ->
        soup = new Soup 'test <p class=para>foo <span>bar</span></p>'
        soup.setInnerHTML '.para', (oldHTML) ->
          test.strictEqual oldHTML, 'foo <span>bar</span>'
          return '<b>aight</b>'
        test.strictEqual soup.toString(), 'test <p class=para><b>aight</b></p>'
        test.done()

      'null means no change': (test) ->
        soup = new Soup 'test <p class=para>foo <span>bar</span></p>'

        soup.setInnerHTML '.para', null # set directly
        test.strictEqual soup.toString(), 'test <p class=para>foo <span>bar</span></p>'

        soup.setInnerHTML '.para', -> null # set via function return value
        test.strictEqual soup.toString(), 'test <p class=para>foo <span>bar</span></p>'

        test.done()

      'works with multiple elements': (test) ->
        html = """
          test
          <p class=para>Paragraph 1</p>
          <p class="para">Paragraph 2</p>
          """

        soup = new Soup html
        soup.setInnerHTML '.para', (oldHTML) ->
          oldHTML + '!!!'

        test.strictEqual soup.toString(), """
          test
          <p class=para>Paragraph 1!!!</p>
          <p class="para">Paragraph 2!!!</p>
          """
        test.done()
