#!/bin/bash

extension="${1##*.}"
filename="${1%.*}"

noheaderfile=$filename"_no_header.$extension"
shuffledfile=$filename"_shuffled.$extension"

header=$(head -n 1 $1)

echo Removing Header
sed '1d' $1 > $noheaderfile

echo Shuffling Data in $noheaderfile to $shuffledfile
shuf $noheaderfile > $shuffledfile

line_count=$(wc -l $1 | awk '{print $1}')
let holdout_count=$line_count/5
let traineval_count=$line_count-$holdout_count
let eval_count=$traineval_count/5
let train_count=$traineval_count-$eval_count

echo Total Records: $line_count
echo Holdouts: $holdout_count
echo Training: $train_count
echo Eval:     $eval_count

holdout_filename=$filename"_holdout.$extension"
traineval_filename=$filename"_traineval.$extension"
train_filename=$filename"_train.$extension"
eval_filename=$filename"_eval.$extension"

echo Taking $holdout_count records from start of $1 for $holdout_filename
head -n $holdout_count $shuffledfile > $holdout_filename

echo Taking $traineval_count records from end of $1 for $traineval_filename
tail -n $traineval_count $shuffledfile > $traineval_filename

echo Taking $train_count records from end of $traineval_filename for $train_filename
tail -n $train_count $traineval_filename > $train_filename

echo Taking $eval_count records from start of $traineval_filename for $eval_filename
head -n $eval_count $traineval_filename > $eval_filename

echo Adding header back to split files
sed -i "1i $header" $holdout_filename
sed -i "1i $header" $train_filename
sed -i "1i $header" $eval_filename

