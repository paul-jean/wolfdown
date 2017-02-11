#!/bin/sh -x

dir=`pwd`
test_dir="export-test"

# create a tests jekyll blog
cp -R ./example-blog ./$test_dir
./jekyllwolf.sh $dir/example-notebooks/eg-notebook.nb $dir/$test_dir/ 400 "An example notebook"

# build and serve the jekyll site
cd $test_dir
jekyll build
jekyll serve

exit 0
