=begin pod

=head1 NAME

css-tidy.raku - tidy/optimise and rewrite CSS stylesheets

=head1 SYNOPSIS

 css-tidy.raku infile.css [outfile.css]

 Options:
    --atomize         # break into component properties
    --imports         # include imported styesheets
    --base-url=path   # set base url for imports  
    --pretty          # enable multi-line property lists
    --/warn           # disable warnings
    --color=names     # write color names (if possible)
    --color=masks     # write colors as masks #77F
    --color=values    # write colors as rgb(...) rgba(...)
    --lax             # allow any functions and units
    --module=css1|css21|css3|svg # CSS conformance mode
    --allow=property  # Allow particular properties (repeatable)
    --allow-any       # All any unknown properties
=head1 DESCRIPTION


This script parses and rewrites CSS stylesheets.

=end pod

use CSS::Stylesheet;
use CSS::Module;
use CSS::Module::CSS1;
use CSS::Module::CSS21;
use CSS::Module::CSS3;
use CSS::Module::SVG;

subset ColorOpt of Str where 'masks'|'names'|'values'|Str:U;
subset ModuleOpt of Str:D where .lc ~~ 'css1'|'css21'|'css3'|'svg';

sub MAIN($file = '-',              #= Input CSS Stylesheet path ('-' for stdin)
         $output?,                 #= Processed stylesheet path (stdout)
         Str :$base-url = $file eq '-' ?? './' !! $file;
         Bool :$atomize,           #= Break into component properties
         Bool :$imports = False,   #= Expand imported stylesheets
         Bool :$pretty = False,    #= Multi line property output
         Bool :$warn = True,       #= Output warnings
         :@allow,                  #= Allow particular properties
         Bool :allow-any($vivify), #= Allow any properties              
         Bool :$lax = $vivify || @allow.so,   #= Allow any functions and units
         ColorOpt :$color,         #= Color output mode: 'names', 'masks', or 'values',
         ModuleOpt :module($mod) = 'css3', #= Property set to use CSS3, or SVG
        ) {

    my %opt = :$pretty, :optimize(!$atomize);
    %opt{'color-' ~ $_} = True with $color;

    given ($file eq '-' ?? $*IN !! $file.IO).slurp {
        my %extensions = @allow.map: { $_ => %() };
        my CSS::Module:D $module = ::('CSS::Module')::($mod.uc).module: :%extensions, :$vivify;
        my CSS::Stylesheet $style .= new: :$base-url, :$imports, :$module;
        $style.parse: $_, :$lax, :$warn;
        my $out = $style.Str: |%opt;

        with $output {
            .IO.spurt: $out
        }
        else {
            say $out;
        }
    }
}
