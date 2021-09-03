#| Overall CSS Stylesheet representation
unit class CSS::Stylesheet:ver<0.0.22>;

use CSS::AtPageRule;
use CSS::Font::Descriptor;
use CSS::Font::Selector;
use CSS::MediaQuery;
use CSS::Media;
use CSS::Module:CSS3;
use CSS::Ruleset;
use CSS::Writer;
use Method::Also;
use URI;

has CSS::Media $.media;
has CSS::Module $.module = CSS::Module::CSS3.module; # associated CSS module
has CSS::Module $.fontface-module = $!module.sub-module<@font-face>;
has CSS::Ruleset @.rules;
has CSS::MediaQuery %.rule-media{Any};
has Str $.charset = 'utf-8';
has Exception @.warnings;
has CSS::AtPageRule @.at-pages;
# by sequence
has CSS::Font::Descriptor @.font-face;
# by font-name
has CSS::Font::Descriptor %!font-face;
has URI() $.base-url = '.';

method font-selector($font, |c) {
    CSS::Font::Selector.new: :$font, :$!base-url, :@.font-face, |c;
}

multi method font-face { @!font-face }
multi method font-face(Str $family) { %!font-face{$family} }

##constant DisplayNode = ...; # not handled by Rakudo yet
sub DisplayNone { state $ //= CSS::Properties.new: :display<none>; }

submethod TWEAK {
    for @!rules -> $rule {
        %!rule-media{$rule} = $_ with $rule.media-query;
    }
}

multi method load(:stylesheet($_)!) {
    $.load: |$_ for .list;
}

multi method at-rule('charset', :string($_)!) {
    $!charset = .lc;
}

multi method at-rule('media', :@media-list, :@rule-list) {
    my CSS::MediaQuery $media-query .= new: :ast(@media-list)
        if @media-list;
    # filter rule-sets, based on our media settings
    if $media-query ~~ $!media {
        self.load(:$media-query, |$_) for @rule-list;
    }
}

multi method at-rule('page', Str :$pseudo-class, List :$declarations) {
    @!at-pages.push: CSS::AtPageRule.new: :$pseudo-class, :$declarations;
}

multi method at-rule('font-face', :declarations(@ast)!, CSS::MediaQuery :$media-query) {
    my CSS::Font::Descriptor $font-face .= new: :@ast, :module($!fontface-module);
    %!rule-media{$font-face} = $_ with $media-query;
    @!font-face.push: $font-face;
    %!font-face{$_} = $font-face
        with $font-face.font-family;
}

multi method at-rule('include', |c) {
    warn 'todo: @include(...) at rules';
}

multi method at-rule($rule, |c) {
    warn "ignoring \@$rule \{...\}";
}

multi method load(:at-rule($_)!, |c) {
    my Str:D $type = .<at-keyw>:delete;
    $.at-rule: $type, |$_, |c;
}

multi method load(:ruleset($ast)!, CSS::MediaQuery :$media-query) {
    my CSS::Ruleset $rule .= new: :$ast, :$!module, :$media-query;
    %!rule-media{$rule} = $_ with $media-query;
    @!rules.push: $rule;
}

multi method load($_) is default { warn .raku }

multi method parse(CSS::Stylesheet:U: $css!, Bool :$lax, Bool :$warn = True, |c) {
    self.new(|c).parse($css, :$lax, :$warn);
}
multi method parse(CSS::Stylesheet:D: $css!, Bool :$lax, Bool :$warn = True, CSS::Module :$module) {
    $!module = $_ with $module;
    my $actions = $!module.actions.new: :$lax;
    given $!module.parse($css, :rule<stylesheet>, :$actions) {
        @!warnings.append: $actions.warnings;
        if $warn {
            note $_ for $actions.warnings;
        }
        $.load: |.ast;
    }
    self;
}

our sub merge-properties(@prop-sets, CSS::Properties $props = CSS::Properties.new) {
    my %seen  = $props.properties.map(* => 1);
    my %vital = $props.important;

    for @prop-sets.reverse -> CSS::Properties $prop-set {
        my %important = $prop-set.important;
        for $prop-set.properties {
            $props."$_"() = $prop-set."$_"()
                if !%seen{$_}++ || (%important{$_} && !%vital{$_});
        }
    }
    $props;
}

method page(Bool :$first, Bool :$right, Bool :$left, Str :$margin-box, |c) {
    my CSS::AtPageRule @page-rules = @!at-pages.grep: {
        given .pseudo-class {
            when 'first' { $first }
            when 'left'  { $left  }
            when 'right' { $right }
            default { True }
        }
    };
    my @prop-sets = @page-rules.map: -> $r {
        with $margin-box { $r.margin-box{$_} // DisplayNone }
        else { $r.properties }
    }
    @prop-sets
        ?? merge-properties(@prop-sets, CSS::Properties.new(|c))
        !! CSS::Properties;
}

method !media-slot(@stylesheet, %at-rules, $rule) {
    with %!rule-media{$rule} {
        my $media-list = .ast;
        %at-rules{$media-list} //= do {
            my $at-rule = %(:at-keyw<media>, :$media-list, :rule-list[]);
            @stylesheet.push: (:$at-rule);
            $at-rule;
        }
    }
}

method ast(Bool :$optimize = True, |c) {
    my @stylesheet;
    my %at-rules{List};

    for @!at-pages {
        @stylesheet.push: .ast(:$optimize, |c);
    }

    for @!rules -> $rule {
        my $rule-ast = $rule.ast(:$optimize, |c);
        unless $optimize && !$rule-ast<ruleset><declarations> {
           with self!media-slot(@stylesheet, %at-rules, $rule)  {
               .<rule-list>.push: $rule-ast;
            }
            else {
                @stylesheet.push: $rule-ast;
            }
        }
    }

    for @!font-face {
        my List:D $declarations = .ast(:$optimize)<declaration-list>;
        my $rule-ast = 'at-rule' => %( :at-keyw<font-face>, :$declarations );
        with self!media-slot(@stylesheet, %at-rules, $_)  {
            .<rule-list>.push: $rule-ast;
        }
        else {
            @stylesheet.push: $rule-ast;
        }
    }

    :@stylesheet;
}

method Str(:$optimize = True, Bool :$terse = True, *%opt) is also<gist> {
    my Pair $ast = self.ast: :$optimize;
    %opt<color-names> //= True
        unless %opt<color-masks> || %opt<color-values>;
    my CSS::Writer $writer .= new: :$terse, |%opt;
    $writer.write: $ast;
}

=begin pod

=head2 Description

This class is used to build or parse CSS style-sheets, including selectors and rule-sets. `@page` and `@media` at-rules are also supported.

=head2 Methods

=head3 method parse
=begin code :lang<raku>
method parse(
    Str $stylesheet,      # stylesheet to parse
    CSS::Media :$media,   # associated media (optional)
    CSS::Module :$module, # CSS version to use (default CSS::Module::CSS3
    Bool :$warn = True,   # display parse warnings
) returns CSS::Stylesheet
=end code
Parses an existing CSS style-sheet.

=item Filters any `@media` scoped rule-sets that do not match the associated media object.

=items The `rules` method can then be used to return remaining rule-sets (see below)

=item `@page` property sets and page-boxes can be queried using the `page` method (see below).

=head3 method new (experimental)
=begin code :lang<raku>
method new(
    CSS::Module :$module, # CSS version to use (default CSS::Module::CSS3)
    Bool :$warn = True,   # display parse warnings
    CSS::Ruleset :@rules,
    CSS::AtPageRules :@at-pages,
)
=end code
The `new` method can be used to create CSS stylesheets from scratch, For example:
=begin code :lang<raku>
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

=end code
See L<CSS::Ruleset>, L<CSS::AtPageRule>, and L<CSS::MediaQuery> for individual constructors and coercement rules.

=head3 method page

=begin code :lang<raku>
method page(Bool :$first, Bool :$right, Bool :$left,
            Str :$margin-box --> CSS::Properties)
=end code
Computes an `@page` at rule property list. Optionally with
a `:first`, `:left`, or `:right` page selection.

The `:$margin-box` option matches a sub-rule such as `@top-left`, `@top-center`,
etc. If there is no such rule, a property list of `display:none;` is returned.

=head3 method rules

     method rules() returns Array[CSS::Ruleset]

Returns an array of all the style sheet's rule-sets, after any `@media` selections.

If a `media` has not been set for the style-sheet, all rule-sets are returned.     

=head3 method at-pages

     method at-pages() returns Array[CSS::AtPageRule]

Returns an array of all the style sheet's `@page` at-rules.

=head2 See Also
=head3 L<CSS::PageBox>

L<CSS::PageBox> (from the CSS::Properties distrubution) is able to create
a correctly sized page using `@page` properties as in the following example:

=begin code :lang<raku>
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

=end code

=head3 font-face
=begin code :lang<raku>
method font-face() returns Array[CSS::Properties]
=end code
Returns a list of properties declared  via `@font-face` rules.

Note that L<CSS::Font> `match()` method can be used to select the first (if any)
matching rule.

=begin code :lang<raku>
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
    my CSS::Font $font .= new: font-props("bold italic 12pt DejaVu Sans");
    say $font.select($css.font-face).src; # fonts/DejaVuSans-BoldOblique.ttf
=end code

=head3 method base-url
=begin code :lang<raku>
method base-url returns URI
=end code
A default base URL for the stylesheet.

=head3 method font-selector
=begin code :lang<raku>
method font-selector(CSS::Font() $font, URI() :$base-url) returns CSS::Font::Selector
=end code
Returns a L<CSS::Font::Selector> objects for font matching and selection

=end pod
