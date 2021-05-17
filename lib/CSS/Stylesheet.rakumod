#| Overall CSS Stylesheet representation
unit class CSS::Stylesheet:ver<0.0.18>;

use CSS::Media;
use CSS::AtPageRule;
use CSS::Module:CSS3;
use CSS::Ruleset;
use CSS::Writer;
use Method::Also;

has CSS::Media $.media;
has CSS::Module $.module = CSS::Module::CSS3.module; # associated CSS module
has CSS::Ruleset @.rules;
has List %.rule-media{CSS::Ruleset};
has Str $.charset = 'utf-8';
has Exception @.warnings;
has CSS::AtPageRule @.at-pages;

##constant DisplayNode = ...; # not handled by Rakudo yet
sub DisplayNone { state $ //= CSS::Properties.new: :display<none>; }

multi method load(:stylesheet($_)!) {
    $.load: |$_ for .list;
}

multi method at-rule('charset', :string($_)!) {
    $!charset = .lc;
}

multi method at-rule('media', :@media-list, :@rule-list) {
    # filter rule-sets, based on our media settings
    if !$!media || $!media.query(:@media-list) {
        self.load(:@media-list, |$_) for @rule-list;
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

multi method load(:ruleset($ast)!, :$media-list) {
    my CSS::Ruleset $rule .= new: :$ast;
    %!rule-media{$rule} = $_ with $media-list;
    @!rules.push: $rule;
}

multi method load($_) is default { warn .raku }

multi method parse(CSS::Stylesheet:U: $css!, Bool :$lax, Bool :$warn = True, |c) {
    self.new(|c).parse($css, :$lax, :$warn);
}
multi method parse(CSS::Stylesheet:D: $css!, Bool :$lax, Bool :$warn = True) {
    my $actions = $.module.actions.new: :$lax;
    given $.module.parse($css, :rule<stylesheet>, :$actions) {
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

method page(Bool :$first, Bool :$right, Bool :$left, Str :$margin-box) {
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
        ?? merge-properties(@prop-sets)
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
            with %!rule-media{$rule} -> $media-list {
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

This class is used to parse style-sheet rule-sets. Objects have an associated
media attributes which is used to filter `@media` rule-sets.

=head2 Methods

=head3 method parse

    method parse(Str $stylesheet, Str :$media) returns CSS::Stylesheet

Parses the string as a CSS Stylesheet. Filters any `@media` rule-sets that do not match
the supplied media object.

=head3 method page

    method page(Bool :$first, Bool :$right, Bool :$left,
                Str :$margin-box --> CSS::Properties)

Compute `@page` at rule property list.


=head3 method rules

     method rules() returns Array[CSS::Ruleset]

Returns the rule-sets in the loaded style-sheet.

=end pod
