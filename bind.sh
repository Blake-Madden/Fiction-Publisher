#!/bin/bash

# Build your books
bundle exec jekyll build

# Rename files from .html to .md so Pandoc can parse them correctly
for f in _site/*.html; do
  mv -- "$f" "${f%.html}.md"
done


# Create epub for every book in _site
# "${i%%.*}" gets the filename but ignores the extension
for i in $(ls _site -I *Amazon*); do
    mkdir Books/"${i%%.*}"
    pandoc --toc-depth=1 --template=Pandoc/templates/custom-epub.html --epub-stylesheet=Pandoc/css/style.css --epub-cover-image=Source/_images/"${i%%.*}"-Cover.jpg -o Books/"${i%%.*}"/"${i%%.*}".epub _site/$i
done

# Create mobi for every book in _site
for i in $(ls _site | grep Amazon); do
    pandoc --toc-depth=1 --template=Pandoc/templates/amazon-epub.html --epub-stylesheet=Pandoc/css/style.css --epub-cover-image=Source/_images/"${i%-Amazon.md}"-Cover.jpg -o Books/"${i%-Amazon.md}"/"${i%%.*}".epub _site/$i
    
    kindlegen -c2 Books/"${i%-Amazon.md}"/"${i%%.*}".epub
    rm Books/"${i%-Amazon.md}"/"${i%%.*}".epub
    
done

# Create PDF for every book in _site
# "${i%%.*}" gets the filename but ignores the extension
for i in $(ls _site -I *Amazon*); do
    pandoc --toc --toc-depth=1 --latex-engine=xelatex -V documentclass=report -o Books/"${i%%.*}"/"${i%%.*}".pdf _site/$i
done
