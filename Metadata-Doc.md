## Metadata Options (* indicates optional features)

title: Title of your book
title-latex*: Latex formatted title (will override "title" value on the title page of PDF and print output).
subtitle*: Optional subtitle
subtitle-latex*: Latex formatted subtitle (will override "subtitle" value on the title page of PDF and print output).
author: Author Name
website: Author Website

type: Genre of your book
lang: A string value in BCP 47 format: http://tools.ietf.org/html/bcp47 (example: en-US)
date: YYYY-MM-DD
year: YYYY

cover-image: Source/images/YOUR-IMAGE.jpg

publisher: Publisher of your book
rights: A single sentence regarding the licensing of your book

isbn*: Optional ISBN of your print book
isbn-13*: Optional 13 digit ISBN of your print book
epub-isbn*: Optional ISBN of your epub

dedication: Optional dedication.

toc: Whether to include a table of contents in the print output (true or false).
toc-title: The header text for the Table of Contents (default is "Content").

top-margin: The top margin in the print output (headers will be inside of the text body).
bottom-margin: The bottom margin in the print output.
inner-margin: The inner/gutter margin in the print output.
outer-margin: The outer margin in the print output.

fancy-chapter: Chapter heading style from the "fncychap" library (print output only). Styles include Sonny, Lenny, Glenn, Conny, Rejne, Bjarne, and Bjornstrup.

debug: Whether to draw an outline around the various sections in the print output.

identifier:
    - scheme: UUID
      text: A unique UUID for your ebook.
      
contributors*:
    - designer*: Who designed your book/cover
      artist*: Who created the art of your book cover
      editor*: Who edited your book

header-includes*: Raw content to embed in the template file's header (e.g., Latex commands)

book1*: 
    - title*: Optional books to include on the title page
      link*: If you include Amazon links here, they'll get linked in the Amazon version
book2*:
    - title*: Add a second book
      link*: http://www.amazon.com/dp/XXXXXXXXX
book3*:
    - title*: This handles up to 5 books
      link*: http://www.amazon.com/dp/XXXXXXXXX
