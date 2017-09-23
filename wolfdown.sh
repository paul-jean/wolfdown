#! /bin/sh
# Exports a Wolfram Language notebook (.nb) to a markdown document within a Jekyll site.
# Usage:
# wolfdown.sh nb_file jekyll_dir [device_width] [post_title]

DEFAULT_DEVICE_WIDTH=600

function usage {
    echo "usage: wolfdown.sh nb_file jekyll_dir [device_width] [post_title]"
    echo "nb_file: wolfram notebook file"
    echo "jekyll_dir: directory of the Jekyll site"
    echo "device_width (optional): image width for the exported image files (default: $DEFAULT_DEVICE_WIDTH px)"
    echo "post_title (optional): title of the Jekyll post (default: notebook file name)"
}

# TODO: use switches to parse device width and post title

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

# export the notebook to markdown using the WolframScript interpreter:
md_post_file=`$script_dir/export_nb_to_static_site.wolframscript $nb_file $jekyll_dir $device_width "$post_title"`

# reconstruct the name of the file the wolfram script wrote because it isn't
# getting returned properly
# TODO: figure out how to get the file name returned from the wolfram script
curr_dir=$(pwd)
jekyll_dir_full_path=$(cd "$jekyll_dir"; pwd)
cd $curr_dir
md_base_name="`date +"%Y-%m-%d"`-${nb_basename}.md"
md_file_name="$jekyll_dir_full_path/_posts/${md_base_name}"

# replace some common special characters from the wolfram exporter with ASCII equivalents:
# TODO: look into exporting in wolfram script using CharacterEncoding->ASCII
echo "[wolfdown] Replacing wolfram special chars with ASCII equivalents ..."
sed -i.bak 's@\\\[OpenCurlyQuote\]@'\''@g' "$md_file_name"
sed -i.bak 's@\\\[CloseCurlyQuote\]@'\''@g' "$md_file_name"
sed -i.bak 's@\\\[OpenCurlyDoubleQuote\]@'\"'@g' "$md_file_name"
sed -i.bak 's@\\\[CloseCurlyDoubleQuote\]@'\"'@g' "$md_file_name"
if [ ! -z "${md_file_name}.bak" ]
then
    rm "${md_file_name}.bak"
fi
echo "[wolfdown] Done replacing special chars."

# if no cells were found to export, abort:
if [ "$md_post_file" = "Failed" ]
then
    echo "[wolfdown] No cells were found to export, aborting ..."
    exit 1
fi

echo $md_file_name

exit 0


