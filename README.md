### WHAT
Jekyll-Publisher is an attempt to use Jekyll to create ePub ebooks (and then uses kindlegen to create a mobi). 

### HOW
## Generate a new book
Run `bundle exec rake new:book` and enter a title when prompted.
- Creates a new directory named $TITLE that contains the required epub structure
- Creates a custom UUID for the title and stores it at `_data/$TITLE/uuid.yml
  - This UUID is used by `$TITLE/OEBPS/content.opf` and `$TITLE/OEBPS/toc.ncx`
- Creates a new directory named $TITLE at `_includes`
- Creates a new directory named $TITLE at `_posts` that points to the contents of `_includes/$TITLE/`

## Modify the book
Go to `_includes/$TITLE/` add contents to any of the following default pages:
- bio.md
- license.md
- title-page.md
- chapter-01.md

## Build the book
Use the rake task `build` to create the book, bundle it as an epub, and use kindlegen to convert the epub to a mobi file.
- $TITLE.epub and $TITLE.mobi can be found in the `_site` directory

## Adding a new chapter
Use the rake task `new:chapter` to ensure that the chapter is created and added to the 'structure' of the epub.
- Create the scaffolding for the new chapter by running `bundle exec rake new:chapter`
- Open `_includes/$TITLE/` and add contents to the new chapter

## Adding a new 'non-chapter' page
Use the rake task `new:page` to add new 'non-chapter' pages. This is useful for adding custom frontmatter/backmatter pages like Acknowledgements, Dedications, Thank You page, etc.
- Create the scaffolding for the new page by running `bundle exec rake new:page`
- `_includes/$TITLE/` and add contents to the new page

### STRUCTURE
## `_data`
- biblography.yml
  - Edit this as needed. It gets added to `_includes/title-page.md`
- book.yml
  - Enter the information for your book(s) here. It gets looped through by `_includes/title-page.md`

## `_epub_scaffolding`
This directory stores the required epub structure which gets called by the `new:book` rake task.

## `_includes`
This directory stores .md files for any 'shared' pages that you want to create once and include in multiple books.
- These pages are populated with information via the contents of the `_data` directory.
  - Examples include: Author Bio Page, Book License, and Title Page.

## `_layouts`
Includes the default book layout and the stylesheet.
- `epub-stylesheet` is where you modify the CSS for your book.
  - The `_epub_scaffolding/OEBPS/Styles/epub.css` file uses the `epub-stylesheet` to generate the `epub.css` file during the `new:book` rake task.

## `_posts`
These files reference the contents of `_includes` during the build process, make changes in `_includes` and leave these alone.

## `_site`
This is the directory where your completed epub/mobi file will be found after running `bundle exec rake build`.

### COMMANDS
**Create scaffolding for a new book**
- `bundle exec rake new:book`

**Create a new chapter**
- `bundle exec rake new:chapter`

**Add a new 'non-chapter' page**
- `bundle exec rake new:page`

**Delete the book**
- `bundle exec rake delete:book`

### TODO
There's still quite a bit of missing functionality and a large todo list.

# Cover Images
Right now a placeholder image is found at `_epub_scaffolding/OEBPS/Images/cats-cover.jpg` and is used as the cover for all books. 

What should happen is this:
The user defines a cover image title/location in `_data/$TITLE/book.yml` and this is used to update:
- `$TITLE/OEBPS/Images/$cover.jpg`
- `$TITLE/OEBPS/content.opf`
- `$TITLE/OEBPS/Text/Cover.html`

# Updated ToC / Manifest
Right now using the `new:chapter` and `new:page` rake tasks correctly creates the pages but they're not added to the `toc.ncx` or `content.opf` so they're not visible when the book is created.

What should happen is this:
- Use rake task to create new chapter/page
- User defines a ToC in `_data/$TITLE/toc.yml` and this is used to create/modify:
  - `$TITLE/OEBPS/content.opf`
  - `$TITLE/OEBPS/toc.ncxc`
  - `$TITLE/OEBPS/Text/TOC.xhtml`

# Universal Includes
I'd like to be able to define some 'universal' _includes such as 'bio' etc that can be defined once and then called by any book.
