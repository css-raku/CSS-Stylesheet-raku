use v6;
use Test;
use CSS::Selectors;
my $actions = (require ::('CSS::Module::CSS3::Selectors::Actions')).new: :xml;
use CSS::Module::CSS3::Selectors;
# tests from https://www.w3.org/TR/selectors-3/#specificity
for (
    '*'              => v0.0.0,  # a=0 b=0 c=0 -> specificity =   0
    'LI'             => v0.0.1,  # a=0 b=0 c=1 -> specificity =   1
    'UL LI'          => v0.0.2,  # a=0 b=0 c=2 -> specificity =   2
    'UL OL+LI'       => v0.0.3,  # a=0 b=0 c=3 -> specificity =   3
    'H1 + *[REL=up]' => v0.1.1,  # a=0 b=1 c=1 -> specificity =  11
    'UL OL LI.red'   => v0.1.3,  # a=0 b=1 c=3 -> specificity =  13
    'LI.red.level'   => v0.2.1,  # a=0 b=2 c=1 -> specificity =  21
    '#x34y'          => v1.0.0,  # a=1 b=0 c=0 -> specificity = 100
    '#s12:not(FOO)'  => v1.0.1,  # a=1 b=0 c=1 -> specificity = 101
) {
    my Str $css = .key;
    my Version $specificity = .value;
    if CSS::Module::CSS3::Selectors.parse($css, :rule<selectors>, :$actions) {
        my %ast = $/.ast;
        my CSS::Selectors $selectors .= new: :%ast;
        is $selectors.specificity, $specificity, "specificity of: $css ($specificity)"; 
    }
    else {
        flunk "unable to parse CSS selector: $css";
    }
}

done-testing();
