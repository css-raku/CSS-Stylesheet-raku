use v6;
use Test;
plan 22;
use CSS::Media;
use CSS::Units :dpi, :px;

my CSS::Media $media .= new: :type<screen>, :width(640px), :height(480px), :resolution(60dpi), :color;

is $media.type, 'screen', 'media.type';
is $media.width, 640px, 'media.width';
is $media.height, 480px, 'media.height';
is $media.resolution, 60dpi, 'media.resolution';
is $media.device-width, 640px, 'media.device-width';
is $media.device-height, 480px, 'media.device-height';
is $media.orientation, 'landscape', 'media.orientation';

ok $media.query('all');
ok $media.query('screen');
nok $media.query('print');
ok $media.query('not print');
ok $media.query('screen, print');
ok $media.query('print, screen');
nok $media.query('print, tty');

ok $media.query('screen and (max-width: 900px)');
nok $media.query('screen and (max-width: 600px)');

ok $media.query('screen and (orientation: landscape)'); 
nok $media.query('screen and (orientation: portrait)');

ok $media.query('screen and (color)');

ok $media.query('screen and (orientation: landscape) and (max-width: 900px)');
nok $media.query('screen and (orientation: landscape) and (max-width: 600px)');
nok $media.query('screen and (orientation: portrait) and (max-width: 900px)');

done-testing();
