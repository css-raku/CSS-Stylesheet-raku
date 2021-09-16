use v6;
use Test;
plan 1;
use CSS::Stylesheet;
use CSS::Media;
use CSS::Units :px;

my $css = q:to<END>;
    @media not print {
      h1 {
        color: blue;
      }
      @media (min-width: 0) {
        p {
          font-weight: bold;
        }
        @media (max-width: 750px) {
          p {
            background: yellow;
          }
        }
      }
    }
    END

my CSS::Stylesheet $stylesheet-plain .= parse($css);
my CSS::Media $media .= new: :type<screen>, :width(1024px), :height(840px);

is-deeply $stylesheet-plain.Str(:pretty).lines, $css.lines;