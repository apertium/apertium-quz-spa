LANG1=quz
LANG2=spa
BASENAME=apertium-quz-spa
PREFIX1=quz-spa
PREFIX2=spa-quz

all: $(PREFIX1).automorf.hfst $(PREFIX2).autogen.hfst $(PREFIX1).rlx.bin $(PREFIX1).autobil.bin $(PREFIX1).mode

.deps/$(LANG1).twol.hfst: $(BASENAME).$(LANG1).twol
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-twolc $< -o $@

.deps/$(LANG1).lexc.hfst: $(BASENAME).$(LANG1).lexc
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-lexc --format foma $< -o $@

.deps/$(LANG1).hfst: .deps/$(LANG1).lexc.hfst .deps/$(LANG1).twol.hfst
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-compose-intersect -1 .deps/$(LANG1).lexc.hfst -2 .deps/$(LANG1).twol.hfst -o $@

$(PREFIX2).autogen.hfst: .deps/$(LANG1).hfst
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-fst2fst -O $< -o $@

$(PREFIX1).automorf.hfst: .deps/$(LANG1).hfst
	if [ ! -d .deps ]; then mkdir .deps; fi
	hfst-invert $< | hfst-fst2fst -O -o $@

$(PREFIX1).autobil.bin: $(BASENAME).$(PREFIX1).dix
	apertium-validate-dictionary $<
	lt-comp lr $< $@

$(PREFIX1).rlx.bin: $(BASENAME).$(PREFIX1).rlx
	cg-comp $< $@

$(PREFIX1).mode: modes.xml
	apertium-validate-modes $<
	apertium-gen-modes $<
