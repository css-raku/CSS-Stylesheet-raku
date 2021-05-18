[[Raku CSS Project]](https://css-raku.github.io)
 / [[CSS-Stylesheet]](https://css-raku.github.io/CSS-Stylesheet-raku)
 / [CSS::MediaQuery](https://css-raku.github.io/CSS-Stylesheet-raku/CSS/MediaQuery)

class CSS::MediaQuery
---------------------

@media query representation

### method parse

```raku
method parse(
    Str:D $media-query,
    :$module = Code.new,
    |c
) returns CSS::MediaQuery
```

parse a media query

