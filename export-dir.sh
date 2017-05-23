#!/bin/sh
# usage:
# export-dir.sh nb_dir jekyll_dir device_width

nb_dir=$1
jekyll_dir=$2
device_width=$3

for nb in `ls -1 $nb_dir/*.nb`; do
    echo "exporting $nb ..."
    echo "./wolfdown.sh $nb $jekyll_dir $device_width"
    ./wolfdown.sh $nb $jekyll_dir $device_width
done

exit 0
