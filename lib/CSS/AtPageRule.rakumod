unit class CSS::AtPageRule;

use Method::Also;
use CSS::Properties;

has Str $.pseudo-class;
has CSS::Properties $.properties is built;

submethod TWEAK(List :$declarations) {
    $!properties .= new: :ast($_) with $declarations;
}

method Str is also<gist> {
    my Str $pseudo = do with $!pseudo-class { ' :'~ $_ } else { '' }
    my Str $css = do with $!properties { .Str } else { '' }
    [~] '@page', $pseudo, ' { ', $css, ' }';
}
