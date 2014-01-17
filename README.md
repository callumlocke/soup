# soup [![Build Status](https://secure.travis-ci.org/callumlocke/soup.png?branch=master)](http://travis-ci.org/callumlocke/soup)

A little library for querying and manipulating HTML via CSS selectors. It works on the string itself, rather than working on a parsed DOM and then re-exporting it. So it retains the syntactic/formatting nuances of the original, such as:

* attribute quotes or lack thereof,
* whitespace,
* invalid-but-parseable junk,
* omitted closing tags, etc.

This is intended to help with writing **build tasks/plugins** that need to manipulate other people's markup, without normalising away all the author's formatting choices.


Usage
-----

`npm install soup`

```javascript
var Soup = require('soup');
soup = new Soup('<br><img class=hey src=foo.jpg><br>');
soup.setAttribute('img.hey', 'src', 'bar.png');
soup.toString();
//> <br><img class=hey src=bar.png><br>
```

### Selectors

Soup uses [Cheerio](https://github.com/MatthewMueller/cheerio) under the hood for querying, so you can use any CSS3 selector in the methods below.


### Methods

#### `setAttribute(selector, attributeName, newValue)`

* `newValue` can be a **string**, or a **function** that returns a string.
  * If you use a function, it will be passed the attribute's current value as its first argument.

Example – adding a query string to all images:

```javascript
soup.setAttribute('img', 'src', function (oldValue) {
  return oldValue + '?12345'
});
```

#### `setInnerHTML(selector, attributeName, newHTML)`

* As with `setAttribute`, the `newHTML` can either be a string or a function.
  * If you use a function, it will be passed the element's current inner HTML.

Example – appending content inside an element:

```javascript
soup.setInnerHTML('#foo', function (oldHTML) {
  return oldHTML + '<p>appended content</p>'
});
```


To do
-----

* ~~Make it possible to pass a function that returns a value~~
* ~~Add `soup.setInnerHTML(selector, newHTML)`~~
* Add `soup.setOuterHTML(selector, newHTML)`


License
-------

Copyright (c) 2014 Callum Locke. Licensed under the MIT license.
