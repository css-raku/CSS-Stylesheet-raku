Name
----

CSS::Stylesheet - overall stylesheet

Description
-----------

This class is used to parse style-sheets and load rule-sets. Objects have an associated media attributes which is used to filter `@media` rule-sets.

Methods
-------

### method parse

    method parse(Str $stylesheet, Str :$media) returns CSS::Stylesheet

Parses the string as a CSS Stylesheet. Filters any `@media` rule-sets that do not match the supplied media object.

### method rules

    method rules() returns Array[CSS::Ruleset]

Returns the rule-sets in the loaded style-sheet.

