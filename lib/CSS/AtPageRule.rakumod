#| @page at-rule representation, including margin boxes
unit class CSS::AtPageRule;

use Method::Also;
use CSS::Properties;

#| (optional) .e.g. 'left', 'right', 'first'
has Str $.pseudo-class;

#| Top-level CSS properties
has CSS::Properties $.properties is built;

#| Per page margin CSS properties
has CSS::Properties %.margin-box;

submethod TWEAK(List:D :$declarations!) {
    given $declarations {
        $!properties .= new: :ast($_);
        for $declarations.grep: {.<at-rule>:exists} {
            # extract margin box
            given .<at-rule> {
                my Str:D $name = .<at-keyw>;
                my List:D $ast = .<declarations>;
                %!margin-box{$name} .= new: :$ast;
            }
        }
    }
}

#| return AST representation of a single @page at-rule
method ast(|c) {
    my @declarations = $!properties.ast(:optimize, |c)<declaration-list>.List;

    for %!margin-box.keys.sort -> $at-keyw {
        my $declarations = %!margin-box{$at-keyw};
        my %at-rule = :$at-keyw, :declarations(%!margin-box{$at-keyw}.ast(:optimize, |c)<declaration-list>);
        @declarations.push: (:%at-rule);
    }
    my %at-rule = :at-keyw<page>, :@declarations;
    %at-rule<pseudo-class> = $_ with $!pseudo-class;
    :%at-rule;
}

#| serialize a @page rule to CSS
method Str(:$optimize = True, Bool :$terse = True, *%opt) is also<gist> {
    my Pair $ast = self.ast: :$optimize;
    %opt<color-names> //= True
        unless %opt<color-masks> || %opt<color-values>;
    my CSS::Writer $writer .= new: :$terse, |%opt;
    $writer.write: $ast;
}
