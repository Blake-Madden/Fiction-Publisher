# clean up any output from previous run
if ([System.IO.Directory]::Exists("./Books/Output"))
    {
    $oldOutputs = [System.IO.Directory]::EnumerateFiles("./Books/Output", "*.*", [IO.SearchOption]::TopDirectoryOnly)
    foreach ($oldOutput in $oldOutputs)
        { Remove-Item -Path "$oldOutput" }
    Remove-Item -Path "./Books/Output"
    }

# get a list of all book projects in the Books folder
$Books = Get-ChildItem ./Books -Directory

# create fresh output folder after getting names of book projects
New-Item -ItemType Directory -Path "./Books/Output" -Force | Out-Null

foreach ($bookName in $Books)
    {
    Write-Output "Processing '$bookName'..."

    # Copy chapter markdown files into temp folders to be processed
    ###############################################################

    # copy source files into build folder
    Write-Output "Copying files..."
    New-Item -ItemType Directory -Path "./Books/$bookName/build" -Force | Out-Null
    Get-ChildItem -Path "./Books/$bookName/build" -Recurse | Remove-Item -Recurse -Force
    Copy-Item -Path "./Books/$bookName/outline" -Destination "./Books/$bookName/build/" -Recurse -Force

    # get all the chapters and scenes (these should all be prefixed with numbers to control their ordering)
    $mdFiles = [System.IO.Directory]::EnumerateFiles("./Books/$bookName/build/outline", "*.md", [IO.SearchOption]::AllDirectories)

    # check for possible formatting issues from the markdown files that author may want to fix
    ###############################################################

    Write-Output "Reviewing formatting in source files..."
    $WarningList = New-Object Collections.Generic.List[string]
    foreach ($file in $mdFiles)
        {
        $content = [System.IO.File]::ReadAllText($file)
        if ($content -match "[`"`']+")
            {
            $WarningList.Add('Warning: straight single/double quote(s) found in "' + $file + '". Considering converting these into smart quotes.')
            }
        if ($content -match '[ ]{2,}[^\r\n]')
            {
            $WarningList.Add('Warning: multiple spaces between words/sentences found in "' + $file + '". Considering changing these into single spaces.')
            }
        # print and e-books handle their own indenting
        if ($content -match '[\t]+')
            {
            $WarningList.Add('Warning: tab found in "' + $file + '". Considering removing these.')
            }
        if ($content -match '[\r\n]+[ ]\w+')
            {
            $WarningList.Add('Warning: space indenting found in "' + $file + '". Considering removing these.')
            }
        }

    # Pre-process files
    ###############################################################

    Write-Output "Preprocessing source files..."
    foreach ($file in $mdFiles)
        {
        $fileInfo = New-Object System.IO.FileInfo($file)

        # remove YAML sections
        $content = [System.IO.File]::ReadAllText($file) -replace '^([\w]*:[ \t]*[\w{}: ]*[\r\n]*)*', ''

        # if missing top-level header and file is the first scene in the chapter (i.e., filename starts with zero),
        # then add a chapter heading based on the chapter folder name
        if (-not ($content -match '^\s*#[ \w]+') -and ($fileInfo.BaseName -match '^[0].*'))
            {
            # chapter (folder) names should begin with number and hyphen prefix to control order, so strip that off
            $ChapterName = $fileInfo.Directory.Name -replace('^[0-9]*-','') -replace('[_]', ' ')
            $content = "# $ChapterName" + [Environment]::NewLine + [Environment]::NewLine + $content
            }

        # replace single new line (between rows of text) with a blank line
        $blankLine = [Environment]::NewLine + [Environment]::NewLine
        $content = $content -replace '([^\s])(\r\n|\n|\r)([^\s])',
                                     "`$1$blankLine`$3"

        [void] [System.IO.File]::WriteAllText($file, $content)
        }

    # source markdown files are cleaned up, now copy to different folders to pre-process for the different output formats
    Copy-Item -Path "./Books/$bookName/build/outline/" -Destination "./Books/$bookName/build/epub/" -Recurse -Force
    $epubMdFiles = [System.IO.Directory]::EnumerateFiles("./Books/$bookName/build/epub", "*.md", [IO.SearchOption]::AllDirectories)

    # Build a draft copy before doing any output-specific formatting
    Write-Output "Building draft copy..."
    pandoc --toc "./Books/$bookName/config.yml" --reference-doc "./Pandoc/templates/draft.docx" $mdFiles -o "./Books/Output/$bookName DRAFT.docx"

    # Create a bio page so we can append it to the end of the main document
    pandoc --pdf-engine=xelatex -o "./Books/$bookName/build/bio.tex" "./Books/$bookName/bio.md"

    # format for print (i.e., latex) conversion
    Write-Output "Formatting for print..."
    foreach ($file in $mdFiles)
        {
        $fileInfo = New-Object System.IO.FileInfo($file)

        $content = [System.IO.File]::ReadAllText($file)

        # replace *** with scene separator (i.e., flourishes)
        $content = $content -replace '([\r\n]+)([[:space:]]*[*]{3,}[[:space:]]*)',
                                     '$1\vspace{5mm}\centerline{\adforn{60}\quad\adforn{11}\quad\adforn{32}}\vspace{5mm}'

        # Add drop caps (on the first paragraph below the top-level header [i.e., chapter title])
        $content = $content -replace '(^[\s]*#[^\r\n]+[\r\n]+)([‘'"“«]?[A-ZÀ-ÖØ-Ý])([\w'’]*[\s,])',
                                     '$1\lettrine{$2}{$3}'
        
        # files that don't start with zero should be new scenes in a chapter, so unindent their first paragraph
        if ($fileInfo.BaseName -match '^[^0].*')
            {
            $content = $content -replace '^([\s\r\n]*)(.)', '$1\noindent $2'
            }

        [void] [System.IO.File]::WriteAllText($file, $content)
        }

    # format for epub (i.e., html) conversion
    Write-Output "Formatting for epub..."
    foreach ($file in $epubMdFiles)
        {
        $fileInfo = New-Object System.IO.FileInfo($file)

        $content = [System.IO.File]::ReadAllText($file)


        # Add drop caps (on the first paragraph below the top-level header [i.e., chapter title])
        $content = $content -replace '(^[\s]*#[^\r\n]+[\r\n]+)([‘'"“«]?[A-ZÀ-ÖØ-Ý])([\w'’]*[\s,])',
                                     '$1<span class="drop-caps">$2</span><span class="small-caps">$3</span>'

        [void] [System.IO.File]::WriteAllText($file, $content)
        }

    # Write out any formatting warnings
    if ($WarningList.Count)
        {
        Write-Output "Formatting issues found in source files. Please review 'Output/$bookName Format Warnings.log'"
        $WarningList.Sort()
        $WarningList -replace '(.*found in ")(.*[/\\]build[/\\]outline[/\\])','$1' | Out-File -FilePath "./Books/Output/$bookName Format Warnings.log"
        }

    # Build the books
    ###############################################################

    # epub
    Write-Output "Building for e-pub..."
    pandoc --top-level-division=chapter "./Books/$bookName/config.yml" --toc --toc-depth=1 --template="./Pandoc/templates/custom-epub.html" --css="./Pandoc/css/style.css" -f markdown+smart -t epub3 -o "./Books/Output/$bookName.epub" $epubMdFiles

    # Print publication output
    Write-Output "Building for print..."
    pandoc --top-level-division=chapter --template="./Pandoc/templates/cs-5x8-pdf.latex" --pdf-engine=xelatex --pdf-engine-opt=-output-driver="xdvipdfmx -V 3 -z 0" "./Books/$bookName/config.yml" $mdFiles -o "./Books/Output/$bookName-5x8-print.pdf" -A "./Books/$bookName/build/bio.tex"
    pandoc --top-level-division=chapter --template="./Pandoc/templates/cs-6x9-pdf.latex" --pdf-engine=xelatex --pdf-engine-opt=-output-driver="xdvipdfmx -V 3 -z 0" "./Books/$bookName/config.yml" $mdFiles -o "./Books/Output/$bookName-6x9-print.pdf" -A "./Books/$bookName/build/bio.tex"
    
    # clean up
    ###############################################################

    Get-ChildItem -Path "./Books/$bookName/build" -Recurse | Remove-Item -Recurse -Force
    Remove-Item -Path "./Books/$bookName/build"
    }
