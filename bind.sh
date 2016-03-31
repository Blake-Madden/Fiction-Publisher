#!/bin/bash

jekyll() {
# Build your books
bundle exec jekyll build
}

rename() {
# Rename files from .html to .md so Pandoc can parse them correctly
for f in _site/*.html; do
  mv -- "$f" "${f%.html}.md"
done
}

epub() {
jekyll
rename
# Create Default epub for every book in _site
# "${i%%.*}" gets the filename but ignores the extension
for i in $(ls _site | grep epub); do
    mkdir Books/"${i%%-epub.md}"
    pandoc --toc-depth=1 --template=Pandoc/templates/custom-epub.html --epub-stylesheet=Pandoc/css/style.css --smart -o Books/"${i%%-epub.md}"/"${i%%.*}".epub _site/$i
done
}

smashwords() {
jekyll
rename
# Create Smashwords epub
for i in $(ls _site | grep Smashwords); do
    pandoc --toc-depth=1 --template=Pandoc/templates/smashwords-epub.html --epub-stylesheet=Pandoc/css/style.css --smart -o Books/"${i%-Smashwords.md}"/"${i%%.*}".epub _site/$i
done

}

amazon() {
jekyll
rename
# Create mobi for every book in _site
for i in $(ls _site | grep Amazon); do
    pandoc --toc-depth=1 --template=Pandoc/templates/amazon-epub.html --epub-stylesheet=Pandoc/css/style.css --smart -o Books/"${i%-Amazon.md}"/"${i%%.*}".epub _site/$i
    
    kindlegen -c2 Books/"${i%-Amazon.md}"/"${i%%.*}".epub
    rm Books/"${i%-Amazon.md}"/"${i%%.*}".epub
    
done
}

pdf() {
jekyll
rename
# Create PDF for every book in _site
# "${i%%.*}" gets the filename but ignores the extension
for i in $(ls _site | grep pdf ); do
    pandoc --toc --toc-depth=2 --template=Pandoc/templates/custom-pdf.latex --latex-engine=xelatex -V documentclass=book -o Books/"${i%%-pdf.md}"/"${i%%.*}".pdf _site/$i
done
}

all() {
jekyll
rename
epub
smashwords
amazon
pdf
}

$1
