# soup [![Build Status](https://secure.travis-ci.org/callumlocke/soup.png?branch=master)](http://travis-ci.org/callumlocke/soup)

A little library for querying and manipulating tag soup via CSS selectors.

It performs manipulations on the string itself (rather than operating on a parsed DOM and then re-exporting it). So it retains all the syntactic/formatting nuances of the original, such as:

- attribute quotes or lack thereof,
- whitespace,
- invalid-but-parseable junk,
- omitted closing tags, etc.

Use cases:

- build tasks/plugins that need to manipulate markup without normalising away all the original formatting
- GUI webpage designers that need to combine hand-coded HTML with WYSIWYG-driven edits
- anywhere else you need to make automated, light-touch changes to other people's markup


## Usage

`npm install soup`

```javascript
var Soup = require('soup');
soup = new Soup('<br><img src=foo.jpg class=thing><br>');
soup.setAttribute('.thing', 'src', 'bar.png');
soup.setAttribute('.thing', 'class', function (oldValue){
  return oldValue + ' another'
});
soup.toString();
//> <br><img src=bar.png class="thing another"><br>
```

### Selectors

Soup uses [Cheerio](https://github.com/MatthewMueller/cheerio) under the hood for finding elements to update, so you can use any CSS3 selector in the methods below.


### Methods

#### `setAttribute(selector, attributeName, newValue)`

- `newValue` can be:
  - any string – to set the attribute's value
  - `true` – to set it as a boolean attribute (eg `disabled`)
  - `false` – to delete the attribute
  - `null` – for no change
  - a function – which will be passed the current value, and should return one of the above values
- Soup will respect the original quote style of each attribute it updates whenever possible (but quotes will be added to non-quoted values if necessitated by characters in the new value).

Example – adding a query string to all image URLs:

```javascript
soup.setAttribute('img', 'src', function (oldValue) {
  return oldValue + '?12345'
});
```

#### `setInnerHTML(selector, attributeName, newHTML)`

* `newHTML` can either be a string of HTML, or a function that returns a string of HTML.

Example – appending new content inside an element:

```javascript
soup.setInnerHTML('#foo', function (oldHTML) {
  return oldHTML + '<p>appended content</p>'
});
```


## License

Copyright (c) 2014 Callum Locke. Licensed under the MIT license.
