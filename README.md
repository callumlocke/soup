# soup [![Build Status](https://secure.travis-ci.org/callumlocke/soup.png?branch=master)](http://travis-ci.org/callumlocke/soup)

A little library for querying and manipulating a raw HTML string, but without just parsing it into a DOM and re-exporting it.

This is intended to help with writing **build tasks/plugins** that need to manipulate markup while respecting and preserving the syntactic/formatting nuances of the original – nuances such as: attribute quotes or lack thereof, whitespace, invalid but parseable junk, omitted closing tags, etc.


Usage
-----

`npm install soup`

```javascript
var Soup = require('soup');
soup = new Soup('<br><img src=foo.jpg><br>');
soup.setAttribute('img', 'src', 'bar.png');
soup.toString();
//> <br><img src=bar.png><br>
```

Note that you can use **any CSS3 selector** to query for elements. The above example just uses `img`, but you could use anything that [Cheerio](https://github.com/MatthewMueller/cheerio) would understand.


### Generating new values dynamically

For the new value, you can also pass a **function** that returns the new value. Your function will be passed the old value.

For example, to add a cachebuster query string to all images:

```javascript
soup.setAttribute('img', 'src', function (oldValue) {
  return oldValue + '?12345'
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
