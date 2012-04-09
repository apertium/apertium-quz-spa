
LANG1=quz
BASENAME=apertium-quz-spa
PREFIX1=quz-spa
PREFIX2=spa-quz

all: $(PREFIX1).automorf.hfst $(PREFIX2).autogen.hfst

.deps/$(LANG1).twol.hfst: $(BASENAME).$(LANG1).twol
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-twolc $< -o $@

.deps/$(LANG1).lexc.hfst: $(BASENAME).$(LANG1).lexc
	hfst-lexc --format foma $< -o $@

.deps/$(LANG1).hfst: .deps/$(LANG1).lexc.hfst .deps/$(LANG1).twol.hfst
	hfst-compose-intersect -1 .deps/$(LANG1).lexc.hfst -2 .deps/$(LANG1).twol.hfst -o $@

$(PREFIX2).autogen.hfst: .deps/$(LANG1).hfst
	hfst-fst2fst -O $< -o $@

$(PREFIX1).automorf.hfst: .deps/$(LANG1).hfst
	hfst-invert $< | hfst-fst2fst -O -o $@

