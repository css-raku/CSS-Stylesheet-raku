[[Raku CSS Project]](https://css-raku.github.io)
 / [[CSS-Stylesheet]](https://css-raku.github.io/CSS-Stylesheet-raku)

[![Actions Status](https://github.com/css-raku/CSS-Stylesheet-raku/workflows/test/badge.svg)](https://github.com/css-raku/CSS-Stylesheet-raku/actions)


Description
------

This module contains representational classes for CSS Style sheets,
including rules-sets and component @media and @page clauses.

Classes
-------

  * [CSS::Stylesheet](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/Stylesheet) - CSS Stylesheet class

  * [CSS::Media](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/Media) - CSS Media represenetation
  * [CSS::MediaQuery](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/MediaQuery) - CSS Media query class

  * [CSS::Ruleset](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/Ruleset) - CSS Ruleset class

  * [CSS::Selectors](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/Selectors) - CSS DOM attribute class

  * [CSS::AtPageRule](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/AtPageRule) - CSS @page {...} representation

Scripts
-------

* `css-tidy.raku [--/optimize] [--pretty] [--imports] [--/warn] [--lax] [--allow property ...] [--color=names|values|masks] [--module=css3|svg] <file> [<output>]`

Rebuild a CSS Style-sheet with various checks and optimizations.


See Also
--------

  * [CSS](https://css-raku.github.io/CSS-raku) - CSS Stylesheet  processing

  * [CSS::Module](https://css-raku.github.io/CSS-Module-raku) - CSS Module Raku module

  * [CSS::Properties](https://css-raku.github.io/CSS-Properties-raku) - CSS Properties Raku module


Todo
----

- `@document` At-Rule

