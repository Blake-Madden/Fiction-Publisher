$q1 = [char] 0x201C  # left smart double quote
$q2 = [char] 0x201D  # right smart double quote
$sq1 = [char] 0x2018 # left smart single quote
$sq2 = [char] 0x2019 # right smart single quote
$gm1 = [char] 0x00AB # left Guillemet
$agrave = [char] 0x00C0 # A with grave
$oumlauts = [char] 0x00D6 # O with umlauts
$ostroke = [char] 0x00D8 # O with stroke
$yacute = [char] 0x00DD # Y with acute
$ellipsis = [char] 0x2026 # ellipsis
$endash = [char] 0x2013 # en dash

# clean up any output from previous run
if ([IO.Directory]::Exists("$PSScriptRoot/Books/Output"))
    {
    $oldOutputs = [IO.Directory]::EnumerateFiles("$PSScriptRoot/Books/Output", "*.*", [IO.SearchOption]::TopDirectoryOnly)
    foreach ($oldOutput in $oldOutputs)
        { Remove-Item -Path "$oldOutput" }
    Remove-Item -Path "$PSScriptRoot/Books/Output" -Force
    }

# get a list of all projects in the 'Books' folder
$Books = (Get-ChildItem "$PSScriptRoot/Books" -Directory).Name

# create fresh output folder after getting names of book projects
New-Item -ItemType Directory -Path "$PSScriptRoot/Books/Output" -Force | Out-Null

foreach ($bookName in $Books)
    {
    Write-Host -BackgroundColor White -ForegroundColor Black "Processing '$bookName' . . ."

    # Copy chapter markdown files into temp folders to be processed
    ###############################################################

    # copy source files into build folder and set that to the current working directory
    Write-Output "Copying files..."
    New-Item -ItemType Directory -Path "$PSScriptRoot/Books/$bookName/build" -Force | Out-Null
    Get-ChildItem -Path "$PSScriptRoot/Books/$bookName/build" -Recurse | Remove-Item -Recurse -Force
    Copy-Item -Path "$PSScriptRoot/Books/$bookName/outline" -Destination "$PSScriptRoot/Books/$bookName/build/" -Recurse -Force
    Copy-Item -Path "$PSScriptRoot/Pandoc/fonts/*.ttf" -Destination "$PSScriptRoot/Books/$bookName/build/" -Recurse -Force
    Copy-Item -Path "$PSScriptRoot/Pandoc/fonts/*.otf" -Destination "$PSScriptRoot/Books/$bookName/build/" -Recurse -Force

    # get all the chapters and scenes (these should all be prefixed with numbers to control their ordering)
    $mdFiles = [IO.Directory]::EnumerateFiles("$PSScriptRoot/Books/$bookName/build/outline", "*.md", [IO.SearchOption]::AllDirectories)

    # don't include files with "compile: 0" in the build
    foreach ($file in $mdFiles)
        {
        $content = [IO.File]::ReadAllText($file)
        if ($content -match '\bcompile:[ ]*0[\s]+')
            {
            Write-Output "Ignoring '$($file)'"
            Remove-Item -Path $file
            }
        }

    # Pre-process files
    ###############################################################
    Write-Output "Preprocessing source files..."
    foreach ($file in $mdFiles)
        {
        $fileInfo = New-Object System.IO.FileInfo($file)

        # remove YAML header
        $content = [IO.File]::ReadAllText($file) -replace '^(---(\r\n|\r|\n))?([\w]+:.+(\r\n|\r|\n))+(---)?(\r\n|\r|\n){2,}', [Environment]::NewLine

        # if missing top-level header and file is the first scene in the chapter (i.e., filename starts with zero),
        # then add a chapter heading based on the chapter folder name
        if (-not ($content -match '^\s*#[ \w]+') -and ($fileInfo.BaseName -match '^[0].*'))
            {
            # chapter (folder) names should begin with number and hyphen prefix to control order, so strip that off
            $ChapterName = $fileInfo.Directory.Name -replace('^[0-9]*-','') -replace('[_]', ' ')
            $content = "# $ChapterName" + [Environment]::NewLine + $content
            }

        # replace single new line (between lines of text) with a blank line--this is how paragraphs are supposed to be separated
        $blankLine = [Environment]::NewLine + [Environment]::NewLine
        $content = $content -replace '([^\s])(\r\n|\n|\r)([^\s])',
                                     "`$1$blankLine`$3"

        # ALL-CAPS word followed by hyphen and a number should use a non-breaking hypen
        $content = $content -replace '([A-Z]{2,})-([0-9]+)',
                                     '$1&#X2011;$2'
        
        [void] [IO.File]::WriteAllText($file, $content)
        }

    # Check for possible formatting issues from the markdown files that author may want to fix
    ###############################################################
    Write-Output "Reviewing formatting in source files..."
    $WarningList = New-Object Collections.Generic.List[string]

    # semicolon separated list of items that should be italicized (specified in meatadata)
    $itemsToEmphacize = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^emphasis-check:(.*)' | % {($_.matches.groups[1].Value) }
    if ($itemsToEmphacize.Length -gt 0)
        {
        $itemsToEmphacize = $itemsToEmphacize.Split(';') | % { $_.Trim() }
        }
    foreach ($file in $mdFiles)
        {
        $fileInfo = New-Object System.IO.FileInfo($file)
        $simpleFilePath = $fileInfo.Directory.Name + [IO.Path]::DirectorySeparatorChar + $fileInfo.Name

        $content = [IO.File]::ReadAllText($file)

        # dialogue issues
        $matchResult = $content | Select-String -Pattern "([\w]+[.][`"$q2] (\w+[.] )?([\w-]+) (said|[a-z]{2}ed))"
        if ($matchResult.Matches.Count -gt 0)
            {
            $WarningList.Add("Warning: period used at end of dialogue in '$($simpleFilePath)' (`"$($matchResult.Matches.Groups[0].Captures[0].Value)`"). Did you intend to use a comma?")
            }
        # italics issues
        $matchResult = $content | Select-String -Pattern "([*][\w ]+['$sq2]s[*])"
        if ($matchResult.Matches.Count -gt 0)
            {
            $WarningList.Add("Warning: possesive suffix being italicized in '$($simpleFilePath)' (`"$($matchResult.Matches.Groups[0].Captures[0].Value)`"). Apostrophe and es should not be italicized with the rest of the word.")
            }
        # interrogative issues
        $matchResult = $content | Select-String -Pattern "(\w+[^?][`"$q2] (the )?\w+ (asked|queried|wondered))"
        if ($matchResult.Matches.Count -gt 0)
            {
            $WarningList.Add("Warning: question mark may be needed in '$($simpleFilePath)' (`"$($matchResult.Matches.Groups[0].Captures[0].Value)`").")
            }
        # space issues
        if ($content -match '[ ]{2,}[^\r\n]')
            {
            $WarningList.Add("Warning: multiple spaces between words/sentences found in '$($simpleFilePath)'. Considering changing these into single spaces.")
            }
        $matchResult = $content | Select-String -Pattern '([^\s]+)(\r\n\r\n\r\n|\n\n\r|\r\r\r)([^\s]+)'
        if ($matchResult.Matches.Count -gt 0)
            {
            $WarningList.Add("Warning: extra blank lines found in '$($simpleFilePath)' (`"$($matchResult.Matches.Groups[0].Captures[0].Value)`"). If these are intended to be scene separators, considering moving this text into another markdown file.")
            }
        # check for possible stray spaces or newlines that cause issues with paragraphs being split or joined incorrectly
        $matchResult = $content | Select-String -Pattern '([^ ]+[ ]+)(\r\n|\n|\r)([^ ]+)'
        if ($matchResult.Matches.Count -gt 0)
            {
            $WarningList.Add("Warning: line followed by spaces, then a single line break found in '$($simpleFilePath)' (`"$($matchResult.Matches.Groups[0].Captures[0].Value)`"). If this is intended to be a new paragraph, it is recommended to change this to a blank line for clarity. If this should be the same paragraph, then remove the newline.")
            }
        if ($content -match "[`"`']+")
            {
            $WarningList.Add("Warning: straight single/double quote(s) found in '$($simpleFilePath)'. Considering converting these into smart quotes to make your intention explicit.")
            }
        # quotation issues
        $matchResult = $content | Select-String -Pattern "(\w+[^,.][`"$q2][,.])"
        if ($matchResult.Matches.Count -gt 0)
            {
            $WarningList.Add("Warning: comma or period inside of quote in '$($simpleFilePath)' (`"$($matchResult.Matches.Groups[0].Captures[0].Value)`"). Should be on the outside.")
            }
        # ellipses checks
        if ($content -match "[$ellipsis]+")
            {
            $WarningList.Add("Warning: Unicode ellipses ($ellipsis) found in '$($simpleFilePath)'. Considering changing these into spaced periods.")
            }
        if ($content -match '[ ]{3,}')
            {
            $WarningList.Add("Warning: period ellipses found in '$($simpleFilePath)' without spaces. Considering changing these into spaced periods.")
            }
        # hyphen/en dash/em dash checks
        if ($content -match '[-]{2,}')
            {
            $WarningList.Add("Warning: multiple dashes found in '$($simpleFilePath)'. Considering changing these into en-dashes or em-dashes to make your intention explicit.")
            }
        if ($content -match "[$endash][`"$q2]")
            {
            $WarningList.Add("Warning: en dash ending a quote in '$($simpleFilePath)'. Considering changing this to an em dash.")
            }
        $matchResult = $content | Select-String -Pattern "([\w]+[$endash][\w]+)"
        if ($matchResult.Matches.Count -gt 0)
            {
            $WarningList.Add("Warning: en dash between words in '$($simpleFilePath)' (`"$($matchResult.Matches.Groups[0].Captures[0].Value)`"). Did you intend to use a hyphen or an em dash?")
            }
         $matchResult = $content | Select-String -Pattern '([0-9]+[-][0-9]+)'
         if ($matchResult.Matches.Count -gt 0)
            {
            $WarningList.Add("Warning: hyphen between numeric range in '$($simpleFilePath)' (`"$($matchResult.Matches.Groups[0].Captures[0].Value)`"). Did you intend to use an en dash?")
            }
        # print and e-books handle their own indenting
        if ($content -match '[\t]+')
            {
            $WarningList.Add("Warning: tab found in '$($simpleFilePath)'. Considering removing these.")
            }
        $matchResult = $content | Select-String -Pattern '[\r\n]+[ ]+(\w+)'
        if ($matchResult.Matches.Count -gt 0)
            {
            $WarningList.Add("Warning: space indenting found in '$($simpleFilePath)', (' $($matchResult.Matches.Groups[0].Captures[0].Value)'). Considering removing these.")
            }
        # stray period or comma around ? or !
        $matchResult = $content | Select-String -Pattern '([.,][?!]|[?!][.,]|[,][.])'
        if ($matchResult.Matches.Count -gt 0)
            {
            $WarningList.Add("Warning: stray period or comma found in '$($simpleFilePath)' (`"$($matchResult.Matches.Groups[0].Captures[0].Value)`").")
            }
        # check for items that should be italicized
        foreach ($item in $itemsToEmphacize)
            {
            if ($content -cmatch "(^|[^*])\b$item\b($|[^*])")
                {
                $WarningList.Add("Warning: '$($item)' in '$($simpleFilePath)' should be enclosed in astericks to format as italic.")
                }
            }
        }

    # Write out any formatting warnings
    if ($WarningList.Count)
        {
        Write-Host -ForegroundColor Red "Formatting issues found in source files. Please review 'Output/$bookName Format Warnings.log'"
        $WarningList.Sort()
        $WarningList -replace '(.*found in ")(.*[/\\]build[/\\]outline[/\\])','$1' | Out-File "$PSScriptRoot/Books/Output/$bookName Format Warnings.log"
        }

    # source markdown files are cleaned up and reviewed, now copy to different folders to pre-process for the different output formats
    Copy-Item -Path "$PSScriptRoot/Books/$bookName/build/outline/" -Destination "$PSScriptRoot/Books/$bookName/build/epub/" -Recurse -Force
    $epubMdFiles = [IO.Directory]::EnumerateFiles("$PSScriptRoot/Books/$bookName/build/epub", "*.md", [IO.SearchOption]::AllDirectories)

    # Build options
    $buildDraft = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^build-draft:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
    $buildEpub = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^build-epub:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
    $buildMobi = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^build-mobi:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
    $buildPrint = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^build-print:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }

    # Build a draft copy before doing any output-specific formatting
    If ($buildDraft -ne "false")
       {
        Write-Output "Building draft copy..."
        pandoc --toc "$PSScriptRoot/Books/$bookName/config.yml" --reference-doc "$PSScriptRoot/Pandoc/templates/draft.docx" $mdFiles -o "$PSScriptRoot/Books/Output/$bookName DRAFT.docx"
        }

    # copy epub cover image to build
    $coverImage = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^cover-image:[ ]*([\w-/\\.]*)' | % {($_.matches.groups[1].Value) }
    If (($coverImage.Length -gt 0) -and ($buildEpub -ne "false"))
        {
        $fileInfo = New-Object System.IO.FileInfo("$PSScriptRoot/Books/$bookName/$coverImage")
        Copy-Item -Path "$PSScriptRoot/Books/$bookName/$coverImage" -Destination "$PSScriptRoot/Books/$bookName/build/$($fileInfo.Name)"
        $coverImage = "$PSScriptRoot/Books/$bookName/build/$($fileInfo.Name)"
        }

    # The "dummy.txt" is just a blank input file required by pandoc when we build are template subfiles
    "" | Out-File -Encoding utf8 "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # whether the TOC should be included (this isn't read from metadata for epub, so we handle that here and pass it to the command line later)
    $includeToc = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^toc:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
    $includeToc = If ($includeToc -eq "true") { "--toc" } Else { "" }

    # whether the series page should be included (based on whether a "book" value is mentioned in the metadata)
    $includeSeriesPageEpub = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^book[1-5]:'
    $includeSeriesPageEpub = If ($includeSeriesPageEpub.Matches.Count -gt 0) { "$PSScriptRoot/Books/$bookName/build/seriespage.md" } Else { "" }

    $includeSeriesPageAmazonEpub = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^book[1-5]:'
    $includeSeriesPageAmazonEpub = If ($includeSeriesPageAmazonEpub.Matches.Count -gt 0) { "$PSScriptRoot/Books/$bookName/build/amazon-seriespage.md" } Else { "" }

    # build epub and print series pages (although they may not be included)
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/seriespage.md" `
           --template="$PSScriptRoot/Pandoc/templates/seriespage/seriespage.md" -i "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/amazon-seriespage.md" `
           --template="$PSScriptRoot/Pandoc/templates/seriespage/amazon-seriespage.md" -i "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/seriespage.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/seriespage/seriespage.tex" -i "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Select the copyright page template (can be customized by "copyright-page" line in metadata file)
    $copyrightPage = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^copyright-page:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
    $copyrightPage = If ($copyrightPage.Length -gt 0) { $copyrightPage } Else { "creative-commons" }

    # Create the latex copyright file to insert into the print documents.
    # Note that we are simply using the copyright template and expanding the variables from our config.yml into it.
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/copyright.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/copyright/$copyrightPage.tex" -i "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Create the copyright file to insert into the epub documents.
    # Also, note that we are simply using the copyright template and expanding the variables from our config.yml into it.
    pandoc --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/copyright.md" `
           --template="$PSScriptRoot/Pandoc/templates/copyright/$copyrightPage.md" `
           -i "$PSScriptRoot/Books/$bookName/build/dummy.txt"
    Copy-Item -Path "$PSScriptRoot/Pandoc/templates/copyright/ccbynasa.png" -Destination "$PSScriptRoot/Books/$bookName/build/ccbynasa.png"

    # Create the latex half titlepage
    # half titlepage doesn't really make sense because e-readers force the main title page to the front
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/half-titlepage.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/half-titlepage/half-titlepage.tex" -i "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Create the latex colophon page
    # ePub doesn't use typesetting, so not built for those
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/colophon.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/colophon/default.tex" -i "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Create the latex chapter heading file to insert into the print documents.
    # Note that we don't do this with epub because their chapter headings should be fairly standard looking.
    # Select the copyright page template (can be customized by "copyright-page" line in metadata file)
    $chapterHeading = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^chapter-heading:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
    $chapterHeading = If ($chapterHeading.Length -gt 0) { $chapterHeading } Else { "default" }
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/chapter-heading.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/chapter-heading/$chapterHeading.tex" -i "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Create the author biography file to insert into the print
    # TODO: need to be able to exclude this from hardcover editions via metadata
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/bio.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/biography/bio.tex" -i "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Create the author biography file to insert into the epub documents
    pandoc --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/bio.md" `
           --template="$PSScriptRoot/Pandoc/templates/biography/bio.md" `
           -i "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # format for print (i.e., LaTeX) conversion
    If ($buildPrint -ne "false")
        {
        Write-Output "Formatting for print..."
        foreach ($file in $mdFiles)
            {
            $fileInfo = New-Object System.IO.FileInfo($file)

            $content = [IO.File]::ReadAllText($file)

            # replace *** with scene separator (e.g., flourishes)
            $sceneSeparator = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^scene-separator-latex:[ ]*(.*)' | % {($_.matches.groups[1].Value) }
            if ($sceneSeparator.Length -gt 0)
                {
                $content = $content -replace '([\r\n]+)([ ]*[*]{3,}[ ]*)',
                                         "`$1$sceneSeparator"
                }

            # Add drop caps (on the first paragraph below the top-level header [i.e., chapter title])
            # Note that a leading quotation mark at start of paragraph will be removed, per Chicago Manual of Style
            $dropCapStyle = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^drop-cap-style:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }

            # romance style is oblique, so need some special commands for certain letters to look nice
            if ($dropCapStyle -eq 'romance')
              {
              $content = $content -replace "(^[\s]*#[^\r\n]+[\r\n]+)[$sq1'`"$q1$gm1 ]?([ACEIKLMRSTUXZ$agrave-$oumlauts$ostroke-$yacute])([\w'$sq2]*[\s,])",
                                  '$1\lettrine{$2}{$3}'

              # 'G' has a lengthy descender with the font that we use for romance
              $content = $content -replace "(^[\s]*#[^\r\n]+[\r\n]+)[$sq1'`"$q1$gm1 ]?([G])([\w'$sq2]*[\s,])",
                                  '$1\lettrine[findent=.5em, nindent=0em, depth=1]{$2}{$3}'

              $content = $content -replace "(^[\s]*#[^\r\n]+[\r\n]+)[$sq1'`"$q1$gm1 ]?([BH])([\w'$sq2]*[\s,])",
                                  '$1\lettrine[findent=.5em, nindent=0em]{$2}{$3}'

              $content = $content -replace "(^[\s]*#[^\r\n]+[\r\n]+)[$sq1'`"$q1$gm1 ]?([DFJNOPQVWY])([\w'$sq2]*[\s,])",
                                  '$1\lettrine[findent=.5em, nindent=-.5em]{$2}{$3}'
              }
            elseif ($dropCapStyle -eq 'none')
              {} # noop
            else
              {
              $content = $content -replace "(^[\s]*#[^\r\n]+[\r\n]+)[$sq1'`"$q1$gm1 ]?([A-Z$agrave-$oumlauts$ostroke-$yacute])([\w'$sq2]*[\s,])",
                                  '$1\lettrine{$2}{$3}'
              }

            # CriticMarkup
            $content = $content -replace '({--)([^-]*)(--})', '\st{$2}' # deletion
            $content = $content -replace '({[+]{2})([^+]*)([+]{2}})', '\underline{$2}' # addition
            $content = $content -replace '({>>)([^<]*)(<<})', '\marginpar{$2}' # comment
            $content = $content -replace '({==)([^=]*)(==})', '\hl{$2}' # highlight
            $content = $content -replace '({~~)([^~]*)(~>)([^}]*)(~~})', '\st{$2}\underline{$4}' # change
        
            # files that don't start with zero should be new scenes in a chapter, so unindent their first paragraph
            if ($fileInfo.BaseName -match '^[^0].*')
                {
                $content = $content -replace '^([\s\r\n]*)(.)', '$1\noindent $2'
                }

            [void] [IO.File]::WriteAllText($file, $content)
            }
        }

    # format for epub (i.e., html) conversion
    If ($buildEpub -ne "false")
        {
        Write-Output "Formatting for epub..."
        foreach ($file in $epubMdFiles)
            {
            $content = [IO.File]::ReadAllText($file)

            # replace *** with scene separator (e.g., flourishes)
            $sceneSeparator = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^scene-separator-html:[ ]*(.*)' | % {($_.matches.groups[1].Value) }
            if ($sceneSeparator.Length -gt 0)
                {
                $content = $content -replace '([\r\n]+)([ ]*[*]{3,}[ ]*)',
                                         "`$1$sceneSeparator"
                }

            # Add drop caps (on the first paragraph below the top-level header [i.e., chapter title])
            $content = $content -replace "(^[\s]*#[^\r\n]+[\r\n]+)([$sq1'`"$q1$gm1 ]?[A-Z$agrave-$oumlauts$ostroke-$yacute])([\w'$sq2]*[\s,])",
                                         '$1<span class="drop-caps">$2</span><span class="small-caps">$3</span>'

            # CriticMarkup
            $content = $content -replace '({--)([^-]*)(--})', '<del>$2</del>' # deletion
            $content = $content -replace '({[+]{2})([^+]*)([+]{2}})', '<ins>$2</ins>' # addition
            $content = $content -replace '({>>)([^<]*)(<<})', '<aside><mark>$2</mark></aside>' # comment
            $content = $content -replace '({==)([^=]*)(==})', '<mark>$2</mark>' # highlight
            $content = $content -replace '({~~)([^~]*)(~>)([^}]*)(~~})', '<del>$2</del><ins>$4</ins>' # change

            [void] [IO.File]::WriteAllText($file, $content)
            }
        }

    # Build the books
    ###############################################################
    Set-Location "$PSScriptRoot/Books/$bookName/build/"

    # epub
    If ($buildEpub -ne "false")
       {
        Write-Output "Building for e-pub..."
        pandoc --top-level-division=chapter --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" `
               $includeToc --toc-depth=1 `
               --template="$PSScriptRoot/Pandoc/templates/custom-epub.html" `
               --epub-cover-image="$coverImage" `
               --css="$PSScriptRoot/Pandoc/css/style.css" -f markdown+smart -t epub3 -o "$PSScriptRoot/Books/Output/$bookName.epub" `
               -i "$PSScriptRoot/Books/$bookName/build/copyright.md" "$includeSeriesPageEpub" `
               $epubMdFiles `
               "$PSScriptRoot/Books/$bookName/build/bio.md"
        }

    # Amazon mobi
    If ($buildEpub -ne "false" -and $buildMobi -ne "false")
       {
        Write-Output "Building for Amazon mobi..."
        pandoc --top-level-division=chapter --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" `
               $includeToc --toc-depth=1 `
               --template="$PSScriptRoot/Pandoc/templates/custom-epub.html" `
               --epub-cover-image="$coverImage" `
               --css="$PSScriptRoot/Pandoc/css/style.css" -f markdown+smart -t epub3 -o "$PSScriptRoot/Books/Output/$bookName.epub" `
               -i "$PSScriptRoot/Books/$bookName/build/copyright.md" "$includeSeriesPageAmazonEpub" `
               $epubMdFiles `
               "$PSScriptRoot/Books/$bookName/build/bio.md"           
        kindlegen -c2 "$PSScriptRoot/Books/Output/$bookName.epub"
        }

    # Print publication output
    If ($buildPrint -ne "false")
        {
        Write-Output "Building for print..."
        pandoc --top-level-division=chapter --template="$PSScriptRoot/Pandoc/templates/custom-print.tex" --pdf-engine=xelatex --pdf-engine-opt=-output-driver="xdvipdfmx -V 3 -z 0" `
               --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" `
               -f markdown+smart $mdFiles -o "$PSScriptRoot/Books/Output/$bookName-print.pdf"
        }

    # clean up
    ###############################################################
    Set-Location "$PSScriptRoot"

    Get-ChildItem -Path "$PSScriptRoot/Books/$bookName/build" -Recurse | Remove-Item -Recurse -Force
    Remove-Item -Path "$PSScriptRoot/Books/$bookName/build" -Force
    }
