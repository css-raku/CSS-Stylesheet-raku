[[Raku CSS Project]](https://css-raku.github.io)
 / [[CSS-Stylesheet]](https://css-raku.github.io/CSS-Stylesheet-raku)
 / [CSS::Stylesheet](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/Stylesheet)

class CSS::Stylesheet
---------------------

Overall CSS Stylesheet representation

Description
-----------

This class is used to parse style-sheet rule-sets. Objects may have an associated media attributes which is used to filter `@media` rule-sets.

Methods
-------

### method parse

```raku
method parse(
    Str $stylesheet,      # stylesheet to parse
    CSS::Media :$media,   # associated media (optional)
    CSS::Module :$module, # CSS version to use (default CSS::Module::CSS3
    Bool :$warn = True,   # display parse warnings
) returns CSS::Stylesheet
```

Parses the string as a CSS Stylesheet. Filters any `@media` rule-sets that do not match the associated media object.

### method new (experimental)

```raku
method new(
    CSS::Module :$module, # CSS version to use (default CSS::Module::CSS3)
    Bool :$warn = True,   # display parse warnings
    CSS::Ruleset :@rules,
    CSS::AtPageRules :@at-pages,
)
```

This method can be used to create stylesheets from scratch, For example:

```raku
my CSS::MediaQuery() $media-query = 'print';
my CSS::Ruleset $h1 .= new: :selectors<h1>, :properties("color:blue");
my CSS::Ruleset $h1-print .= new: :selectors<h1>, :properties("color:black"), :$media-query;
my CSS::Properties() $page-props = 'margin:4pt'; 
my CSS::AtPageRule $at-page .= new: :properties($page-props);
my CSS::Stylesheet $stylesheet .= new: :rules[$h1, $h1-print], :at-pages[$at-page];
say $stylesheet.Str;
# @page { margin:4pt; }
# h1 { color:blue; }
# @media print { h1 { color:black; } }
```

See [CSS::Ruleset](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/Ruleset), [CSS::AtPageRule](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/AtPageRule), and [CSS::MediaQuery](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/MediaQuery) for individual constructors and coercement rules.

### method page

```raku
method page(Bool :$first, Bool :$right, Bool :$left,
            Str :$margin-box --> CSS::Properties)
```

Computes an `@page` at rule property list. Optionally with a `:first`, `:left`, or `:right` page selection.

The `:$margin-box` option matches a sub-rule such as `@top-left`, `@top-center`, etc. If there is no such rule, a property list of `display:none;` is returned.

### method rules

    method rules() returns Array[CSS::Ruleset]

Returns an array of all the style sheet's rule-sets.

### method at-pages

    method at-pages() returns Array[CSS::AtPageRule]

Returns an array of all the style sheet's `@page` at-rules.

See Also
--------

### [CSS::PageBox](https://css-raku.github.io/CSS-Properties-raku/CSS/PageBox)

[CSS::PageBox](https://css-raku.github.io/CSS-Properties-raku/CSS/PageBox) (from the CSS::Properties distrubution) is able to create a correctly sized page using `@page` properties as in the following example:

```raku
use CSS::Stylesheet;
use CSS::Properties;
use CSS::PageBox;
my CSS::Stylesheet $stylesheet .= parse: q:to<END>;
    @page {
      size:a4 landscape;
      margin:3mm;
      border:2mm;
      padding:5mm;
    }
    END

my CSS::Properties:D $page-props = $stylesheet.page: :units<mm>;
my CSS::PageBox $box .= new: :css($page-props);
say $box.margin;  # [297, 210, 0, 0]
say $box.border;  # [294, 207, 3, 3]
say $box.padding; # [292, 205, 5, 5]
say $box.content; # [287, 200, 10, 10]
```

