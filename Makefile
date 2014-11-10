#hfst-expand-equivalences -a ...acx -i input.hfst -o output.hfst should work

LANG1=quz
LANG2=spa
BASENAME=apertium-quz-spa
PREFIX1=quz-spa
PREFIX2=spa-quz

all: $(PREFIX1).automorf.hfst $(PREFIX2).autogen.hfst $(PREFIX1).rlx.bin $(PREFIX1).autobil.bin $(PREFIX1).mode \
	$(PREFIX1).t1x.bin $(PREFIX1).t2x.bin $(PREFIX1).t3x.bin $(PREFIX1).autogen.bin $(PREFIX2).automorf.bin \
	$(PREFIX1).autopgen.bin $(PREFIX1).lrx.bin

debug: .deps/$(LANG1).LR-debug.hfst

.deps/$(LANG1).LR-debug.hfst: $(BASENAME).$(LANG1).lexc .deps/$(LANG1).twol.hfst
	if [ ! -d .deps ]; then mkdir .deps; fi
	cat $< | grep -v 'Dir/RL' | grep -v 'Use/Circ' > .deps/$(LANG1).LR-debug.lexc
	hfst-lexc --format foma .deps/$(LANG1).LR-debug.lexc -o .deps/$(LANG1).LR-debug.lexc.hfst
	hfst-compose-intersect -1 .deps/$(LANG1).LR-debug.lexc.hfst -2 .deps/$(LANG1).twol.hfst -o $@

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

$(PREFIX1).t1x.bin: $(BASENAME).$(PREFIX1).t1x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).t2x.bin: $(BASENAME).$(PREFIX1).t2x
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).t3x.bin: $(BASENAME).$(PREFIX1).t3x
	apertium-validate-postchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).autogen.bin: $(BASENAME).$(LANG2).dix
	apertium-validate-dictionary $<
	lt-comp rl $< $@

$(PREFIX2).automorf.bin: $(BASENAME).$(LANG2).dix
	apertium-validate-dictionary $<
	lt-comp lr $< $@

$(PREFIX1).autopgen.bin: $(BASENAME).post-$(LANG2).dix
	apertium-validate-dictionary $<
	lt-comp lr $< $@

$(PREFIX1).lrx.bin: $(BASENAME).$(PREFIX1).lrx
	lrx-comp $< $@

$(PREFIX1).mode: modes.xml
	apertium-validate-modes $<
	apertium-gen-modes $<
	cp *.mode modes/
