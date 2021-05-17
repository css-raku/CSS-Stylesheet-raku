unit class CSS::AtPageRule;

use Method::Also;
use CSS::Properties;

has Str $.pseudo-class;
has CSS::Properties $.properties is built;
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

method Str(:$optimize = True, Bool :$terse = True, *%opt) is also<gist> {
    my Pair $ast = self.ast: :$optimize;
    %opt<color-names> //= True
        unless %opt<color-masks> || %opt<color-values>;
    my CSS::Writer $writer .= new: :$terse, |%opt;
    $writer.write: $ast;
}
