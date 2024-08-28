DocProj=css-raku.github.io
DocRepo=https://github.com/css-raku/$(DocProj)
DocLinker=../$(DocProj)/etc/resolve-links.raku

all : doc

test : all
	@prove -e"raku -I ." t

loudtest : all
	@prove -e"raku -I ." -v t

$(DocLinker) :
	(cd .. && git clone $(DocRepo) $(DocProj))

Pod-To-Markdown-installed :
	@raku -M Pod::To::Markdown -c

doc : $(DocLinker) Pod-To-Markdown-installed docs/index.md docs/CSS/Stylesheet.md docs/CSS/Ruleset.md docs/CSS/AtPageRule.md docs/CSS/MediaQuery.md docs/CSS/Media.md docs/CSS/Selectors.md 

docs/index.md : README.md
	cp $< $@

docs/%.md : lib/%.rakumod
	@raku -I . -c $<
	raku -I . --doc=Markdown $< \
	| TRAIL=$* raku -p -n $(DocLinker) \
         > $@

