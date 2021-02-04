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
  - [X] Or you can select styles from the [fncychap](https://www.ctan.org/pkg/fncychap) LaTeX package
- [X] Drop cap styles (PDF only, epub uses a simple default format)
  - [X] `default` (same font as the body text)
  - [X] `romance`
  - [X] `blockletter`
  - [X] `none`
- [X] Half-title page template (PDF only)
- [X] Series page template
- [X] Colophon page template (PDF only, details typesetting information)
- [X] Author biography page template

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
- [X] Checks for possesive suffixes being italicized
- [X] Checks for stray periods or commas around '?' or '!'

## Metadata Options

The following can be specified in a book project's "config.yml" file (which should be in the root of the book project's folder)

### Title & Author

- **title**: Title of your book
- **title-latex**: Latex formatted title (will override "title" value on the title and half-title pages of PDF output)
  - A `raggedrighttitle` environment is available for multiline titles to make them ragged right. It takes a parameter specifying the width of the left and right margins.
- **subtitle**: Optional subtitle
- **subtitle-latex**: LaTeX formatted subtitle (will override "subtitle" value on the title page of PDF output)
- **author**: Author name
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

- **cover-image**: The path (relative to **Build.ps1**) to the EPUB cover image

### Copyright Page

- **copyright-page**: Which copyright page template to use. Templates to select from are available in the **Pandoc\templates\copyright** folder (e.g., `creative-commons` and `commercial`)

- **contributors**:
    - **designer**: Who designed your book/cover
    - **artist**: Who created the art of your book cover
    - **editor**: Who edited your book
    
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

- **book1**: 
    - **title**: Optional books to include on the title page
- **book2**:
    - **title**: Add a second book
- **book3**:
    - **title**: Third book
- **book4**:
    - **title**: Fourth book
- **book5**:
    - **title**: Fifth book
- **series-header**: Header that should appear on the series title page (default is "Also Available")

### Colophon

- **colophon**: Whether to include a colophon page (detailing typesetting information) in the print output

### Author Bio
- author-bio: Author biography

### Page Formatting
- **paperheight**: The height of the paper for print output (the default papersize is 6x9 inches)
- **paperwidth**: The width of the paper for print output
- **top-margin**: The top margin in the print output (headers will be inside of the text body)
- **bottom-margin**: The bottom margin in the print output
- **inner-margin**: The inner/gutter margin in the print output
- **outer-margin**: The outer margin in the print output

- **fancy-chapter**: Chapter heading style from the [fncychap](https://www.ctan.org/pkg/fncychap) library (PDF output only). Styles include `Sonny`, `Lenny`, `Glenn`, `Conny`, `Rejne`, `Bjarne`, and `Bjornstrup`
- **chapter-heading**: The name of the custom chapter heading theme to use (`default`, `romance-calligraphy`, `romance-cursive` are available). Note that using **fancy-chapter** will override this

- **drop-cap-style**: The drop cap style to use for first letter at the start of each chapter (`default`, `romance`, `blockletter`, `none`)

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
