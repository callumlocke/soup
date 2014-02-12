# soup [![Build Status](https://secure.travis-ci.org/callumlocke/soup.png?branch=master)](http://travis-ci.org/callumlocke/soup) [![Dependency Status](https://gemnasium.com/callumlocke/soup.png)](https://gemnasium.com/callumlocke/soup)

A little library for querying and manipulating tag soup via CSS selectors.

It manipulates the string itself (rather than operating on a parsed DOM and then re-exporting it). So it retains all the syntactic/formatting nuances of the original, such as:

- attribute quotes or lack thereof,
- whitespace,
- invalid-but-parseable stuff,
- omitted closing tags, etc.

Use cases:

- build tasks/plugins that need to manipulate markup without parsing away all the original formatting;
- GUI webpage design tools that need to combine hand-coded HTML with WYSIWYG-driven edits;
- anywhere else you need to make automated, light-touch changes to other people's markup.


## Usage

`npm install soup`

```javascript
var Soup = require('soup');

soup = new Soup('<div class=thing><img src=cat.jpg></div>');

// Change the img src
soup.setAttribute('img', 'src', 'dog.jpg');
soup.toString(); // <div class=thing><img src=dog.jpg></div>

// Add a class to the div
soup.setAttribute('.thing', 'class', function (oldValue) {
  return oldValue + ' another';
});
soup.toString(); // <div class="thing another"><img src=dog.jpg></div>
```

### Selectors

Soup uses [Cheerio](https://github.com/MatthewMueller/cheerio) under the hood for finding elements to update, so you can use any CSS3 selector in the methods below.


### Methods

#### `setAttribute(selector, attributeName, newValue)`

- `newValue` can be:
  - any string – to set the attribute's value
  - `true` – to set it as a boolean attribute (eg `required`)
  - `false` – to delete the attribute
  - `null` – for "no change"
  - a function – which will be passed the current value, and should return one of the above values
    - it will also be passed an `index` as the second attribute (if the attribute was found), which contains the character index of the attribute you're changing.
- Soup will respect the original quote style of each attribute it updates whenever possible (but quotes will be added to non-quoted values if necessitated by characters in the new value).

Example – adding a query string to all image URLs:

```javascript
soup.setAttribute('img', 'src', function (oldValue) {
  return oldValue + '?12345'
});
```

#### `getAttribute(selector, attributeName, callback)`

- Same as `.setAttritute()`, except your callback's return value won't have any effect.


#### `setInnerHTML(selector, attributeName, newHTML)`

- `newHTML` can be:
  - a string of HTML
  - a function that returns a string of HTML
    - this will be passed the oldHTML
  - `null` for "no change"

Example – appending new content inside an element:

```javascript
soup.setInnerHTML('#foo', function (oldHTML) {
  return oldHTML + '<p>appended content</p>'
});
```


## License

Copyright (c) 2014 Callum Locke. Licensed under the MIT license.
