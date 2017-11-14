#! /bin/sh -x
# Exports a Wolfram Language notebook (.nb) to a markdown document within a Jekyll site.

DEFAULT_DEVICE_WIDTH=600

function usage {
    echo "usage: wolfdown.sh nb_file [-o jekyll_dir] [-w device_width] [-t post_title]"
    echo "Converts wolfram notebook nb_file to markdown."
    echo "The generated .md file and image asset files are written to the"
    echo "current directory, unless the -o (output directory) option is specified."
    echo "nb_file:         (required) wolfram notebook .nb file"
    echo "-o jekyll_dir:   (Output directory, optional) directory of a Jekyll"
    echo "                 site to write output files to (default: current directory)"
    echo "-w device_width: (device Width, optional) image width for the"
    echo "                 exported image files (default: $DEFAULT_DEVICE_WIDTH px)"
    echo "-t post_title    (post Title, optional): title of the Jekyll post (default: notebook file name)"
    echo "-h               Show this help message and exit."
}

# there should be at least one arg
# wolfdown.sh nb_file -o ~/code/paul-jean.github.io
if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

nb_file="$1"

# use getopts to parse command-line args
OPTIND=2
while getopts ":o:w:t:h" opt; do
    case ${opt} in
    # wolfdown.sh -h
    h )
        usage
        exit 0
        ;;
    # wolfdown.sh nb_file -o ~/code/paul-jean.github.io
    o )
        echo "[debug] processing option -o ..."
        echo "[debug] $OPTARG ..."
        jekyll_dir=$OPTARG ;;
    # wolfdown.sh nb_file -o ~/code/paul-jean.github.io -w 500
    w ) device_width=$OPTARG ;;
    # wolfdown.sh nb_file -o ~/code/paul-jean.github.io -w 500 -t "title"
    t ) post_title=$OPTARG ;;
    : ) echo "[wolfdown] Option -$OPTARG requires an argument." >&2; exit 1 ;;
    # wolfdown.sh nb_file -z invalid_stuff
    \? ) echo "[wolfdown] Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done

shift $(($OPTIND - 1))

script_dir=`dirname $0`
nb_basename=`basename $nb_file .nb`

if [ -z "$jekyll_dir" ]
then
    jekyll_dir=$(pwd)
fi

if [ -z "$device_width" ]
then
    device_width=$DEFAULT_DEVICE_WIDTH
fi

if [ -z "$post_title" ]
then
    post_title=$(echo $nb_basename | sed 's|[_-]| |g')
fi

echo "[wolfdown] jekyll dir set to: $jekyll_dir"

# note: embedding the nb file between optional args like this is not supported:
# wolfdown.sh -o jekyll_dir nb_file -w 500

# export the notebook to markdown using the WolframScript interpreter:
md_post_file=`$script_dir/export_nb_to_static_site.wolframscript $nb_file $jekyll_dir $device_width "$post_title"`

# reconstruct the name of the file the wolfram script wrote because it isn't
# getting returned properly from the wolfram script
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


