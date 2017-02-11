#! /bin/sh -x
# Exports a Wolfram Language notebook (.nb) to a markdown document within a Jekyll site.
# Usage:
# jekyllwolf.sh nb_file jekyll_dir [device_width] [post_title]

DEFAULT_DEVICE_WIDTH=600

function usage {
    echo "usage: jekyllwolf.sh nb_file jekyll_dir [device_width] [post_title]"
    echo "nb_file: wolfram notebook file"
    echo "jekyll_dir: directory of the Jekyll site"
    echo "device_width (optional): image width for the exported image files (default: $DEFAULT_DEVICE_WIDTH px)"
    echo "post_title (optional): title of the Jekyll post (default: notebook file name)"
}

script_dir=`dirname $0`

if [ $# -lt 2 ]
then
    usage
    exit 1
fi

nb_file=$1
jekyll_dir=$2

# if the device width isn't provided, use a default device width
if [ ! -z "$3" ]
then
    device_width=$3
else
    device_width=$DEFAULT_DEVICE_WIDTH
fi

nb_basename=`basename $nb_file .nb`

# if the post title isn't provided, use the notebook file name as the title:
if [ ! -z "$4" ]
then
    post_title=$4
else
    post_title=`echo $nb_basename | sed 's|[_-]| |g'`
fi

# export the notebook to html using the WolframScript interpreter:
ht_file=`$script_dir/export_nb_to_static_site.wolframscript $nb_file $jekyll_dir $device_width "$post_title"`

echo $md_post_file

exit 0


