#!/bin/bash

jekyll() {
# Build your books
bundle exec jekyll build
}

rename() {
# Rename files from .html to .md so Pandoc can parse them correctly
for f in _site/*/*.html; do
  mv -- "$f" "${f%.html}.md"
done
}

epub() {
jekyll
rename
# Create Default epub for every book in _site
# "${i%%.*}" gets the filename but ignores the extension
for i in $(ls _site/*/ | grep epub); do
    mkdir -p Books/"${i%%-epub.md}"
    pandoc --toc-depth=1 --template=Pandoc/templates/custom-epub.html --epub-stylesheet=Pandoc/css/style.css --smart -o Books/"${i%%-epub.md}"/"${i%%-epub.md}".epub _site/*/$i
done
}

smashwords() {
jekyll
rename
# Create Smashwords epub
for i in $(ls _site/*/ | grep Smashwords); do
    mkdir -p Books/"${i%-Smashwords.md}"
    pandoc --toc-depth=1 --template=Pandoc/templates/smashwords-epub.html --epub-stylesheet=Pandoc/css/style.css --smart -o Books/"${i%-Smashwords.md}"/"${i%%.*}".epub _site/*/$i
done

}

amazon() {
jekyll
rename
# Create mobi for every book in _site
for i in $(ls _site/*/ | grep Amazon); do
    mkdir -p Books/"${i%-Amazon.md}"
    pandoc --toc-depth=1 --template=Pandoc/templates/amazon-epub.html --epub-stylesheet=Pandoc/css/style.css --smart -o Books/"${i%-Amazon.md}"/"${i%%.*}".epub _site/*/$i
    
    kindlegen -c2 Books/"${i%-Amazon.md}"/"${i%%.*}".epub
    rm Books/"${i%-Amazon.md}"/"${i%%.*}".epub
    
done
}

print-pdf() {
jekyll
rename

# Create a bio page so we can append it to the end of the main document
pandoc --latex-engine=xelatex -o Books/bio.tex Source/_includes/bio.md

# Create PDF for every book in _site
# "${i%%.*}" gets the filename but ignores the extension
for i in $(ls _site/*/ | grep pdf ); do
    mkdir -p Books/"${i%%-pdf.md}"
    pandoc --template=Pandoc/templates/cs-5x8-pdf.latex --latex-engine=xelatex --latex-engine-opt=-output-driver="xdvipdfmx -V 3 -z 0" -o Books/"${i%%-pdf.md}"/"${i%%-pdf.md}"-print.pdf  -A Books/bio.tex _site/*/$i
done
}

ebook-pdf() {
jekyll
rename
# Create PDF for every book in _site
# "${i%%.*}" gets the filename but ignores the extension
for i in $(ls _site/*/ | grep pdf ); do
    mkdir -p Books/"${i%%-pdf.md}"
    pandoc --template=Pandoc/templates/ebook-pdf.latex --latex-engine=xelatex -o Books/"${i%%-pdf.md}"/"${i%%-pdf.md}"-ebook.pdf _site/*/$i
done
}

all() {
jekyll
rename
epub
smashwords
amazon
print-pdf
ebook-pdf
}

$1
