## Metadata Options

#### The following can be specified in a book project's "config.yml" file (which should be in the root of the book project's folder)

- **title**: Title of your book
- **title-latex**: Latex formatted title (will override "title" value on the title and half-title pages of PDF output)
- **subtitle**: Optional subtitle
- **subtitle-latex**: Latex formatted subtitle (will override "subtitle" value on the title page of PDF output)
- **series-header**: Header that should appear on the series title page (default is "Also Available")
- **author**: Author name
- **website**: Author website

- **type**: Genre of your book
- **lang**: A string value in BCP 47 format: http://tools.ietf.org/html/bcp47 (e.g., en-US)
- **date**: YYYY-MM-DD
- **year**: YYYY

- **copyright-page**: Which copyright page template to use. Templates to select from are available in the **Pandoc\templates\copyright** folder (e.g., **creative-commons**)

- **cover-image**: The path (relative to **Build.ps1**) to the EPUB cover image

- **publisher**: Publisher of your book
- **rights**: A single sentence regarding the licensing of your book

- **isbn**: Optional ISBN of your print book
- **isbn-13**: Optional 13 digit ISBN of your print book
- **epub-isbn**: Optional ISBN of your epub

- **dedication**: Optional dedication

- **toc**: Whether to include a table of contents in the print output (true or false)
- **toc-title**: The header text for the Table of Contents

- **paperheight**: The height of the paper for print output (the default papersize is 6x9 inches)
- **paperwidth**: The width of the paper for print output
- **top-margin**: The top margin in the print output (headers will be inside of the text body)
- **bottom-margin**: The bottom margin in the print output
- **inner-margin**: The inner/gutter margin in the print output
- **outer-margin**: The outer margin in the print output

- **fancy-chapter**: Chapter heading style from the [fncychap](https://www.ctan.org/pkg/fncychap) library (PDF output only). Styles include **Sonny**, **Lenny**, **Glenn**, **Conny**, **Rejne**, **Bjarne**, and **Bjornstrup**
- **chapter-heading**: The name of the custom chapter heading theme to use (**default** and **romance** are available). Note that using **fancy-chapter** will override this

- **scene-separator-latex**: LaTeX code to replace **\*\*\*** sequences between scenes (used for PDF output)
- **scene-separator-html**: HTML code to replace **\*\*\*** sequences between scenes (used for ePub output)

- **copyedit**: Set as true to draw an outline around the various sections in the print output and show marginal notes in the print output (useful if using [CriticMarkup](https://github.com/CriticMarkup/CriticMarkup-toolkit))

- **identifier**:
    - **scheme**: UUID
    - **text**: A unique UUID for your ebook
      
- **contributors**:
    - **designer**: Who designed your book/cover
    - **artist**: Who created the art of your book cover
    - **editor**: Who edited your book

- **header-includes**: Raw content to embed in the template file's header (e.g., Latex commands)

- **book1**: 
    - **title**: Optional books to include on the title page
    - **link**: If you include Amazon links here, they'll get linked in the Amazon version
- **book2**:
    - **title**: Add a second book
    - **link**: http://www.amazon.com/dp/XXXXXXXXX
- **book3**:
    - **title**: This handles up to 5 books
    - **link**: http://www.amazon.com/dp/XXXXXXXXX

- **emphasis-check**: Semicolon-separated list of phrases that should be italicized. If they are not, a warning will be logged
- **no-hyphenate-list**: Space-separated list of words that explicitly show how words should be hyphenated when split across lines; useful for listing (non-hyphenated) names of characters whose names should not be split between lines
