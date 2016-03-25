### WHY
My wife is an author and I handle all of the digital/print book creation.
After 4+ years of using various tools I decided to streamline my process.

It can be a pain to manually update a Bio page with new information or new books for example. Doing a simple thing like that for 3 formats of a dozen books can take time and introduces the possibility of new typos with every change.

Pandoc is a great tool to convert markdown files to html/epub/pdf etc. but it's epub templating is still very minimalistic. It requires multiple stages to create a template that allows me to reuse common pages such as biography, licensing, etc.

I love Jekyll and use it whenever I can for web design. One of my favorite aspects is the ability to define 'code chunks' in the _includes folder and then use reference it wherever I want. Change that include file, rebuild, and every reference to it on your website is updated.  It's that kind of logic that I need for creating my books.

By using Jekyll's templating I'm able to create files that slightly differ based on need. The mandatory Smashwords title page for example, or a custom Title page with Amazon URLs to other books. 

Jekyll allows me to create custom templates, multiple 'includes', and then outputs them in a perfectly formatted Markdown file.

This markdown file can then be passed along to Pandoc and converted to epub/mobi/pdf.

### WHAT
- Write in `Books/_includes/book-title/chapters.md`
- Modify content of `amazon_review.md, bio.md, and license.md` as needed.
- Modify layouts in `Books/_layouts/book-title/` and add/remove stuff from `_includes` as needed
- jekyll build
- Your ouput.html is in _site
- Change the output.html to output.md
- Use that file as your input to Pandoc

Jekyll builds everything and puts it in _site
Use contents of _site as input for Pandoc

### STRUCTURE
```
    Books/
        Sample-Title.md
        Sample-Title-Amazon.md
        
        _layouts/
            Sample-Title/
                amazon.md
                default.md
                
        _includes/
            Sample-Title1/
                chapters.md
                
            Sample-Title2/
                chapters.md
                
            amazon_review.md
            bio.md
            license.md
```

##### Books
`Books/Sample-Title.md`
    - This file 'defines' a book and says which layout to use.
    - You can specify different versions of a book as well, in this instance I also have an Amazon specific title.

##### _layouts
`Books/_layouts/Sample-Title/default.md`
    - This file defines the structure of your final output and uses Jekyll _includes to populate the content.
    - Again, I have a default one and an Amazon specific one.

##### _includes
`Books/_includes/`
    - The files in this directory are considered 'common' and should be for files that are referenced by multiple books. This allows you create a single 'bio' page for example and reuse it for every book you write.
    
`Books/_includes/Sample-Title/chapters.md`
    - This is where you put the contents/chapters of your story.

### FLOW
- Jekyll will look for any books defined in the root of `Books`. Sample-Title.md and Sample-Title-Amazon.md in this example.

- Those files define a layout.

- The layout defines structure by 'including' files.

- Jekyll finds the included files, writes their contents in the order specified in the layout, and writes the file to the  _source directory.

- Use the contents of the source directory as input for Pandoc.

### TODO
Rake task to 'create book'
    - create Books/book-title.md file
    - create Books/_layouts/book-title/default.md | amazon.md | smashwords.md etc
    - create Books/_includes/book-title/chapters.md

Rake task to run Pandoc commands (replace makefile)

Dockerize this?
    - Base image
        + Pandoc
        + Jekyll
    - Entrypoint: rakefile
    
    Structure:
        - Dockerized repo
            - Dockerfile
            - empty 'source' directory
                - mounted by dockerfile
                - put all source.md here, Jekyll uses this as it's source
            - empty 'books' directory
                - mounted by dockerfile
                - pandoc writes to here
