#| CSS Rule-set representation
unit class CSS::Ruleset;

use CSS::Properties;
use CSS::Selectors;
use CSS::Module;
use CSS::Module::CSS3;
use CSS::Writer;
use CSS::MediaQuery;

has CSS::Selectors() $.selectors handles<xpath specificity>;
has CSS::Properties() $.properties;
has CSS::MediaQuery() $.media-query; # associated media (raw AST only)

submethod TWEAK(:%ast is copy, :selectors($), :properties($), :media-query($), |c) {
    %ast = $_ with %ast<ruleset>;
    $!properties .= new: :ast($_), |c
       with %ast<declarations>:delete;
    $!selectors .= new: :%ast, |c
        if %ast;
}

method parse(CSS::Ruleset:U: Str:D $rule-set!, :$module = CSS::Module::CSS3.module, |c --> CSS::Ruleset) {
    my $actions .= $module.actions.new;
    my $p := $module.parse($rule-set, :rule<ruleset>, :$actions)
        or die "unable to parse CSS rule-set: $rule-set";
    note $_ for $actions.warnings;
    my $ast = $p.ast;
    self.new: :$ast, |c;
}

multi method COERCE(Str:D $rule-set --> CSS::Ruleset ) { self.parse: $rule-set; }

method ast(|c) {
    my %ast = $!selectors.ast;
    %ast<declarations> = $!properties.ast(:keep-defaults, |c)<declaration-list>;
    :ruleset(%ast);
}

method Str(:$optimize = True, :$terse = True, *%opt --> Str) {
    my %ast = $.ast: :$optimize;
    %opt<color-names> //= True
        unless %opt<color-masks> || %opt<color-values>;
    my CSS::Writer $writer .= new: :$terse, |%opt;
    $writer.write(%ast);
}

=begin pod

=head2 Synopsis

    use CSS::Ruleset;
    my CSS::Ruleset $rules .= parse('h1 { x:42;font-size: 2em; margin: 3px; }');
    say $rules.properties; # font-size: 2em; margin: 3px;
    say $rules.selectors.xpath;       # '//h1'
    say $rules.selectors.specificity; # v0.0.1
    say $rules.Str; # h1 { font-size:2em; margin:3px; }

=head2 Description

This is a container class for a CSS ruleset; a single set of CSS selectors and
declarations (or properties)/

=head2 Methods

=head3 method parse

   method parse(Str $css!) returns CSS::Ruleset;

Parses a single rule-set; creates a rule-set object.

=head3 method selectors

    use CSS::Selectors;
    method selectors() returns CSS::Selectors

Returns the rule-set's selectors

=head3  method properties

    use CSS::Properties;
    method properties() returns CSS::Properties

returns the rule-set's properties

=head3 method Str

    Reserialize the rule-set.

=end pod
