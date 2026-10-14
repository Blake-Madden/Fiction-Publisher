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

# YAML header at the start of a markdown file (removed before building)
$yamlHeaderPattern = '^(---(\r\n|\r|\n))?([\w]+:.+(\r\n|\r|\n))+(---)?(\r\n|\r|\n){2,}'

# Records a formatting issue if '$Pattern' is found in the file being reviewed ($content).
# Uses the enclosing script's $content, $lineOffset, $displayPath and $WarningList.
# '{0}' in the message is replaced with the matched text.
function Test-FormatIssue
    {
    param(
        [string]$Pattern,
        [string]$Message,
        [switch]$CaseSensitive,
        [int]$ValueGroup = 0,   # which regex group is shown in the message
        [int]$IndexGroup = 0    # which regex group determines the reported line
        )

    $options = If ($CaseSensitive) { [Text.RegularExpressions.RegexOptions]::None } Else { [Text.RegularExpressions.RegexOptions]::IgnoreCase }
    $match = [regex]::Match($content, $Pattern, $options)
    If (-not $match.Success)
        { return }

    $lineNumber = 1 + $lineOffset + [regex]::Matches($content.Substring(0, $match.Groups[$IndexGroup].Index), '\r\n|\r|\n').Count
    $matchedText = $match.Groups[$ValueGroup].Value -replace '\r\n|\r|\n', '\n'
    $WarningList.Add([pscustomobject]@{ File = $displayPath; Line = $lineNumber; Message = ($Message -f $matchedText) })
    }

# make sure the required tools are available before touching anything (e.g., previous output)
$missingTools = @()
if (-not (Get-Command pandoc -ErrorAction SilentlyContinue))
    { $missingTools += "pandoc (https://pandoc.org/installing.html)" }
if (-not (Get-Command xelatex -ErrorAction SilentlyContinue))
    { $missingTools += "xelatex (install TeX Live, MiKTeX, or MacTeX)" }
if ($missingTools.Count)
    {
    Write-Host -ForegroundColor Red "Required tool(s) not found on PATH:"
    $missingTools | ForEach-Object { Write-Host -ForegroundColor Red "  - $_" }
    exit 1
    }
Write-Output "Using $(pandoc --version | Select-Object -First 1)"

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
        $content = [IO.File]::ReadAllText($file) -replace $yamlHeaderPattern, [Environment]::NewLine

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
    $WarningList = New-Object Collections.Generic.List[object]

    # semicolon separated list of items that should be italicized (specified in meatadata)
    $itemsToEmphacize = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^emphasis-check:(.*)' | % {($_.matches.groups[1].Value) }
    if ($itemsToEmphacize.Length -gt 0)
        {
        $itemsToEmphacize = $itemsToEmphacize.Split(';') | % { $_.Trim() }
        }
    foreach ($file in $mdFiles)
        {
        # the pre-processed copy in the build folder is what gets built, but warnings are reported
        # against the author's original file (so that line numbers are meaningful)
        $relativePath = [IO.Path]::GetRelativePath("$PSScriptRoot/Books/$bookName/build/outline", $file)
        $sourceFile = Join-Path "$PSScriptRoot/Books/$bookName/outline" $relativePath
        $displayPath = [IO.Path]::GetRelativePath($PSScriptRoot, $sourceFile) -replace '\\', '/'

        # skip the YAML header (it isn't prose), but account for its lines when reporting line numbers
        $sourceText = [IO.File]::ReadAllText($sourceFile)
        $yamlHeader = [regex]::Match($sourceText, $yamlHeaderPattern)
        $content = $sourceText.Substring($yamlHeader.Length)
        $lineOffset = [regex]::Matches($yamlHeader.Value, '\r\n|\r|\n').Count

        # dialogue issues
        Test-FormatIssue -Pattern "([\w]+[.][`"$q2] (\w+[.] )?([\w-]+) (said|[a-z]{2}ed))" `
                         -Message "period used at end of dialogue (`"{0}`"). Did you intend to use a comma?"
        # italics issues
        Test-FormatIssue -Pattern "([*][\w ]+['$sq2]s[*])" `
                         -Message "possesive suffix being italicized (`"{0}`"). Apostrophe and es should not be italicized with the rest of the word."
        # interrogative issues
        Test-FormatIssue -Pattern "(\w+[^?][`"$q2] (the )?\w+ (asked|queried|wondered))" `
                         -Message "question mark may be needed (`"{0}`")."
        # space issues
        Test-FormatIssue -Pattern '[ ]{2,}[^\r\n]' `
                         -Message "multiple spaces between words/sentences found. Considering changing these into single spaces."
        Test-FormatIssue -Pattern '([^\s]+)(\r\n\r\n\r\n|\n\n\r|\r\r\r)([^\s]+)' `
                         -Message "extra blank lines found (`"{0}`"). If these are intended to be scene separators, considering moving this text into another markdown file."
        # check for possible stray spaces or newlines that cause issues with paragraphs being split or joined incorrectly
        Test-FormatIssue -Pattern '([^ ]+[ ]+)(\r\n|\n|\r)([^ ]+)' `
                         -Message "line followed by spaces, then a single line break found (`"{0}`"). If this is intended to be a new paragraph, it is recommended to change this to a blank line for clarity. If this should be the same paragraph, then remove the newline."
        Test-FormatIssue -Pattern "[`"`']+" `
                         -Message "straight single/double quote(s) found. Considering converting these into smart quotes to make your intention explicit."
        # quotation issues
        Test-FormatIssue -Pattern "(\w+[^,.][`"$q2][,.])" `
                         -Message "comma or period inside of quote (`"{0}`"). Should be on the outside."
        # ellipses checks
        Test-FormatIssue -Pattern "[$ellipsis]+" `
                         -Message "Unicode ellipses ($ellipsis) found. Considering changing these into spaced periods."
        Test-FormatIssue -Pattern '[ ]{3,}' `
                         -Message "period ellipses found without spaces. Considering changing these into spaced periods."
        # hyphen/en dash/em dash checks
        Test-FormatIssue -Pattern '[-]{2,}' `
                         -Message "multiple dashes found. Considering changing these into en-dashes or em-dashes to make your intention explicit."
        Test-FormatIssue -Pattern "[$endash][`"$q2]" `
                         -Message "en dash ending a quote. Considering changing this to an em dash."
        Test-FormatIssue -Pattern "([\w]+[$endash][\w]+)" `
                         -Message "en dash between words (`"{0}`"). Did you intend to use a hyphen or an em dash?"
        Test-FormatIssue -Pattern '([0-9]+[-][0-9]+)' `
                         -Message "hyphen between numeric range (`"{0}`"). Did you intend to use an en dash?"
        # print and e-books handle their own indenting
        Test-FormatIssue -Pattern '[\t]+' `
                         -Message "tab found. Considering removing these."
        Test-FormatIssue -Pattern '[\r\n]+[ ]+(\w+)' -ValueGroup 1 -IndexGroup 1 `
                         -Message "space indenting found (`" {0}`"). Considering removing these."
        # stray period or comma around ? or !
        Test-FormatIssue -Pattern '([.,][?!]|[?!][.,]|[,][.])' `
                         -Message "stray period or comma found (`"{0}`")."
        # check for items that should be italicized
        foreach ($item in $itemsToEmphacize)
            {
            Test-FormatIssue -Pattern "(?<![*])\b$item\b(?![*])" -CaseSensitive `
                             -Message "'$item' should be enclosed in astericks to format as italic."
            }
        }

    # Write out any formatting warnings
    # (formatted as "<path>(<line>): warning: <message>", which editors can use to link back to the source)
    if ($WarningList.Count)
        {
        Write-Host -ForegroundColor Red "Formatting issues found in source files. Please review 'Output/$bookName Format Warnings.log'"
        $warningLines = $WarningList | Sort-Object File, Line | ForEach-Object { "$($_.File)($($_.Line)): warning: $($_.Message)" }
        $warningLines | Out-File "$PSScriptRoot/Books/Output/$bookName Format Warnings.log"
        $warningLines | ForEach-Object { Write-Output $_ }
        }

    # source markdown files are cleaned up and reviewed, now copy to different folders to pre-process for the different output formats
    Copy-Item -Path "$PSScriptRoot/Books/$bookName/build/outline/" -Destination "$PSScriptRoot/Books/$bookName/build/epub/" -Recurse -Force
    $epubMdFiles = [IO.Directory]::EnumerateFiles("$PSScriptRoot/Books/$bookName/build/epub", "*.md", [IO.SearchOption]::AllDirectories)

    # Build options
    $buildDraft = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^build-draft:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
    $buildEpub = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^build-epub:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
    $buildAmazonEpub = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^build-amazon-epub:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
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
           --template="$PSScriptRoot/Pandoc/templates/seriespage/seriespage.md" "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/amazon-seriespage.md" `
           --template="$PSScriptRoot/Pandoc/templates/seriespage/amazon-seriespage.md" "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/seriespage.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/seriespage/seriespage.tex" "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Select the copyright page template (can be customized by "copyright-page" line in metadata file)
    $copyrightPage = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^copyright-page:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
    $copyrightPage = If ($copyrightPage.Length -gt 0) { $copyrightPage } Else { "creative-commons" }

    # Create the latex copyright file to insert into the print documents.
    # Note that we are simply using the copyright template and expanding the variables from our config.yml into it.
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/copyright.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/copyright/$copyrightPage.tex" "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Create the copyright file to insert into the epub documents.
    # Also, note that we are simply using the copyright template and expanding the variables from our config.yml into it.
    pandoc --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/copyright.md" `
           --template="$PSScriptRoot/Pandoc/templates/copyright/$copyrightPage.md" `
           "$PSScriptRoot/Books/$bookName/build/dummy.txt"
    Copy-Item -Path "$PSScriptRoot/Pandoc/templates/copyright/ccbynasa.png" -Destination "$PSScriptRoot/Books/$bookName/build/ccbynasa.png"

    # Create the latex half titlepage
    # half titlepage doesn't really make sense because e-readers force the main title page to the front
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/half-titlepage.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/half-titlepage/half-titlepage.tex" "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Create the latex colophon page
    # ePub doesn't use typesetting, so not built for those
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/colophon.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/colophon/default.tex" "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Create the latex chapter heading file to insert into the print documents.
    # Note that we don't do this with epub because their chapter headings should be fairly standard looking.
    # Select the copyright page template (can be customized by "copyright-page" line in metadata file)
    $chapterHeading = Get-Content "$PSScriptRoot/Books/$bookName/config.yml" | Select-String -Pattern '^chapter-heading:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
    $chapterHeading = If ($chapterHeading.Length -gt 0) { $chapterHeading } Else { "default" }
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/chapter-heading.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/chapter-heading/$chapterHeading.tex" "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Create the author biography file to insert into the print
    # TODO: need to be able to exclude this from hardcover editions via metadata
    pandoc --pdf-engine=xelatex --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/bio.tex" -t latex `
           --template="$PSScriptRoot/Pandoc/templates/biography/bio.tex" "$PSScriptRoot/Books/$bookName/build/dummy.txt"

    # Create the author biography file to insert into the epub documents
    pandoc --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" -o "$PSScriptRoot/Books/$bookName/build/bio.md" `
           --template="$PSScriptRoot/Pandoc/templates/biography/bio.md" `
           "$PSScriptRoot/Books/$bookName/build/dummy.txt"

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
               "$PSScriptRoot/Books/$bookName/build/copyright.md" "$includeSeriesPageEpub" `
               $epubMdFiles `
               "$PSScriptRoot/Books/$bookName/build/bio.md"
        }

    # Amazon (KDP) epub; same as the standard epub, except for the Amazon-specific series page
    If ($buildEpub -ne "false" -and $buildAmazonEpub -ne "false")
       {
        Write-Output "Building epub for Amazon KDP..."
        pandoc --top-level-division=chapter --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" `
               $includeToc --toc-depth=1 `
               --template="$PSScriptRoot/Pandoc/templates/custom-epub.html" `
               --epub-cover-image="$coverImage" `
               --css="$PSScriptRoot/Pandoc/css/style.css" -f markdown+smart -t epub3 -o "$PSScriptRoot/Books/Output/$bookName-amazon.epub" `
               "$PSScriptRoot/Books/$bookName/build/copyright.md" "$includeSeriesPageAmazonEpub" `
               $epubMdFiles `
               "$PSScriptRoot/Books/$bookName/build/bio.md"
        }

    # Print publication output
    If ($buildPrint -ne "false")
        {
        Write-Output "Building for print..."
        pandoc --top-level-division=chapter --template="$PSScriptRoot/Pandoc/templates/custom-print.tex" --pdf-engine=xelatex --pdf-engine-opt=-output-driver="xdvipdfmx -V 3 -z 0" `
               --metadata-file "$PSScriptRoot/Books/$bookName/config.yml" `
               -f markdown+smart $mdFiles -o "$PSScriptRoot/Books/Output/$bookName-print.pdf"

        # Optional print checks (requires Ghostscript, skipped if not installed)
        $ghostscript = Get-Command gs, gswin64c, gswin32c -ErrorAction SilentlyContinue | Select-Object -First 1
        If ($null -eq $ghostscript)
            {
            Write-Output "Ghostscript not found. Skipping print PDF checks."
            }
        Else
            {
            $printPdf = "$PSScriptRoot/Books/Output/$bookName-print.pdf"

            # Printers need an even page count (a sheet has two sides)
            $pageCount = & $ghostscript.Source -q -dNODISPLAY -dNOSAFER -dBATCH -dNOPAUSE -c "($printPdf) (r) file runpdfbegin pdfpagecount = quit" 2>&1
            If ($pageCount -match '^\d+$')
                {
                If ([int]$pageCount % 2 -ne 0)
                    {
                    Write-Warning ("'$bookName-print.pdf' has an odd number of pages ($pageCount). Most printers require an even page count.")
                    }
                }
            Else
                {
                Write-Warning ("Unable to determine the page count of '$bookName-print.pdf' with Ghostscript.")
                }

            # Printers require all fonts to be embedded
            $pdfInfo = & $ghostscript.Source -q -dNODISPLAY -dNOSAFER -dBATCH -dNOPAUSE -dPDFINFO $printPdf 2>&1
            $unembeddedFonts = $pdfInfo | Where-Object { $_ -match 'Font' -and $_ -match 'not embedded' }
            If ($unembeddedFonts)
                {
                Write-Warning ("'$bookName-print.pdf' contains fonts that are not embedded: $(($unembeddedFonts | ForEach-Object { $_.ToString().Trim() }) -join '; ')")
                }
            }
        }

    # clean up
    ###############################################################
    Set-Location "$PSScriptRoot"

    Get-ChildItem -Path "$PSScriptRoot/Books/$bookName/build" -Recurse | Remove-Item -Recurse -Force
    Remove-Item -Path "$PSScriptRoot/Books/$bookName/build" -Force
    }
