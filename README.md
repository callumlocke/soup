# soup

[![NPM version][npm-image]][npm-url] [![Linux Build Status][travis-image]][travis-url] [![Dependency Status][depstat-image]][depstat-url] [![devDependency Status][devDepstat-image]][devDepstat-url]

A little library for querying and manipulating tag soup via CSS selectors.

It manipulates the string itself (rather than operating on a parsed DOM and then re-exporting it). So it retains all the syntactic/formatting nuances of the original, such as:

* attribute quotes or lack thereof,
* whitespace,
* invalid-but-parseable stuff,
* omitted closing tags, etc.

Use cases:

* build tasks/plugins that need to manipulate markup without parsing away all the original formatting;
* GUI webpage design tools that need to combine hand-coded HTML with WYSIWYG-driven edits;
* anywhere else you need to make automated, light-touch changes to other people's markup.


## Usage

```sh
$ npm install soup
```

```js
var Soup = require('soup');

soup = new Soup('<div class=thing><img src=cat.jpg></div>');

// Change the img src
soup.setAttribute('img', 'src', 'dog.jpg');
soup.toString();    // <div class=thing><img src=dog.jpg></div>

// Add a class to the div
soup.setAttribute('.thing', 'class', function (oldValue) {
  return oldValue + ' another';
});
soup.toString();    // <div class="thing another"><img src=dog.jpg></div>
```

### Selectors

Soup uses [Cheerio](https://github.com/MatthewMueller/cheerio) under the hood for finding elements to update, so you can use any CSS3 selector in the methods below.


### Methods

#### setAttribute(selector, attributeName, newValue)

* `newValue` can be:
  * any string – to set the attribute's value
  * `true` – to set it as a boolean attribute (eg `required`)
  * `false` – to delete the attribute
  * `null` – for "no change"
  * a function – which should decide what to do and return the correct value (as a string, boolean, or `null`). The function will be passed these arguments (NB. indices are relative to the start of the whole HTML string):
    1. the current value
    2. the start index of the attribute
    3. the end index of the attribute
    4. the start index of the element
    5. the end index of the element
* Soup will respect the original quote style of each attribute it updates whenever possible (but quotes will be added to non-quoted values if necessitated by characters in the new value).

Example – adding a query string to all image URLs:

```js
soup.setAttribute('img', 'src', function (oldValue) {
  return oldValue + '?12345';
});
```

#### getAttribute(selector, attributeName, callback)

Same as `.setAttribute()`, except that any return value from your callback will be ignored.


#### setInnerHTML(selector, attributeName, newHTML)

* `newHTML` can be:
  * a string of HTML
  * a function that returns a string of HTML
    * this will be passed the oldHTML
  * `null` for "no change"

Example – appending new content inside an element:

```js
soup.setInnerHTML('#foo', function (oldHTML) {
  return oldHTML + '<p>appended content</p>';
});
```


## License

Copyright (c) 2014 Callum Locke. Licensed under the MIT license.

[npm-url]: https://npmjs.org/package/soup
[npm-image]: https://img.shields.io/npm/v/soup.svg?style=flat-square

[travis-url]: http://travis-ci.org/callumlocke/soup
[travis-image]: https://img.shields.io/travis/callumlocke/soup.svg?style=flat-square&label=Linux%20build

[depstat-url]: https://david-dm.org/callumlocke/soup
[depstat-image]: https://img.shields.io/david/callumlocke/soup.svg?style=flat-square

[devDepstat-url]: https://david-dm.org/callumlocke/soup
[devDepstat-image]: https://img.shields.io/david/dev/callumlocke/soup.svg?style=flat-square#info=devDependencies
