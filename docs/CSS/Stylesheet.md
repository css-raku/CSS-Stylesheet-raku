[[Raku CSS Project]](https://css-raku.github.io)
 / [[CSS-Stylesheet]](https://css-raku.github.io/CSS-Stylesheet-raku)
 / [CSS::Stylesheet](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/Stylesheet)

class CSS::Stylesheet
---------------------

Overall CSS Stylesheet representation

Description
-----------

This class is used to build or parse CSS style-sheets, including selectors and rule-sets. `@page` and `@media` at-rules are also supported.

Methods
-------

### method parse

```raku
method parse(
    Str $stylesheet,      # stylesheet to parse
    CSS::Module :$module, # CSS version to use (default CSS::Module::CSS3
    Bool :$warn = True,   # display parse warnings
) returns CSS::Stylesheet
```

Parses an existing CSS style-sheet.

  * Filters any `@media` scoped rule-sets that do not match the associated media object.

items
=====

The `rules` method can then be used to return remaining rule-sets (see below)

  * `@page` property sets and page-boxes can be queried using the `page` method (see below).

### method new

```raku
method new(
    CSS::Module :$module,    # CSS version to use (default CSS::Module::CSS3)
    Bool :$warn = True,      # display parse warnings
    Bool :$import,           # enable @import rules
    URI() :$base-url = '/.', # Base URL for relative urls (@import and @font-face)
    CSS::Ruleset :@rules,
    CSS::AtPageRules :@at-pages,
)
```

The `new` method can be used to create CSS stylesheets from scratch, For example:

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

Returns an array of all the style sheet's rule-sets, after any `@media` selections.

If a `media` has not been set for the style-sheet, all rule-sets are returned. 

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

### font-face

```raku
method font-face() returns Array[CSS::Properties]
```

Returns a list of properties declared via `@font-face` rules.

### method base-url

```raku
method base-url returns URI
```

A default base URL for the stylesheet.

### method font-sources

```raku
method font-sources(CSS::Font() $font, :$formats)
```

Returns a list of [CSS::Font::Resources::Source](https://css-raku.github.io/CSS-Font-Resources-raku/CSS/Font/Resources/Source) objects for matching fonts

```raku
my $style = q:to<END>.split(/^^'---'$$/);
    @font-face {
      font-family: "DejaVu Sans";
      src: url("fonts/DejaVuSans.ttf");
    }
    @font-face {
      font-family: "DejaVu Sans";
      src: url("fonts/DejaVuSans-Bold.ttf");
      font-weight: bold;
    }
    @font-face {
      font-family: "DejaVu Sans";
      src: url("fonts/DejaVuSans-Oblique.ttf");
      font-style: oblique;
    }
    @font-face {
      font-family: "DejaVu Sans";
      src: url("fonts/DejaVuSans-BoldOblique.ttf");
      font-weight: bold;
      font-style: oblique;
    }
    END
    my CSS::Stylesheet $css .= parse($style);
    my CSS::Font() $font = "bold italic 12pt DejaVu Sans";
    my CSS::Font::Resources::Sources @srcs = $css-font-sources($font);
    say @src.head.Str; # fonts/DejaVuSans-BoldOblique.ttf
```

