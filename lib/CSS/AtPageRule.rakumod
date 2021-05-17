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

method Str is also<gist> {
    my Str $pseudo = do with $!pseudo-class { ' :'~ $_ } else { '' }
    my Str $css = do with $!properties { .Str } else { '' }
    [~] '@page', $pseudo, ' { ', $css, ' }';
}
