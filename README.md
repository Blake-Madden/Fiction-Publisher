## Table of Contents

- [What is Fiction Publisher](#what-is-fiction-publisher)
- [Features](#features)
- [Building your Books](#building-your-books)
- [Metadata Options](#metadata-options)
- [Requirements](#requirements)


## What is Fiction Publisher
**Fiction Publisher** is a fork of [Open Publisher](https://github.com/chrisanthropic/Open-Publisher), redesigned to work with [Manuskript](https://github.com/olivierkes/manuskript) and [Bookdown](https://bookdown.org/) projects. It is a [PowerShell](https://github.com/PowerShell/PowerShell) script that wraps [Pandoc](https://github.com/jgm/pandoc), KindleGen, and LaTeX and uses a set of custom Pandoc templates (created with a focus on fiction).

Write your manuscript in markdown, configure a Pandoc [metadata](#Metadata-Options) file, run a build script, and receive some beautifully formatted ePub, Mobi, and print-ready PDF books.

Full documentation on the [wiki](https://github.com/Blake-Madden/Fiction-Publisher/wiki).

Refer [here](https://github.com/Blake-Madden/Fiction-Publisher/wiki/Project-Structure) for the recommended file structure for your book.

## Features

#### PowerShell build script which creates
  - [X] PDF (print)
  - [X] ePub
  - [X] Mobi
  - [X] Word (using a **Draft** template)

#### Input formats
- [X] Supports Markdown files within [Manuskript](https://github.com/olivierkes/manuskript) folder structure

#### Configurable components for output (PDF and epub)
- [X] Copyright page templates
  - [X] `creative-commons`
  - [X] `commercial`
- [X] Impression lines
- [X] Chapter heading templates (PDF only)
  - [X] `default`
  - [X] `romance-calligraphy`
  - [X] `romance-cursive`
  - [X] `scifi`
  - [X] Or you can select styles from the [fncychap](https://www.ctan.org/pkg/fncychap) LaTeX package
- [X] Drop cap styles (PDF only, epub uses a simple default format)
  - [X] `default` (same font as the body text)
  - [X] `romance`
  - [X] `blockletter`
  - [X] `scifi`
  - [X] `none`
- [X] Half-title page template (PDF only)
- [X] Series page template
- [X] Colophon page template (PDF only, details typesetting information)
- [X] Author biography page template
- [X] Customizable fonts for author name and title

#### Adds formatting to output (PDF and epub)
- [X] Adds header to start of chapters if missing (based on parent folder name)
- [X] Formats start of chapter with drop cap and small caps
- [X] Can convert `***` separators between scene breaks/POV changes with custom code (e.g., fleurons)
- [X] Unindents starting paragraph of new scenes/POV changes
- [X] Formats start of chapter with drop cap and smart caps
- [X] Supports [CriticMarkup](https://github.com/CriticMarkup/CriticMarkup-toolkit) syntax

#### Validation features
- [X] Checks for paragraphs not separated by blank lines (this is recommended over ending lines with double spaces because it makes the intention clearer and avoids possible errors)
- [X] Checks for straight quotes (smart quotes should be included in source markdown to avoid ambiguity)
- [X] Checks for `--` (en dashes and em dashes should be included in source markdown to avoid ambiguity)
- [X] Checks for correct ordering of closing quotation marks and commas/periods
- [X] Checks for Unicode ellipsis (should be spaced periods)
- [X] Checks for en dash at the end of a quote (should be an em dash)
- [X] Checks for hyphen between numbers (should be an en dash)
- [X] Checks for extra spaces
- [X] Checks for indenting spaces (these should not be hardcoded in source markdown files)
- [X] Checks for tabs
- [X] Checks for a line that ends with space(s), followed by single newline (indicates ambiguous intention as to whether this should be a new paragraph [a full blank line is recommended here] or the same paragraph [the newline should be removed])
- [X] Checks for items that should be italicized (items are user-defined in metadata)
- [X] Checks for possessive suffixes being italicized
- [X] Checks for stray periods or commas around '?' or '!'

## Building your Books

### Organize Book Projects
- Create a folder named "Books" In your "Fiction-Publisher" folder.
- Copy your Manuskript project(s) into this folder.
- Add a "config.yml" file to each book project.

### Update Your MetaData
Each book project will contain a "config.yml", which is used to define metadata about your book. Refer to the [Metadata Documentation](#metadata-options) for more information.

### Build Your Books
Use the "Build.ps1" script to create your books, which will appear in the "Output" folder.

## Metadata Options

The following can be specified in a book project's "config.yml" file (which should be in the root of the book project's folder)

### Title & Author

- **title**: Title of your book
- **title-latex**: Latex formatted title (will override "title" value on the title and half-title pages of PDF output)
  - A `raggedrighttitle` environment is available for multi-line titles to make them ragged right. It takes a parameter specifying the width of the left and right margins.
- **title-page-top-margin**: How much space should be above the title on the title page (default is 4cm). This is useful if you are needing to add illustrator information to the title page and need a smaller top margin to make it all fit on one page
- **title-font** : The font for the book title on the title and half-title pages (can be a TTF/OTF filename in the "Pandoc/fonts" folder or font name)
- **title-font-pointsize**: Font size of title in PDF output (default is 50)
- **subtitle**: Optional subtitle
- **subtitle-latex**: LaTeX formatted subtitle (will override "subtitle" value on the title page of PDF output)
- **author**: Author name
- **author-font**: The font for the author's name on the title page (can be a TTF/OTF filename in the "Pandoc/fonts" folder or font name)
- **author-by-header**: The "By" label that appears above the author on the title page (default is blank)
- **email**: Author e-mail
- **website**: Author website

### Book Info

- **type**: Genre of your book
- **lang**: A string value in BCP 47 format: http://tools.ietf.org/html/bcp47 (e.g., en-US)
- **date**: YYYY-MM-DD
- **year**: YYYY

- **identifier**:
  - **scheme**: UUID
  - **text**: A unique UUID for your ebook

### Cover

- **cover-image**: The path (relative to "Build.ps1") to the EPUB cover image

### Copyright Page

- **copyright-page**: Which copyright page template to use. Templates to select from are available in the "Pandoc\templates\copyright" folder (e.g., `creative-commons` and `commercial`)

- **contributors**:
  - **designer**: Who designed your book/cover
  - **cover-artist**: Who created the art of your book cover
  - **editor**: Who edited your book
  - **illustrator**: Who did the interior illustrations (will appear on the title page)

- **publisher**: Publisher of your book
- **publisher-address-latex**: LaTeX-formatted publisher address (used on PDF copyright page)
- **publisher-address-html**: HTML-formatted publisher address (used on ePub copyright page)
- **rights**: A single sentence regarding the licensing of your book

- **paperback-isbn-13**: Optional 13 digit ISBN of your paperback book
- **hardcover-isbn-13**: Optional 13 digit ISBN of your hardcover book
- **epub-isbn-13**: Optional 13 digit ISBN of your epub book
- **paperback-isbn-10**: Optional 10 digit ISBN of your paperback book
- **hardcover-isbn-10**: Optional 10 digit ISBN of your hardcover book
- **epub-isbn-10**: Optional 10 digit ISBN of your epub book
- **first-paperback-date**: Publication date of first paperback edition
- **lcc-info-latex**: LaTeX-formatted Library of Congress Cataloging-in-Publication Data (used on PDF copyright page)
- **lcc-info-html**: HTML-formatted Library of Congress Cataloging-in-Publication Data (used on ePub copyright page)

- **impression-line-years**: The year part of the impression number/printer line (years run right-to-left, and are usually 2-digit)
- **impression-line-printings**: The print-run part of the impression number/printer line (number run left-to-right)

### Dedication Page

- **dedication**: Optional dedication

### Table of Contents

- **toc**: Whether to include a table of contents in the print output (`true` or `false`)
- **toc-title**: The header text for the Table of Contents

### Series Page

- **series-book1**: 
    - **title**: Optional books to include on the title page
    - **title-latex**: LaTeX-formatted title for PDF output (will override **title**)
    - **subtitle**: Subtitle of book
    - **subtitle-latex**: LaTeX-formatted subtitle of book (will override **subtitle**)
- **series-book2**:
    - **title**: Add a second book
- **series-book3**:
    - **title**: Third book
- **series-book4**:
    - **title**: Fourth book
- **series-book5**:
    - **title**: Fifth book
- **series-header**: Header that should appear on the series title page (default is "Also Available")

### Colophon

- **colophon**: Whether to include a colophon page (detailing typesetting information) in the print output

### Author Bio
- **author-bio**: Author biography

### Page Formatting
- **paperheight**: The height of the paper for print output (the default papersize is 6x9 inches)
- **paperwidth**: The width of the paper for print output
- **top-margin**: The top margin in the print output (headers will be inside of the text body)
- **bottom-margin**: The bottom margin in the print output
- **inner-margin**: The inner/gutter margin in the print output
- **outer-margin**: The outer margin in the print output

- **fancy-chapter**: Chapter heading style from the [fncychap](https://www.ctan.org/pkg/fncychap) library (PDF output only). Styles include `Sonny`, `Lenny`, `Glenn`, `Conny`, `Rejne`, `Bjarne`, and `Bjornstrup`
- **chapter-heading**: The name of the custom chapter heading theme to use (`default`, `romance-calligraphy`, `romance-cursive`, `scifi`). Note that using **fancy-chapter** will override this

- **drop-cap-style**: The drop cap style to use for first letter at the start of each chapter (`default`, `romance`, `blockletter`, `scifi` (requires the font file "Orbitron-Bold.ttf"), `none`)

- **scene-separator-latex**: LaTeX code to replace `***` sequences between scenes (used for PDF output)
- **scene-separator-html**: HTML code to replace `***` sequences between scenes (used for ePub output)

- **no-hyphenate-list**: Space-separated list of words that explicitly show how words should be hyphenated when split across lines; useful for listing (non-hyphenated) names of characters whose names should not be split between lines

### Extra

- **header-includes**: Raw content to embed in the template file's header (e.g., LaTeX commands)

### Validation & Testing

- **emphasis-check**: Semicolon-separated list of phrases that should be italicized. If they are not, a warning will be logged
- **copyedit**: Set as `true` to draw an outline around the various sections in the print output and show marginal notes in the print output (useful if using [CriticMarkup](https://github.com/CriticMarkup/CriticMarkup-toolkit))

### Build Options

- **build-draft**: `false` to not build a draft copy (`true` by default)
- **build-epub**: `false` to not build an EPub file (`true` by default)
- **build-mobi**: `false` to not build a Mobi file (`true` by default)
- **build-print**: `false` to not build a PDF file (`true` by default)

# Requirements
Fiction Publisher needs the following tools to be installed in order to work:

## Pandoc
[Pandoc](http://pandoc.org/) - converts _from_ many file formats _to_ many other file formats. For our purposes, it converts our markdown file to epub and pdf.

## Kindlegen
[KindleGen](https://www.amazon.com/gp/feature.html?docId=1000765211) - Amazon's free tool to create .mobi/kindle files. For our purposes, it converts epub to mobi.

## LaTeX / TexLive / MiKTeX
[LaTeX](https://www.latex-project.org/) - typesetting software that can output PDF files.

## Fiction Publisher
Git clone the [Fiction Publisher](https://github.com/Blake-Madden/Fiction-Publisher) repo.

`git clone https://github.com/Blake-Madden/Fiction-Publisher`

