#!/bin/bash

# Build your books
bundle exec jekyll build

# Rename files from .html to .md so Pandoc can parse them correctly
for f in _site/*.html; do
  mv -- "$f" "${f%.html}.md"
done


# Create epub for every book in _site
# "${i%%.*}" gets the filename but ignores the extension
for i in $(ls _site); do
    pandoc --toc-depth=1 --template=Pandoc/templates/custom-epub.html --epub-stylesheet=Pandoc/css/style.css -o Books/"${i%%.*}".epub _site/$i
done

# Create epub for every book in _site
# "${i%%.*}" gets the filename but ignores the extension
for i in $(ls _site); do
    pandoc --toc --toc-depth=1 --latex-engine=xelatex -V documentclass=report -o Books/"${i%%.*}".pdf _site/$i
done
