#!/bin/bash

config=$1
stem=$2
lang=$3
outputfile=$4

file=`basename $stem`

. $config

if [ -f $tagger/stanford-postagger.sh ]; then
  echo Using the Stanford Tagger
  model=
  case "$lang" in
    en) model=$tagger/models/wsj-0-18-left3words-nodistsim.tagger
    ;;
    fr) model=$tagger/models/french.tagger
    ;;
    de) model=$tagger/models/german-fast.tagger
    ;;
    es) model=$tagger/models/spanish.tagger
    ;;
  esac

  if [ "$lang" != "de" ]; then
    $ROOT/scripts/run-in-parallel.sh "$tagger/stanford-postagger.sh $model" $stem.$lang $outputfile.0 $pos_jobs $working/$id/step-2/tagged/tmp/$file.$lang/ $ROOT
  else
    # need to change file encoding to avoid some issue
    iconv -c -f utf-8 -t ISO-8859-1 $stem.de | sed "s=^ *$=ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ=g" > $working/$id/step-2/$file.de.iso
    $ROOT/scripts/run-in-parallel.sh "$tagger/stanford-postagger.sh $model" $working/$id/step-2/$file.de.iso $outputfile.0 $pos_jobs $working/$id/step-2/tagged/tmp/$file.$lang/ $ROOT
  fi

  cat $outputfile.0 | ./scripts/extract-tags.py > $outputfile

  exit
fi

if [ -f $tagger/bin/tree-tagger ]; then
  echo Using the tree-tagger
  $ROOT/scripts/run-in-parallel.sh "$ROOT/scripts/tree-tag.sh $config $lang" $stem.$lang $outputfile $pos_jobs $working/$id/step-2/tagged/tmp/$file.$lang/ $ROOT
fi
