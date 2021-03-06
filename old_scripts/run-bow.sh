#!/bin/bash

config=$1
dict=$2
source=$3
target=$4

file=`basename $dict`

. $config

mkdir -p $working/$id/iter-$iter/step-3/bow

cat $dict | awk -v thresh=$bow_thresh '$3>thresh{print}' > $working/$id/iter-$iter/step-3/bow/$file.short

#~/data_selection/tools/bow-translation $dict.short source

cat $source | $ROOT/tools/bow-translation $working/$id/iter-$iter/step-3/bow/$file.short - | python $ROOT/scripts/unigram-similarity-soft.py - $target 2>/dev/null

