[[Raku CSS Project]](https://css-raku.github.io)
 / [[CSS-Stylesheet]](https://css-raku.github.io/CSS-Stylesheet-raku)
 / [CSS::Stylesheet](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/Stylesheet)

class CSS::Stylesheet
---------------------

Overall CSS Stylesheet representation

Description
-----------

This class is used to parse style-sheet rule-sets. Objects have an associated media attributes which is used to filter `@media` rule-sets.

Methods
-------

### method parse

    method parse(Str $stylesheet, Str :$media) returns CSS::Stylesheet

Parses the string as a CSS Stylesheet. Filters any `@media` rule-sets that do not match the supplied media object.

### method page

    method page(Bool :$first, Bool :$right, Bool :$left,
                Str :$margin-box --> CSS::Properties)

Compute `@page` at rule property list.

### method rules

    method rules() returns Array[CSS::Ruleset]

Returns the rule-sets in the loaded style-sheet.

