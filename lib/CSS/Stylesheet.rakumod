unit class CSS::Stylesheet;

use CSS::Media;
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

multi method at-rule('include', |c) {
    warn 'todo: @include(...) at rules';
}

multi method at-rule($rule, |c) is default {
    warn "ignoring \@$rule \{...\}";
}

multi method load(:at-rule($_)!) {
    my $type = .<at-keyw>:delete;
    $.at-rule: $type, |$_;
}

multi method load(:ruleset($ast)!, :$media-list) {
    my CSS::Ruleset $rule .= new: :$ast;
    %!rule-media{$rule} = $_ with $media-list;
    @!rules.push: $rule;
}

multi method load($_) is default { warn .raku }

method parse($css!, Bool :$lax, Bool :$warn = True, |c) {
    my $obj = self;
    $_ .= new(|c) without $obj;
    my $actions = $obj.module.actions.new: :$lax;
    given $obj.module.parse($css, :rule<stylesheet>, :$actions) {
        $obj.warnings.append: $actions.warnings;
        if $warn {
            note $_ for $obj.warnings;
        }
        $obj.load: |.ast;
    }
    $obj;
}

method ast(Bool :$optimize = True, |c) {
    my @stylesheet;
    my %at-rules{List};

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

=head2 Name

CSS::Stylesheet - overall stylesheet

=head2 Description

This class is used to parse style-sheets and load rule-sets. Objects have an associated
media attributes which is used to filter `@media` rule-sets.

=head2 Methods

=head3 method parse

    method parse(Str $stylesheet, Str :$media) returns CSS::Stylesheet

Parses the string as a CSS Stylesheet. Filters any `@media` rule-sets that do not match
the supplied media object.


=head3 method rules

     method rules() returns Array[CSS::Ruleset]

Returns the rule-sets in the loaded style-sheet.

=end pod
