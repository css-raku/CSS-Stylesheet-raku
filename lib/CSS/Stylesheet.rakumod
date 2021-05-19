#| Overall CSS Stylesheet representation
unit class CSS::Stylesheet:ver<0.0.20>;

use CSS::Media;
use CSS::AtPageRule;
use CSS::Module:CSS3;
use CSS::Ruleset;
use CSS::Writer;
use CSS::MediaQuery;
use Method::Also;

has CSS::Media $.media;
has CSS::Module $.module = CSS::Module::CSS3.module; # associated CSS module
has CSS::Ruleset @.rules;
has CSS::MediaQuery %.rule-media{CSS::Ruleset};
has Str $.charset = 'utf-8';
has Exception @.warnings;
has CSS::AtPageRule @.at-pages;

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
    if !$!media || $!media ~~ $media-query {
        self.load(:$media-query, |$_) for @rule-list;
    }
}

multi method at-rule('page', Str :$pseudo-class, List :$declarations) {
    @!at-pages.push: CSS::AtPageRule.new: :$pseudo-class, :$declarations;
}

multi method at-rule('include', |c) {
    warn 'todo: @include(...) at rules';
}

multi method at-rule($rule, |c) {
    warn "ignoring \@$rule \{...\}";
}

multi method load(:at-rule($_)!) {
    my Str:D $type = .<at-keyw>:delete;
    $.at-rule: $type, |$_;
}

multi method load(:ruleset($ast)!, CSS::MediaQuery :$media-query) {
    my CSS::Ruleset $rule .= new: :$ast, :$!module, :$media-query;
    %!rule-media{$rule} = $_ with $media-query;
    @!rules.push: $rule;
}

multi method load($_) is default { warn .raku }

multi method parse(CSS::Stylesheet:U: $css!, |c) {
    self.new.parse($css, |c);
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

method ast(Bool :$optimize = True, |c) {
    my @stylesheet;
    my %at-rules{List};

    for @!at-pages {
        @stylesheet.push: .ast(:$optimize, |c);
    }

    for @!rules -> $rule {
        my $rule-ast = $rule.ast(:$optimize, |c);
        unless $optimize && !$rule-ast<ruleset><declarations> {
            with %!rule-media{$rule} {
                my $media-list = .ast;
                given %at-rules{$media-list} //= do {
                   my $at-rule = %(:at-keyw<media>, :$media-list, :rule-list[]);
                    %at-rules{$media-list} = $at-rule;
                    @stylesheet.push: (:$at-rule);
                    $at-rule;
                } {
                    .<rule-list>.push: $rule-ast;
                }
            }
            else {
                @stylesheet.push: $rule-ast;
            }
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

This class is used to parse style-sheet rule-sets. Objects may have an associated
media attributes which is used to filter `@media` rule-sets.

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
Parses the string as a CSS Stylesheet. Filters any `@media` rule-sets that do not match the associated media object.

=head3 method new (experimental)
=begin code :lang<raku>
method new(
    CSS::Module :$module, # CSS version to use (default CSS::Module::CSS3)
    Bool :$warn = True,   # display parse warnings
    CSS::Ruleset :@rules,
    CSS::AtPageRules :@at-pages,
)
=end code
This method can be used to create stylesheets from scratch, For example:
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

Returns an array of all the style sheet's rule-sets.

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

=end pod
