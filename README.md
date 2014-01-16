# soup [![Build Status](https://secure.travis-ci.org/callumlocke/soup.png?branch=master)](http://travis-ci.org/callumlocke/soup)

A little library for querying and manipulating a raw HTML string, but without parsing it into a DOM and re-exporting it.

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


To do
-----

* Make it possible to pass a function that returns a value
* Add `soup.setInnerHTML(selector, newHTML)`
* Add `soup.setOuterHTML(selector, newHTML)`


License
-------

Copyright (c) 2014 Callum Locke. Licensed under the MIT license.
