# Wolf to Jekyll: Convert a Wolfram Language notebook to a Jekyll markdown file

The `jekyllwolf.sh` script converts a Wolfram Language notebook to a Jekyll markdown file.

## Basic usage

```
nb_to_static_site.sh nb_file jekyll_dir [device_width] [post_title]
```

Call the script with:

- the file name of the Wolfram Language notebook
- the directory of the Jekyll site
- (optional) the device width
- (optional) the title of the Jekyll post

## Quick Example

Call the `jekyllwolf.sh` script with the path to the Wolfram Language notebook file, the path to the Jekyll site, and (optionally) the width of the images to generate in pixels:

```
[rule146@rule146: babynames-blog]$ jekyllwolf.sh /path/to/notebook/example-notebook-file.nb /path/to/jekyll/site/ 600
```

The script returns the full path to the generated markdown file, in the `_posts` directory of the Jekyll layout:

```
/path/to/jekyll/site/_posts/2017-01-15-example-notebook-file.md
```

As a side-effect, the script puts any image assets from the notebook conversion into the Jekyll layout under an `assets` directory:

```
$ cd /path/to/jekyll/site
$ tree assets
assets
└── 2017
    └── 01
        └── 15
            └── example-notebook-file-600px
                ├── HTMLFiles
                │   ├── example-notebook-file_1.gif
                │   ├── example-notebook-file_2.gif
                │   ├── example-notebook-file_3.gif
                │   └── example-notebook-file_4.gif
                ├── HTMLLinks
                ├── example-notebook-file.html
                └── example-notebook-file.md
```


## Pre-requisites

The pre-requisites to run `jekyllwolf.sh` are:

- [WolframScript](http://reference.wolfram.com/language/ref/program/wolframscript.html) interpreter
- [pandoc](http://pandoc.org/) document converter
- [Jekyll](https://jekyllrb.com/) static site generator

## Supported platforms

So far this has only been tested on OS X 10.11 (El Capitan).

## Notebook conversion steps

The conversion proceeds in several steps:

1. use `WolframScript` to export the notebook to HTML
2. use `pandoc` to convert the HTML to (Github-flavored) markdown
3. use `sed` to tweak the markdown into a properly formatted Jekyll post
4. use `Jekyll` to compile the markdown post to a static site

Note the conversion script adds some yaml front-matter to the Jekyll markdown post:

- gif: an image file selected automatically from the notebook's html export
- date: the current date
- title: post title
- layout: assumed to be called "post" (see `example-blog` directory and examples in this README)

## Usage

Run `nb_to_static_site.sh` with no args to see the script usage message:

```
[rule146@rule146: babynames-blog]$ nb_to_static_site.sh
usage: nb_to_static_site.sh nb_file jekyll_dir [device_width] [post_title]
nb_file: wolfram notebook file
jekyll_dir: directory of the Jekyll site
device_width (optional): image width for the exported image files (default: 600 px)
post_title (optional): title of the Jekyll post (default: notebook file name)
```

## Example: export a single notebook to an existing Jekyll site

Clone this repo:

```
[rule146@rule146: code]$ git clone git@github.com:paul-jean/jekyllwolf.git
```

Open the example notebook to see how it looks:

![example](assets/example-notebook.png)

Copy the example Jekyll blog to a location of your choice:

```
[rule146@rule146: code]$ cp -R jekyllwolf/example-blog/ ./example-blog
```

Call `jekyllwolf.sh` with the full path the notebook, the path of the Jekyll site, the device width, and the post title:

```
[rule146@rule146: jekyllwolf]$ ./jekyllwolf.sh /Users/rule146/code/jekyllwolf/eg-notebook.nb /Users/rule146/code/example-blog/ 600 "An example notebook"
```

Change directory to the Jekyll blog and see that the assets were added in a directory structure reflecting the current date, the notebook file name, and the screen width:

```
[rule146@rule146: example-blog]$ cd ../example-blog/
[rule146@rule146: example-blog]$ tree assets
assets
└── 2017
    └── 01
        └── 15
            └── eg-notebook-600px
                ├── HTMLFiles
                │   ├── eg-notebook_1.gif
                │   ├── eg-notebook_2.gif
                │   ├── eg-notebook_3.gif
                │   └── eg-notebook_4.gif
                ├── HTMLLinks
                ├── eg-notebook.html
                └── eg-notebook.md
```

The markdown file is located in the `_posts` directory with the filename format required by Jekyll:

```
[rule146@rule146: example-blog]$ tree _posts/
_posts/
└── 2017-01-15-eg-notebook.md

```


Build and serve the Jekyll site:

```
[rule146@rule146: example-blog]$ jekyll build
[rule146@rule146: example-blog]$ jekyll serve
```

Open the Jekyll post on `http://127.0.0.1:4000/2017/01/15/eg-notebook.html`:

![example](assets/jekyll-example-post.png)

And notice it reproduces the example notebook as a Jekyll post!

## Example: export several notebooks to a new Jekyll site

There is a series of example notebooks given in the `example-notebooks` directory:

![example notebook series](assets/example-notebook-series.png)

Copy the example Jekyll layout provided in the `example-blog` directory to a new directory:

```
[rule146@rule146: code]$ cp -R jekyllwolf/example-blog ./w2j-example
```

List the notebooks in the `example-notebooks` directory and export them all to the new Jekyll layout:

```
[rule146@rule146: code]$ find ~/code/jekyllwolf/example-notebooks -name "*.nb" -exec ~/code/jekyllwolf/jekyllwolf.sh {} ./w2j-example 450 \;
./w2j-example/_posts/2017-01-15-rule-22-random-init-density.md
./w2j-example/_posts/2017-01-15-rule-22-random-init.md
./w2j-example/_posts/2017-01-15-rule-22-simple-init.md
```

Build and serve the new jekyll site:

```
[rule146@rule146: code]$ cd w2j-example
[rule146@rule146: w2j-example]$ jekyll build
...
[rule146@rule146: w2j-example]$ jekyll serve
...
    Server address: http://127.0.0.1:4000/
```

Browse to [http://127.0.0.1:4000/]() where each of the example notebooks have been exported as individual posts:

![example exported notebooks](assets/example-notebook-series-exported.png)

Clicking on one of the posts takes you to that exported notebook:

![example exported notebooks](assets/example-notebook-series-post.png)


