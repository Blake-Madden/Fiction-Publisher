## Metadata Options

#### The following can be specified in a book project's **config.yml** file (which should be in the root of the book project's folder)

- **title**: Title of your book
- **title-latex** (optional): Latex formatted title (will override "title" value on the title page of PDF and print output).
- **subtitle** (optional): Optional subtitle
- **subtitle-latex** (optional): Latex formatted subtitle (will override "subtitle" value on the title page of PDF and print output).
- **series-header** (optional): Header that should appear on the series title page (default is "Also Available").
- **author**: Author Name
- **website**: Author Website

- **type**: Genre of your book
- **lang**: A string value in BCP 47 format: http://tools.ietf.org/html/bcp47 (example: en-US)
- **date**: YYYY-MM-DD
- **year**: YYYY

- **copyright-page** (optional): Which copyright page template to use. Templates to select from are available in **Pandoc\templates\copyright** (e.g., **creative-commons**)

- **cover-image**: Source/images/YOUR-IMAGE.jpg

- **publisher**: Publisher of your book
- **rights**: A single sentence regarding the licensing of your book

- **isbn** (optional): Optional ISBN of your print book
- **isbn-13** (optional): Optional 13 digit ISBN of your print book
- **epub-isbn** (optional): Optional ISBN of your epub

- **dedication**: Optional dedication.

- **toc**: Whether to include a table of contents in the print output (true or false).
- **toc-title**: The header text for the Table of Contents.

- **top-margin**: The top margin in the print output (headers will be inside of the text body).
- **bottom-margin**: The bottom margin in the print output.
- **inner-margin**: The inner/gutter margin in the print output.
- **outer-margin**: The outer margin in the print output.

- **fancy-chapter**: Chapter heading style from the "fncychap" library (print output only). Styles include Sonny, Lenny, Glenn, Conny, Rejne, Bjarne, and Bjornstrup.

- **debug**: Whether to draw an outline around the various sections in the print output.

- **identifier**:
    - **scheme**: UUID
      **text**: A unique UUID for your ebook.
      
- **contributors** (optional):
    - **designer**: Who designed your book/cover
      **artist**: Who created the art of your book cover
      **editor**: Who edited your book

- **header-includes** (optional): Raw content to embed in the template file's header (e.g., Latex commands)

- **book1** (optional): 
    - **title**: Optional books to include on the title page
      **link**: If you include Amazon links here, they'll get linked in the Amazon version
- **book2** (optional):
    - **title**: Add a second book
      **link**: http://www.amazon.com/dp/XXXXXXXXX
- **book3** (optional):
    - **title**: This handles up to 5 books
      **link**: http://www.amazon.com/dp/XXXXXXXXX
      
- **emphasis-check** (optional): semicolon-separated list of phrases that should be italicized. If they are not, a warning will be logged.
