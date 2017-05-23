#!/bin/sh

dir=`pwd`
test_dir="export-test"

echo "creating test blog under $test_dir ..."
cp -R ./example-blog ./$test_dir

for nb in `ls -1 example-notebooks/*.nb`; do
    echo "exporting $nb ..."
    ./wolfdown.sh $dir/$nb $dir/$test_dir/ 500
done

echo "building the jekyll site ..."
cd $test_dir
jekyll build
jekyll serve

exit 0
