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

# some practical tests that we're applying specificity properly

my $string = q:to<END>;
<!DOCTYPE html>
<html>
  <head>
    <style>
      h1 {color: blue;}
      .c2 {color: purple }
      h1.c2 {color: green;}
      #id3 {color: red;}
      #id4 {color: red;}
      .c4  {color: pink !important}
      body h2 {color: yellow !important}
      body h4 {color: pink}
      .c5 {color:red}
      .c5 {color:blue}
    </style>
  </head>

  <body style="color:purple">
    <h1 class="c1">H1[1] (blue)</h1>
    <h1 class="c2">H1[2] (green)</h1>
    <h1 id="id3" class="c3">H1[3] (red)</h1>
    <h1 id="id4" class="c4">H1[4] (pink)</h1>
    <h1 class="c4" style="color:purple">H1[5] (pink)</h1>
    <h1 class="c4" style="color:purple !important">H1[6] (purple)</h1>
    <h1 class="c5">H1[7] (blue)</h1>
    <h2>H2 (yellow)</h2>
    <h3>H3 (purple)</h3>
    <span> <h3>H3 spanned (purple)</h3> </span>
    <h4>H4 (pink)</h4>
    <span style="color:red !important; font-size:18pt"><span style="color:blue">Blue 18pt</span></span>
  </body>

</html>
END

use LibXML;
use LibXML::Document;
use CSS;
use CSS::TagSet::XHTML;
use CSS::Properties;
use Method::Also;

my LibXML::Document $doc .= parse: :$string, :html;
my CSS $css .= new: :$doc, :inherit, :!tags;

like $css.style('/html/body/h1[1]'), /'color:blue;'/;
like $css.style('/html/body/h1[2]'), /'color:green;'/;
like $css.style('/html/body/h1[3]'), /'color:red;'/;
like $css.style('/html/body/h1[4]'), /'color:pink;'/;
like $css.style('/html/body/h1[5]'), /'color:pink;'/;
like $css.style('/html/body/h1[6]'), /'color:purple!important;'/;
like $css.style('/html/body/h1[7]'), /'color:blue;'/;
like $css.style('/html/body/h2'), /'color:yellow;'/;
like $css.style('/html/body/h3'), /'color:purple;'/;
like $css.style('/html/body/span/h3'), /'color:purple;'/;
like $css.style('/html/body/h4'), /'color:pink;'/;
like $css.style('/html/body/span/span'), /'color:blue; font-size:18pt;'/;
like $css.style('/html/body/span[2]'), /'color:red!important; font-size:18pt;'/;

done-testing();
