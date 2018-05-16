# Dashboard-2

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/jbampton/dashboard-2/blob/gh-pages/LICENSE)

http://thebeast.me/dashboard-2/

This project is using [Ruby](https://www.ruby-lang.org/en/) to build a high powered analytics dashboard website using [Google Charts](https://developers.google.com/chart/) [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript) library which is being hosted on [GitHub Pages](https://pages.github.com/).  [Bootstrap](http://getbootstrap.com/) and [jQuery](https://jquery.com/) are also being used for a [responsive designed](https://responsivedesign.is/) mobile first website.

Another interesting technique that is being used is [concatenation](https://en.wikipedia.org/wiki/Concatenation) to build all the [HTML 5](https://developer.mozilla.org/en-US/docs/Web/HTML) pages, which are then written to files via [variable interpolation](http://batsov.com/articles/2014/08/13/the-elements-of-style-in-ruby-number-14-variable-interpolation/).

Ruby instance variables are being used for each HTML page via the [instance_variable_get](http://apidock.com/ruby/Object/instance_variable_get) and [instance_variable_set](http://apidock.com/ruby/Object/instance_variable_set) built in Ruby custom functions.  


## Contributions

Fork and pull request. Simple.
