if [ -z $TMPDIR ]; then
	TMPDIR="/tmp"
fi

hfst-fst2strings ../.deps/quz.LR-debug.hfst | grep -v -e '<lpar>' -e '<rpar>' | sort -u |  sed 's/:/%/g' | cut -f1 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
        apertium-pretransfer|\
	lt-proc -b ../quz-spa.autobil.bin | tee $TMPDIR/tmp_testvoc2.txt |\
        apertium-transfer -b ../apertium-quz-spa.quz-spa.t1x  ../quz-spa.t1x.bin |\
        apertium-interchunk ../apertium-quz-spa.quz-spa.t2x  ../quz-spa.t2x.bin |\
        apertium-postchunk ../apertium-quz-spa.quz-spa.t3x  ../quz-spa.t3x.bin | tee $TMPDIR/tmp_testvoc3.txt |\
        lt-proc -d ../quz-spa.autogen.bin > $TMPDIR/tmp_testvoc4.txt
paste -d _ $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc3.txt $TMPDIR/tmp_testvoc4.txt | sed 's/\^.<sent>\$//g' | sed 's/\^.<sent>\/.<sent>\$//g' | sed 's/_/   --------->  /g'
