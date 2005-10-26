#!/bin/sh
for i in *.dot.txt
do
	echo $i
	j=${i%.dot.txt}
	# can't use neato -s -n2 because it does strange things to 
	# the records in datastruct.dot
	dot -Tpng -Gsize="7,7" $i -o $j.png
	convert -resize 160x160 $j.png $j.small.png
	# dot -Tpng -Gsize="1.75,1.75" $i -o $j.small.png
	dot -Tsvg $i -o $j.svg
done
