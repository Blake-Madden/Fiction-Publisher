## Metadata Options

The following can be specified in a book project's "config.yml" file (which should be in the root of the book project's folder)

### Title & Author

- **title**: Title of your book
- **title-latex**: Latex formatted title (will override "title" value on the title and half-title pages of PDF output)
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
