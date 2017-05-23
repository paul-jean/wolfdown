# WolfDown: Convert a Wolfram Language notebook to a Jekyll markdown file

The `wolfdown.sh` script converts a Wolfram Language notebook to a Jekyll markdown file.

## Example: export a single notebook to an existing Jekyll site

Clone this repo:

```
[rule146@rule146: code]$ git clone git@github.com:paul-jean/wolfdown.git
```

Open one of the example notebooks using Mathematica to see how it looks:

![example](assets/example-notebook.png)

Copy the `example-blog` directory, which contains a working jekyll site layout:

```
[rule146@rule146: wolfdown]$ cp -R example-blog export-test
[rule146@rule146: wolfdown]$ lt export-test/
total 32
-rw-r--r--   1 rule146  staff   699B Feb 12 00:12 index.html
-rw-r--r--   1 rule146  staff   1.3K Feb 12 00:12 feed.xml
drwxr-xr-x   5 rule146  staff   170B Feb 12 00:12 css/
-rw-r--r--   1 rule146  staff   536B Feb 12 00:12 about.md
drwxr-xr-x   6 rule146  staff   204B Feb 12 00:12 _sass/
drwxr-xr-x   5 rule146  staff   170B Feb 12 00:12 _layouts/
drwxr-xr-x  10 rule146  staff   340B Feb 12 00:12 _includes/
-rw-r--r--   1 rule146  staff   732B Feb 12 00:12 _config.yml
drwxr-xr-x   3 rule146  staff   102B Feb 12 00:12 assets/
drwxr-xr-x   8 rule146  staff   272B Feb 12 00:12 _site/
drwxr-xr-x   7 rule146  staff   238B Feb 12 00:24 _posts/
```

Now export one of the example notebooks in the `example-notebooks` directory (note the script requires full paths to be given for the notebook file and the jekyll directory). Call the `wolfdown.sh` script with the path to the Wolfram Language notebook
file, the path to the Jekyll site, and (optionally) the width of the images to
generate in pixels:

```
[rule146@rule146: wolfdown]$ ./wolfdown.sh /Users/rule146/code/wolfdown/example-notebooks/eg-notebook.nb /Users/rule146/code/wolfdown/export-test/ 500
/Users/rule146/code/wolfdown/export-test/_posts/2017-02-12-eg-notebook.md
```

The script returns the full path to the generated markdown file, in the
`_posts` directory of the Jekyll layout.

The script puts any image assets from the notebook
conversion into the Jekyll layout under an `assets` directory:

```
[rule146@rule146: wolfdown]$ tree export-test/assets/
export-test/assets/
└── 2017
    └── 02
        └── 12
            ├── eg-notebook-500px
            │   ├── eg-notebook_4.gif
            │   ├── eg-notebook_5.gif
            │   ├── eg-notebook_7.gif
            │   └── eg-notebook_8.gif
```


Build and serve the jekyll site:

```
[rule146@rule146: wolfdown]$ cd export-test/
[rule146@rule146: export-test]$ jekyll serve
Configuration file: /Users/rule146/code/wolfdown/export-test/_config.yml
Configuration file: /Users/rule146/code/wolfdown/export-test/_config.yml
            Source: /Users/rule146/code/wolfdown/export-test
       Destination: /Users/rule146/code/wolfdown/export-test/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
                    done in 0.214 seconds.
 Auto-regeneration: enabled for '/Users/rule146/code/wolfdown/export-test'
Configuration file: /Users/rule146/code/wolfdown/export-test/_config.yml
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```

Browse to [http://127.0.0.1:4000/]() and click on the post:

![example](assets/jekyll-example-post.png)

It should hopefully look like a reasonable rendition of the notebook.


## Usage

```
wolfdown.sh nb_file jekyll_dir [device_width] [post_title]
```

Call the script with:

- the file name of the Wolfram Language notebook
- the directory of the Jekyll site
- (optional) the device width
- (optional) the title of the Jekyll post

Run `wolfdown.sh` with no args to see the script usage message:

```
$ wolfdown.sh
usage: wolfdown.sh nb_file jekyll_dir [device_width] [post_title]
nb_file: wolfram notebook file
jekyll_dir: directory of the Jekyll site
device_width (optional): image width for the exported image files (default: 600 px)
post_title (optional): title of the Jekyll post (default: notebook file name)
```


## Pre-requisites

The pre-requisites to run `wolfdown.sh` are:

- [WolframScript](http://reference.wolfram.com/language/ref/program/wolframscript.html) interpreter
- [Jekyll](https://jekyllrb.com/) static site generator

## Supported platforms

So far this has only been tested on OS X 10.11 (El Capitan), using Wolfram Language 11.0.1 for Mac OS X x86 (64-bit).

## Notebook conversion steps

The conversion proceeds in several steps:

1. use `WolframScript` to export the notebook to HTML
2. use `Jekyll` to compile the markdown post to a static site

Note the conversion script adds some yaml front-matter to the Jekyll markdown post:

- gif: an image file selected automatically from the notebook's html export
- date: the current date
- title: post title
- layout: assumed to be called "post" (see `example-blog` directory and examples in this README)


## Run tests 

Clone this repo:

```
[rule146@rule146: code]$ git clone git@github.com:paul-jean/wolfdown.git
```

There is a series of example notebooks given in the `example-notebooks` directory:

![example notebook series](assets/example-notebook-series.png)


Run the test export script, which creates a test jekyll blog in the repo:

```
[rule146@rule146: wolfdown]$ ./test-export.sh
creating test blog under export-test ...
exporting example-notebooks/eg-notebook.nb ...
/Users/rule146/code/wolfdown/export-test/_posts/2017-02-12-eg-notebook.md
exporting example-notebooks/rule-22-random-init-density.nb ...
/Users/rule146/code/wolfdown/export-test/_posts/2017-02-12-rule-22-random-init-density.md
exporting example-notebooks/rule-22-random-init.nb ...
/Users/rule146/code/wolfdown/export-test/_posts/2017-02-12-rule-22-random-init.md
exporting example-notebooks/rule-22-simple-init.nb ...
/Users/rule146/code/wolfdown/export-test/_posts/2017-02-12-rule-22-simple-init.md
building the jekyll site ...
```

Browse to [http://127.0.0.1:4000/]() where each of the example notebooks have been exported as individual posts:

![example exported notebooks](assets/example-notebook-series-exported.png)
