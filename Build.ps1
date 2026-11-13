param(
    # the book project folder to build (kept outside of this project)
    [string]$BookFolder
)

# Resolve the book folder
if ([string]::IsNullOrWhiteSpace($BookFolder))
    {
    Write-Host -ForegroundColor Red "Please specify the book project folder to build (e.g., pwsh -File Build.ps1 -BookFolder ~/Novels/MyBook)."
    exit 1
    }
if ($BookFolder.StartsWith('~'))
    { $BookFolder = Join-Path $HOME $BookFolder.Substring(1).TrimStart('/', '\') }
$resolvedFolder = Resolve-Path -LiteralPath $BookFolder -ErrorAction SilentlyContinue
if (-not $resolvedFolder -or -not (Test-Path -LiteralPath $resolvedFolder.ProviderPath -PathType Container))
    {
    Write-Host -ForegroundColor Red "Book folder '$BookFolder' not found."
    exit 1
    }
$bookDir = $resolvedFolder.ProviderPath.TrimEnd('/', '\')
$bookName = Split-Path -Leaf $bookDir      # used to name the output files
$outputDir = "$bookDir/Fiction-Publisher-Output"
# marks the output folder as created by this script (so that it is safe to delete on the next build)
$outputMarker = "$outputDir/.fiction-publisher-output"
# Working folder for processing the source files.
# It is inside the output folder, so nothing in the book's own folder is overwritten.
# If the build fails, it is left in place so that the generated files can be reviewed.
$buildDir = "$outputDir/build"
# pandoc's errors and warnings (e.g., from LaTeX) are saved here
$buildLog = "$outputDir/$bookName Build Errors.log"

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

# Returns the markdown files under a folder in a stable order (folders and files are numbered to control their order).
function Get-MarkdownFiles
    {
    param([string]$Folder)
    $files = [string[]][IO.Directory]::GetFiles($Folder, "*.md", [IO.SearchOption]::AllDirectories)
    $keys = [string[]]($files | ForEach-Object { $_ -replace '[\\/]', [string][char]1 })
    [Array]::Sort($keys, $files, [StringComparer]::OrdinalIgnoreCase)
    return $files
    }

# Records a formatting issue for each match of '$Pattern' in the file being reviewed ($content).
# Uses the enclosing script's $content, $lineStarts, $lineOffset, $displayPath and $WarningList.
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
    foreach ($match in [regex]::Matches($content, $Pattern, $options))
        {
        # find the line that the match starts on (a miss returns the complement of the next line's index)
        $lineIndex = [Array]::BinarySearch($lineStarts, $match.Groups[$IndexGroup].Index)
        If ($lineIndex -lt 0)
            { $lineIndex = -$lineIndex - 2 }
        $lineNumber = 1 + $lineOffset + $lineIndex
        $matchedText = $match.Groups[$ValueGroup].Value -replace '\r\n|\r|\n', '\n'
        $WarningList.Add([pscustomobject]@{ File = $displayPath; Line = $lineNumber; Message = ($Message -f $matchedText) })
        }
    }

# Runs pandoc and stops the build if it fails.
# Any messages from pandoc are shown and also added to the build log (under a heading naming the file being built).
function Invoke-Pandoc
    {
    $messages = @(& pandoc @args 2>&1 | ForEach-Object { $line = $_.ToString(); Write-Host $line; $line })
    $exitCode = $LASTEXITCODE
    if ($messages.Count)
        {
        $outputIndex = [Array]::IndexOf($args, '-o')
        $target = If ($outputIndex -ge 0 -and $outputIndex + 1 -lt $args.Count) { Split-Path -Leaf $args[$outputIndex + 1] } Else { 'pandoc' }
        @("== $target ==") + $messages + @('') | Out-File -Append -LiteralPath $buildLog
        }
    if ($exitCode -ne 0)
        {
        Write-Host -ForegroundColor Red "pandoc failed (exit code $exitCode) while processing '$bookName'. Please review 'Fiction-Publisher-Output/$bookName Build Errors.log'."
        Write-Host -ForegroundColor Red "The generated files that were being built are in '$buildDir'."
        Set-Location "$PSScriptRoot"
        exit 1
        }
    }

# Prints a warning in the "<path>(<line>): warning: <message>" format that the
# "Build Book" task's problem matcher recognizes, so that it appears in VS Code's Problems pane.
# (A plain Write-Warning renders as "WARNING: ..." with no file or line, which the matcher can't parse.)
function Write-Problem
    {
    param(
        [string]$File,   # the file the warning applies to (absolute, or relative to the workspace folder)
        [string]$Message,
        [int]$Line = 1
        )
    Write-Output "$File($Line): warning: $Message"
    }

# Returns the value (and line number) of a top-level key in a config.yml (or $null if missing/empty)
function Get-ConfigValue
    {
    param([string[]]$Lines, [string]$Key)
    for ($i = 0; $i -lt $Lines.Count; $i++)
        {
        if ($Lines[$i] -match "^$([regex]::Escape($Key)):[ ]*(.*?)[ ]*$")
            {
            $value = $Matches[1] -replace '^["'']|["'']$', ''
            if ($value.Length -gt 0)
                { return [pscustomobject]@{ Value = $value; Line = $i + 1 } }
            return $null
            }
        }
    return $null
    }

# Validates an ISBN-10 or ISBN-13 check digit (hyphens and spaces are ignored)
function Test-Isbn
    {
    param([string]$Isbn, [int]$Length)
    $digits = $Isbn -replace '[\s-]', ''
    if ($Length -eq 13 -and $digits -match '^\d{13}$')
        {
        $sum = 0
        for ($i = 0; $i -lt 13; $i++)
            { $sum += [int][string]$digits[$i] * $(If ($i % 2) { 3 } Else { 1 }) }
        return ($sum % 10 -eq 0)
        }
    if ($Length -eq 10 -and $digits -match '^\d{9}[\dXx]$')
        {
        $sum = 0
        for ($i = 0; $i -lt 10; $i++)
            {
            $digit = If ($digits[$i] -in 'X', 'x') { 10 } Else { [int][string]$digits[$i] }
            $sum += $digit * (10 - $i)
            }
        return ($sum % 11 -eq 0)
        }
    return $false
    }

# Reviews a book project's structure and config.yml (e.g., that referenced files exist).
# Returns a list of issues, each with a File, Line, Severity ('error' or 'warning'), and Message.
function Test-BookProject
    {
    $issues = New-Object Collections.Generic.List[object]
    $bookPath = $bookDir -replace '\\', '/'
    $configPath = "$bookPath/config.yml"

    if (-not [IO.Directory]::Exists("$bookDir/outline"))
        {
        $issues.Add([pscustomobject]@{ File = $bookPath; Line = 1; Severity = 'error'; Message = "'outline' folder not found (this should contain the book's markdown chapters)." })
        }
    if (-not [IO.File]::Exists("$bookDir/config.yml"))
        {
        $issues.Add([pscustomobject]@{ File = $bookPath; Line = 1; Severity = 'error'; Message = "'config.yml' not found (run 'Config.ps1' to create a skeleton)." })
        return $issues
        }

    $lines = Get-Content -LiteralPath "$bookDir/config.yml"
    $buildEpub = (Get-ConfigValue $lines 'build-epub').Value -ne 'false'
    $buildPrint = (Get-ConfigValue $lines 'build-print').Value -ne 'false'

    # cover image (path is relative to the book's folder)
    $cover = Get-ConfigValue $lines 'cover-image'
    if ($buildEpub -and $cover -and -not [IO.File]::Exists("$bookDir/$($cover.Value)"))
        {
        $issues.Add([pscustomobject]@{ File = $configPath; Line = $cover.Line; Severity = 'error'; Message = "cover-image '$($cover.Value)' not found in '$bookPath'." })
        }
    # an empty cover-image is read by pandoc and errors on empty paths
    if ($buildEpub -and -not $cover)
        {
        $emptyCoverLine = [array]::FindIndex([string[]]$lines,[Predicate[string]] { param($line) $line -match '^cover-image:[ ]*(""|'''')?[ ]*$' })
        if ($emptyCoverLine -ge 0)
            {
            $issues.Add([pscustomobject]@{ File = $configPath; Line = $emptyCoverLine + 1; Severity = 'error'; Message = "cover-image is empty. Enter the path to the cover image." })
            }
        }

    # fonts (only validated if specified as a font file; otherwise, it is a font name installed on the system)
    if ($buildPrint)
        {
        foreach ($key in 'main-font', 'main-font-bold', 'main-font-italic', 'main-font-bold-italic', 'title-font', 'author-font')
            {
            $font = Get-ConfigValue $lines $key
            if ($font -and $font.Value -match '\.(ttf|otf)$' -and -not [IO.File]::Exists("$PSScriptRoot/Pandoc/fonts/$($font.Value)"))
                {
                $issues.Add([pscustomobject]@{ File = $configPath; Line = $font.Line; Severity = 'error'; Message = "$key '$($font.Value)' not found in 'Pandoc/fonts'." })
                }
            }
        }

    # templates
    $copyright = Get-ConfigValue $lines 'copyright-page'
    $copyrightName = If ($copyright) { $copyright.Value } Else { 'creative-commons' }
    foreach ($extension in 'tex', 'md')
        {
        if (-not [IO.File]::Exists("$PSScriptRoot/Pandoc/templates/copyright/$copyrightName.$extension"))
            {
            $issues.Add([pscustomobject]@{ File = $configPath; Line = If ($copyright) { $copyright.Line } Else { 1 }; Severity = 'error'; Message = "copyright-page template '$copyrightName.$extension' not found in 'Pandoc/templates/copyright'." })
            }
        }

    $chapterHeading = Get-ConfigValue $lines 'chapter-heading'
    $chapterHeadingName = If ($chapterHeading) { $chapterHeading.Value } Else { 'default' }
    if (-not [IO.File]::Exists("$PSScriptRoot/Pandoc/templates/chapter-heading/$chapterHeadingName.tex"))
        {
        $issues.Add([pscustomobject]@{ File = $configPath; Line = If ($chapterHeading) { $chapterHeading.Line } Else { 1 }; Severity = 'error'; Message = "chapter-heading template '$chapterHeadingName.tex' not found in 'Pandoc/templates/chapter-heading'." })
        }
    # chapter heading isn't used with fancy-chapter
    elseif (-not (Get-ConfigValue $lines 'fancy-chapter').Value)
        {
        $chapterHeadingFonts = @{ 'romance-cursive' = 'miama.otf'; scifi = 'Orbitron-Bold.ttf'; oldwest = 'ChunkFive-Regular.ttf' }
        if ($buildPrint -and $chapterHeadingFonts.ContainsKey($chapterHeadingName) -and -not [IO.File]::Exists("$PSScriptRoot/Pandoc/fonts/$($chapterHeadingFonts[$chapterHeadingName])"))
            {
            $issues.Add([pscustomobject]@{ File = $configPath; Line = $chapterHeading.Line; Severity = 'error'; Message = "chapter-heading '$chapterHeadingName' requires '$($chapterHeadingFonts[$chapterHeadingName])' in 'Pandoc/fonts'." })
            }
        }

    # drop caps
    $dropCap = Get-ConfigValue $lines 'drop-cap-style'
    if ($buildPrint -and $dropCap)
        {
        $dropCapFonts = @{ romance = 'texgyrechorus-mediumitalic.otf'; scifi = 'Orbitron-Bold.ttf'; oldwest = 'ChunkFive-Regular.ttf' }
        if ($dropCap.Value -notin 'default', 'romance', 'blockletter', 'scifi', 'oldwest', 'none')
            {
            $issues.Add([pscustomobject]@{ File = $configPath; Line = $dropCap.Line; Severity = 'warning'; Message = "drop-cap-style '$($dropCap.Value)' is not recognized (the default style will be used)." })
            }
        elseif ($dropCapFonts.ContainsKey($dropCap.Value) -and -not [IO.File]::Exists("$PSScriptRoot/Pandoc/fonts/$($dropCapFonts[$dropCap.Value])"))
            {
            $issues.Add([pscustomobject]@{ File = $configPath; Line = $dropCap.Line; Severity = 'error'; Message = "drop-cap-style '$($dropCap.Value)' requires '$($dropCapFonts[$dropCap.Value])' in 'Pandoc/fonts'." })
            }
        }

    # ISBNs
    foreach ($format in 'paperback', 'hardcover', 'epub')
        {
        foreach ($length in 13, 10)
            {
            $key = "$format-isbn-$length"
            $isbn = Get-ConfigValue $lines $key
            if ($isbn -and -not (Test-Isbn -Isbn $isbn.Value -Length $length))
                {
                $issues.Add([pscustomobject]@{ File = $configPath; Line = $isbn.Line; Severity = 'warning'; Message = "$key '$($isbn.Value)' is not a valid ISBN-$length (check digit or length is incorrect)." })
                }
            }
        }

    return $issues
    }

# Returns the LaTeX packages (.sty files, plus any other files they need) that the print templates load for this book, along with
# the TeX Live package that provides each one. The templates are read (rather than keeping a separate list)
# so that this stays up to date when a package is added to them.
function Get-RequiredLatexPackages
    {
    param([string[]]$ConfigLines)
    $templates = @("$PSScriptRoot/Pandoc/templates/custom-print.tex")
    $fancyChapter = (Get-ConfigValue $ConfigLines 'fancy-chapter').Value
    if ($fancyChapter)
        { $packages = @('fncychap') }
    else
        {
        # the chapter heading template is only used when fancy-chapter isn't
        $packages = @()
        $chapterHeading = (Get-ConfigValue $ConfigLines 'chapter-heading').Value
        $templates += "$PSScriptRoot/Pandoc/templates/chapter-heading/$(If ($chapterHeading) { $chapterHeading } Else { 'default' }).tex"
        }

    # drop cap fonts are only loaded for their own style (so the drop-cap-style block is skipped while reading)
    $dropCapPackages = @{ blockletter = 'Romantik' }
    $dropCapStyle = (Get-ConfigValue $ConfigLines 'drop-cap-style').Value
    if ($dropCapStyle -and $dropCapPackages.ContainsKey($dropCapStyle))
        { $packages += $dropCapPackages[$dropCapStyle] }

    foreach ($template in $templates)
        {
        if (-not [IO.File]::Exists($template))
            { continue } # (reported by the project review)
        $inDropCapBlock = $false
        foreach ($line in [IO.File]::ReadAllLines($template))
            {
            $line = $line -replace '(?<!\\)%.*$', '' # remove comments
            if ($line -match '^\s*\$if\(drop-cap-style\)\$')
                { $inDropCapBlock = $true; continue }
            if ($inDropCapBlock)
                {
                if ($line -match '^\s*\$endif\$')
                    { $inDropCapBlock = $false }
                continue
                }
            foreach ($match in [regex]::Matches($line, '\\usepackage(\[[^\]]*\])?\{([^}]+)\}'))
                {
                # (a package loaded with a template variable, like fncychap, is handled above)
                if ($match.Value -match '\$')
                    { continue }
                $packages += $match.Groups[2].Value.Split(',') | % { $_.Trim() } | Where-Object { $_ }
                }
            }
        }

    # TeX Live packages that are named differently from their .sty file
    $tlPackageNames = @{ Romantik = 'cfr-initials'; calligra = 'fundus-calligra'; longtable = 'tools' }
    # files that a package needs from a different TeX Live package
    # (e.g., Romantik.sty is only a wrapper, the font itself comes from initials)
    $extraFiles = @{
        Romantik = [pscustomobject]@{ Sty = 'Romantik.fd'; TlPackage = 'initials' }
        calligra = [pscustomobject]@{ Sty = 'callig15.mf'; TlPackage = 'calligra' }
        }
    # babel is loaded with a template variable, so it's skipped above
    $packages += 'babel'
    return $packages | Select-Object -Unique | ForEach-Object {
        [pscustomobject]@{ Sty = "$_.sty"; TlPackage = If ($tlPackageNames.ContainsKey($_)) { $tlPackageNames[$_] } Else { $_ } }
        if ($extraFiles.ContainsKey($_))
            { $extraFiles[$_] }
        }
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

# review the book project before cleaning up or building anything
$projectIssues = @(Test-BookProject)
foreach ($issue in $projectIssues)
    { Write-Output "$($issue.File)($($issue.Line)): $($issue.Severity): $($issue.Message)" }
$projectErrors = @($projectIssues | Where-Object { $_.Severity -eq 'error' })
if ($projectErrors.Count)
    {
    Write-Host -ForegroundColor Red "$($projectErrors.Count) error(s) found in the book project. Please fix these and try again."
    exit 1
    }

# ensure LaTeX packages that the print templates use are installed
$configLines = Get-Content -LiteralPath "$bookDir/config.yml"
if ((Get-ConfigValue $configLines 'build-print').Value -ne 'false' -and (Get-Command kpsewhich -ErrorAction SilentlyContinue))
    {
    $requiredPackages = @(Get-RequiredLatexPackages $configLines)
    $foundStyFiles = @(& kpsewhich @($requiredPackages.Sty) 2>$null | ForEach-Object { [IO.Path]::GetFileName($_) })
    $missingPackages = @($requiredPackages | Where-Object { $foundStyFiles -notcontains $_.Sty })
    if ($missingPackages.Count)
        {
        $missingList = ($missingPackages.Sty) -join ', '
        if ((& xelatex --version | Select-Object -First 1) -match 'MiKTeX')
            {
            # MiKTeX can install missing packages during the build (depending on its settings), so this isn't an error
            Write-Warning "LaTeX package(s) not installed: $missingList. If MiKTeX isn't set to install missing packages automatically, install these with MiKTeX Console."
            }
        else
            {
            Write-Host -ForegroundColor Red "LaTeX package(s) needed for the print PDF aren't installed: $missingList."
            Write-Host -ForegroundColor Red "Install them with:"
            Write-Host -ForegroundColor Red "  tlmgr install $((@($missingPackages.TlPackage) | Select-Object -Unique) -join ' ')"
            Write-Host -ForegroundColor Red "(or set 'build-print: false' in config.yml to skip the print PDF)"
            exit 1
            }
        }
    }

# clean up any output from previous run and create a fresh output folder
# (only if it was created by this script or is empty, so that a folder of the user's own isn't deleted)
if ([IO.Directory]::Exists($outputDir))
    {
    if (-not [IO.File]::Exists($outputMarker) -and @(Get-ChildItem -LiteralPath $outputDir -Force).Count -gt 0)
        {
        Write-Host -ForegroundColor Red "'$outputDir' already exists, but wasn't created by Fiction-Publisher. Please rename or remove it and try again."
        exit 1
        }
    Remove-Item -LiteralPath $outputDir -Recurse -Force
    }
[void] [IO.Directory]::CreateDirectory($outputDir)
[IO.File]::WriteAllText($outputMarker, "Created by Fiction-Publisher. This folder is deleted and recreated on each build.")

Write-Host -BackgroundColor White -ForegroundColor Black "Processing '$bookName' . . ."

# Copy chapter markdown files into temp folders to be processed
###############################################################

# copy source files into build folder and set that to the current working directory
Write-Output "Copying files..."
[void] [IO.Directory]::CreateDirectory($buildDir)
Copy-Item -LiteralPath "$bookDir/outline" -Destination "$buildDir/" -Recurse -Force
Copy-Item -Path "$PSScriptRoot/Pandoc/fonts/*.ttf" -Destination "$buildDir/" -Recurse -Force
Copy-Item -Path "$PSScriptRoot/Pandoc/fonts/*.otf" -Destination "$buildDir/" -Recurse -Force

# get all the chapters and scenes (these should all be prefixed with numbers to control their ordering)
$mdFiles = Get-MarkdownFiles "$buildDir/outline"

# don't include files with "compile: 0" in the build
foreach ($file in $mdFiles)
    {
    $content = [IO.File]::ReadAllText($file)
    if ($content -match '\bcompile:[ ]*0[\s]+')
        {
        Write-Output "Ignoring '$($file)'"
        Remove-Item -LiteralPath $file
        }
    }
$mdFiles = Get-MarkdownFiles "$buildDir/outline"

# Pre-process files
###############################################################
Write-Output "Preprocessing source files..."

# Chapter (folder) names that aren't numbered (e.g., a prologue), so that they don't affect the chapter numbering.
# Semicolon-separated list (specified in metadata), defaulting to "Prologue" and "Epilogue".
$unnumberedChapters = Get-ConfigValue (Get-Content -LiteralPath "$bookDir/config.yml") 'unnumbered-chapters'
$unnumberedChapters = If ($unnumberedChapters)
    { @($unnumberedChapters.Value.Split(';') | % { $_.Trim() } | Where-Object { $_.Length -gt 0 }) }
    Else { @('Prologue', 'Epilogue') }

foreach ($file in $mdFiles)
    {
    $fileInfo = New-Object System.IO.FileInfo($file)

    # remove YAML header
    $content = [IO.File]::ReadAllText($file) -replace $yamlHeaderPattern, [Environment]::NewLine

    # chapter (folder) names should begin with number and hyphen prefix to control order, so strip that off
    $ChapterName = $fileInfo.Directory.Name -replace('^[0-9]*-','') -replace('[_]', ' ')
    # a folder that is only a number (e.g., "01") has no title, so treat it as title-less
    if ($fileInfo.Directory.Name -match '^[0-9]+$')
        { $ChapterName = '' }
    $isFirstScene = $fileInfo.BaseName -match '^[0].*'

    # if missing top-level header and file is the first scene in the chapter (i.e., filename starts with zero),
    # then add a chapter heading based on the chapter folder name
    if (-not ($content -match '^\s*#(\s|$)') -and $isFirstScene)
        {
        $content = "# $ChapterName" + [Environment]::NewLine + $content
        }

    # Mark the heading of an unnumbered chapter (e.g., a prologue) with pandoc's "{-}" attribute.
    # This prevents it from being labeled or counted as a numbered chapter, but it is still in the TOC.
    # A heading that already has attributes is left alone.
    if ($isFirstScene -and $unnumberedChapters -contains $ChapterName)
        {
        $content = $content -replace '^(\s*#[ ][^\r\n{]*?)[ ]*(\r\n|\n|\r|$)', '$1 {-}$2'
        }

    # replace single new line (between lines of text) with a blank line--this is how paragraphs are supposed to be separated
    $blankLine = [Environment]::NewLine + [Environment]::NewLine
    $content = $content -replace '([^\s])(\r\n|\n|\r)([^\s])',
                                 "`$1$blankLine`$3"

    # ALL-CAPS word followed by hyphen and a number should use a non-breaking hyphen
    $content = $content -replace '([A-Z]{2,})-([0-9]+)',
                                 '$1&#X2011;$2'
    
    [void] [IO.File]::WriteAllText($file, $content)
    }

# Check for possible formatting issues from the markdown files that author may want to fix
###############################################################
Write-Output "Reviewing formatting in source files..."
$WarningList = New-Object Collections.Generic.List[object]

# semicolon separated list of items that should be italicized (specified in metadata)
$itemsToEmphasize = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^emphasis-check:(.*)' | % {($_.matches.groups[1].Value) }
if ($itemsToEmphasize.Length -gt 0)
    {
    $itemsToEmphasize = $itemsToEmphasize.Split(';') | % { $_.Trim() } | Where-Object { $_.Length -gt 0 }
    }
# invisible characters that are often pasted in from word processors or web pages
$invisibleCharacters = [ordered]@{
    [char] 0x200B = 'zero-width space'
    [char] 0x200C = 'zero-width non-joiner'
    [char] 0x200D = 'zero-width joiner'
    [char] 0x2060 = 'word joiner'
    [char] 0xFEFF = 'byte order mark (zero-width no-break space)'
    [char] 0x00AD = 'soft hyphen'
    [char] 0x00A0 = 'non-breaking space'
    }
# verbs used in dialogue tags (used to find dialogue punctuation issues; "asked" is checked separately for missing question marks)
$speechVerbs = 'said|whispered|replied|answered|muttered|murmured|mumbled|shouted|yelled|screamed|cried|called|exclaimed|added|continued|explained|stated|declared|announced|admitted|agreed|offered|suggested|insisted|warned|snapped|growled|grumbled|sighed|laughed|chuckled|sneered|stammered|stuttered|hissed'
foreach ($file in $mdFiles)
    {
    # the pre-processed copy in the build folder is what gets built, but warnings are reported
    # against the author's original file (so that line numbers are meaningful)
    $relativePath = [IO.Path]::GetRelativePath("$buildDir/outline", $file)
    $sourceFile = Join-Path "$bookDir/outline" $relativePath
    $displayPath = $sourceFile -replace '\\', '/'

    # skip the YAML header (it isn't prose), but account for its lines when reporting line numbers
    $sourceText = [IO.File]::ReadAllText($sourceFile)
    $yamlHeader = [regex]::Match($sourceText, $yamlHeaderPattern)
    $content = $sourceText.Substring($yamlHeader.Length)
    $lineOffset = [regex]::Matches($yamlHeader.Value, '\r\n|\r|\n').Count
    # where each line starts in $content (used to look up the line number of an issue)
    $lineStarts = [int[]](@(0) + @([regex]::Matches($content, '\r\n|\r|\n') | ForEach-Object { $_.Index + $_.Length }))

    # dialogue issues
    Test-FormatIssue -Pattern "([\w]+[.][`"$q2] (\w+[.] )?([\w-]+) ($speechVerbs)\b)" `
                     -Message "period used at end of dialogue (`"{0}`"). Did you intend to use a comma?"
    Test-FormatIssue -Pattern "(\w+[`"$q2] (\w+[.] )?[\w-]+ ($speechVerbs)\b)" `
                     -Message "dialogue followed by a speech tag has no punctuation before the closing quote (`"{0}`"). Did you intend to use a comma?"
    # ("I" and names are capitalized anyway, so only the other pronouns are checked)
    Test-FormatIssue -Pattern "(\w+[,?!][`"$q2] (He|She|They|We|You|It) ($speechVerbs|asked)\b)" -CaseSensitive `
                     -Message "dialogue tag starts with a capital letter (`"{0}`"). The pronoun should be lowercase because the tag continues the sentence."
    # italics issues
    Test-FormatIssue -Pattern "([*][\w ]+['$sq2]s[*])" `
                     -Message "possessive suffix being italicized (`"{0}`"). The apostrophe and s should not be italicized with the rest of the word."
    # interrogative issues
    Test-FormatIssue -Pattern "(\w+[^?][`"$q2] (the )?\w+ (asked|queried|wondered))" `
                     -Message "question mark may be needed (`"{0}`")."
    # space issues
    Test-FormatIssue -Pattern '[ ]{2,}[^\r\n]' `
                     -Message "multiple spaces between words/sentences found. Consider changing these into single spaces."
    # (a space before an ellipsis is allowed)
    Test-FormatIssue -Pattern '(\w+[ ]+[,;:?!]|\w+[ ]+[.](?![.]))' `
                     -Message "space before punctuation (`"{0}`"). Consider removing the space."
    # (words must be at least two letters, so that numbers like "1,000" and abbreviations like "e.g." and "U.S." are allowed;
    #  the following word is only looked ahead at so that it can be checked too, as in "Why?Because;nothing")
    Test-FormatIssue -Pattern '(?=(\w*[a-z]{2,}([,;:][A-Za-z]|[.?!][A-Z][a-z])\w*))\w*[a-z]{2,}[,;:.?!]' -CaseSensitive -ValueGroup 1 `
                     -Message "missing space after punctuation (`"{0}`")."
    Test-FormatIssue -Pattern '([^\s]+)((\r\n){3,}|\n{3,}|\r{3,})([^\s]+)' `
                     -Message "extra blank lines found (`"{0}`"). If these are intended to be scene separators, consider moving this text into another markdown file."
    # check for possible stray spaces or newlines that cause issues with paragraphs being split or joined incorrectly
    Test-FormatIssue -Pattern '([^ ]+[ ]+)(\r\n|\n|\r)([^ ]+)' `
                     -Message "line followed by spaces, then a single line break found (`"{0}`"). If this is intended to be a new paragraph, it is recommended to change this to a blank line for clarity. If this should be the same paragraph, then remove the newline."
    Test-FormatIssue -Pattern "[`"`']+" `
                     -Message "straight single/double quote(s) found. Consider converting these into smart quotes to make your intention explicit."
    # quotation issues
    Test-FormatIssue -Pattern "(\w+[^,.][`"$q2][,.])" `
                     -Message "comma or period outside of quote (`"{0}`"). Should be on the inside."
    # ellipses checks
    Test-FormatIssue -Pattern "[$ellipsis]+" `
                     -Message "Unicode ellipses ($ellipsis) found. Consider changing these into three periods (...)."
    # (four periods are allowed, as that is an ellipsis at the end of a sentence)
    Test-FormatIssue -Pattern '((?<![.])[.]{2}(?![.])|[.]{5,}|[,]{2,}|[!]{2,}|[?]{2,})' `
                     -Message "repeated punctuation (`"{0}`"). Ellipses should be three periods; otherwise, consider using a single punctuation mark."
    # hyphen/en dash/em dash checks
    # (en and em dashes can be typed as "--" and "---", which pandoc converts, or as the actual characters)
    Test-FormatIssue -Pattern "(\w+[ ]+-[ ]+\w+|\w+[ ]+-[`"$q2])" `
                     -Message "hyphen surrounded by spaces (`"{0}`"). Did you intend to use an em dash?"
    Test-FormatIssue -Pattern "([$endash]|(?<!-)--)[`"$q2]" `
                     -Message "en dash ending a quote. Consider changing this to an em dash."
    # (only letters on both sides of the dash, since an en dash is correct in ranges, e.g., "10--20" or "1990s--2000s")
    Test-FormatIssue -Pattern "(\w*[^\W\d_]([$endash]|--)[^\W\d_]\w*)" `
                     -Message "en dash between words (`"{0}`"). Did you intend to use a hyphen or an em dash?"
    Test-FormatIssue -Pattern '([0-9]+[-][0-9]+)' `
                     -Message "hyphen between numeric range (`"{0}`"). Did you intend to use an en dash?"
    # print and e-books handle their own indenting
    Test-FormatIssue -Pattern '[\t]+' `
                     -Message "tab found. Consider removing these."
    Test-FormatIssue -Pattern '[\r\n]+[ ]+(\w+)' -ValueGroup 1 -IndexGroup 1 `
                     -Message "space indenting found (`" {0}`"). Consider removing these."
    # lines that look like scene separators, but won't be converted ('scene-separator-latex/html' only replace "***")
    Test-FormatIssue -Pattern '(?m)^[ ]*([*][ ]+[*]([ ]*[*])+|#([ ]*#)*|~{3,}|-{3,}|_{3,}|={3,})[ ]*(?=\r?$)' -ValueGroup 1 -IndexGroup 1 `
                     -Message "`"{0}`" looks like a scene separator, but only `"***`" is converted into one. Consider changing this to `"***`"."
    # invisible characters (the matched text isn't shown, since it can't be seen)
    foreach ($character in $invisibleCharacters.GetEnumerator())
        {
        Test-FormatIssue -Pattern ([regex]::Escape([string]$character.Key)) `
                         -Message ("{0} (U+{1:X4}) found. This is usually pasted in from a word processor or web page; consider removing it (or replacing it with a regular space)." -f $character.Value, [int]$character.Key)
        }
    # stray period or comma around ? or !
    Test-FormatIssue -Pattern '([.,][?!]|[?!][.,]|[,][.])' `
                     -Message "stray period or comma found (`"{0}`")."
    # unbalanced double quotes (each line is a paragraph); a quote left open at the end of a paragraph
    # is fine if the next paragraph opens with a quote (i.e., the same speaker continues)
    $paragraphs = [regex]::Split($content, '\r\n|\r|\n')
    $previousLeftOpen = $false
    for ($i = 0; $i -lt $paragraphs.Count; $i++)
        {
        $paragraph = $paragraphs[$i].Trim()
        if ($paragraph.Length -eq 0)
            { continue }
        $opening = $paragraph.Split($q1).Count - 1
        $closing = $paragraph.Split($q2).Count - 1

        # find the next paragraph with text
        $nextParagraph = ''
        for ($j = $i + 1; $j -lt $paragraphs.Count -and $nextParagraph.Length -eq 0; $j++)
            { $nextParagraph = $paragraphs[$j].Trim() }

        $problem = $null
        if ($opening -gt $closing -and -not $nextParagraph.StartsWith($q1))
            { $problem = "opening quote ($q1) has no closing quote." }
        elseif ($closing -gt $opening -and -not $previousLeftOpen)
            { $problem = "closing quote ($q2) has no opening quote." }

        if ($problem)
            {
            $WarningList.Add([pscustomobject]@{ File = $displayPath; Line = 1 + $lineOffset + $i; Message = "unbalanced quotes: $problem" })
            }
        $previousLeftOpen = ($opening -gt $closing)

        # unbalanced italics/bold markers (emphasis can't continue into the next paragraph),
        # skipping scene separators, list bullets, escaped asterisks, and asterisks surrounded by spaces (these are literal)
        if ($paragraph -notmatch '^[* ]+$')
            {
            $markers = $paragraph -replace '^\*[ ]+', '' -replace '\\\*', '' -replace '(?<=\s)\*(?=\s)', ''
            $italicCount = 0
            $boldCount = 0
            foreach ($run in [regex]::Matches($markers, '\*+'))
                {
                # "*" is italic, "**" is bold, and "***" is both
                if ($run.Length -in 1, 3)
                    { $italicCount++ }
                if ($run.Length -in 2, 3)
                    { $boldCount++ }
                }
            if ($italicCount % 2 -or $boldCount % 2)
                {
                $WarningList.Add([pscustomobject]@{ File = $displayPath; Line = 1 + $lineOffset + $i; Message = "unbalanced italics/bold markers (*): the text won't be formatted as intended, and a stray asterisk may appear in the output." })
                }
            }
        }
    # check for items that should be italicized
    foreach ($item in $itemsToEmphasize)
        {
        # item is matched literally, the lookarounds act like word boundaries, but also work with items that start or end with punctuation
        Test-FormatIssue -Pattern "(?<![*\w])$([regex]::Escape($item))(?![*\w])" -CaseSensitive `
                         -Message "'$item' should be enclosed in asterisks to format as italic."
        }
    }

# Write out any formatting warnings
# (formatted as "<path>(<line>): warning: <message>", which editors can use to link back to the source)
if ($WarningList.Count)
    {
    Write-Host -ForegroundColor Red "Formatting issues found in source files. Please review 'Fiction-Publisher-Output/$bookName Format Warnings.log'"
    $warningLines = $WarningList | Sort-Object File, Line | ForEach-Object { "$($_.File)($($_.Line)): warning: $($_.Message)" }
    $warningLines | Out-File -LiteralPath "$outputDir/$bookName Format Warnings.log"
    $warningLines | ForEach-Object { Write-Output $_ }
    }

# source markdown files are cleaned up and reviewed, now copy to different folders to pre-process for the different output formats
Copy-Item -LiteralPath "$buildDir/outline/" -Destination "$buildDir/epub/" -Recurse -Force
$epubMdFiles = Get-MarkdownFiles "$buildDir/epub"

# Build options
$buildDraft = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^build-draft:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
$buildEpub = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^build-epub:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
$buildAmazonEpub = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^build-amazon-epub:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
$buildPrint = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^build-print:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }

# Build a draft copy before doing any output-specific formatting
If ($buildDraft -ne "false")
   {
    Write-Output "Building draft copy..."
    Invoke-Pandoc --toc "$bookDir/config.yml" --reference-doc "$PSScriptRoot/Pandoc/templates/draft.docx" $mdFiles -o "$outputDir/$bookName DRAFT.docx"
    }

# copy epub cover image to build
# (passed to pandoc as an array, so that the option is left out entirely if there is no cover image)
$coverImage = (Get-ConfigValue (Get-Content -LiteralPath "$bookDir/config.yml") 'cover-image').Value
$coverImageOption = @()
If (($coverImage.Length -gt 0) -and ($buildEpub -ne "false"))
    {
    $fileInfo = New-Object System.IO.FileInfo("$bookDir/$coverImage")
    Copy-Item -LiteralPath "$bookDir/$coverImage" -Destination "$buildDir/$($fileInfo.Name)"
    $coverImageOption = @("--epub-cover-image=$buildDir/$($fileInfo.Name)")
    }

# The "dummy.txt" is just a blank input file required by pandoc when we build our template subfiles
"" | Out-File -Encoding utf8 -LiteralPath "$buildDir/dummy.txt"

# whether the TOC should be included (this isn't read from metadata for epub, so we handle that here and pass it to the command line later)
$includeToc = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^toc:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
$includeToc = If ($includeToc -eq "true") { @("--toc") } Else { @() }

# whether the series page should be included (based on whether a "book" value is mentioned in the metadata)
$includeSeriesPageEpub = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^series-book[1-5]:'
$includeSeriesPageEpub = If ($includeSeriesPageEpub.Matches.Count -gt 0) { @("$buildDir/seriespage.md") } Else { @() }

$includeSeriesPageAmazonEpub = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^series-book[1-5]:'
$includeSeriesPageAmazonEpub = If ($includeSeriesPageAmazonEpub.Matches.Count -gt 0) { @("$buildDir/amazon-seriespage.md") } Else { @() }

# build epub and print series pages (although they may not be included)
Invoke-Pandoc --pdf-engine=xelatex --metadata-file "$bookDir/config.yml" -o "$buildDir/seriespage.md" `
       --template="$PSScriptRoot/Pandoc/templates/seriespage/seriespage.md" "$buildDir/dummy.txt"

Invoke-Pandoc --pdf-engine=xelatex --metadata-file "$bookDir/config.yml" -o "$buildDir/amazon-seriespage.md" `
       --template="$PSScriptRoot/Pandoc/templates/seriespage/amazon-seriespage.md" "$buildDir/dummy.txt"

Invoke-Pandoc --pdf-engine=xelatex --metadata-file "$bookDir/config.yml" -o "$buildDir/seriespage.tex" -t latex `
       --template="$PSScriptRoot/Pandoc/templates/seriespage/seriespage.tex" "$buildDir/dummy.txt"

# Select the copyright page template (can be customized by "copyright-page" line in metadata file)
$copyrightPage = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^copyright-page:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
$copyrightPage = If ($copyrightPage.Length -gt 0) { $copyrightPage } Else { "creative-commons" }

# Create the latex copyright file to insert into the print documents.
# Note that we are simply using the copyright template and expanding the variables from our config.yml into it.
Invoke-Pandoc --pdf-engine=xelatex --metadata-file "$bookDir/config.yml" -o "$buildDir/copyright.tex" -t latex `
       --template="$PSScriptRoot/Pandoc/templates/copyright/$copyrightPage.tex" "$buildDir/dummy.txt"

# Create the copyright file to insert into the epub documents.
# Also, note that we are simply using the copyright template and expanding the variables from our config.yml into it.
Invoke-Pandoc --metadata-file "$bookDir/config.yml" -o "$buildDir/copyright.md" `
       --template="$PSScriptRoot/Pandoc/templates/copyright/$copyrightPage.md" `
       "$buildDir/dummy.txt"
Copy-Item -Path "$PSScriptRoot/Pandoc/templates/copyright/ccbynasa.png" -Destination "$buildDir/ccbynasa.png"

# Create the latex half titlepage
# half titlepage doesn't really make sense because e-readers force the main title page to the front
Invoke-Pandoc --pdf-engine=xelatex --metadata-file "$bookDir/config.yml" -o "$buildDir/half-titlepage.tex" -t latex `
       --template="$PSScriptRoot/Pandoc/templates/half-titlepage/half-titlepage.tex" "$buildDir/dummy.txt"

# Create the latex colophon page
# ePub doesn't use typesetting, so not built for those
Invoke-Pandoc --pdf-engine=xelatex --metadata-file "$bookDir/config.yml" -o "$buildDir/colophon.tex" -t latex `
       --template="$PSScriptRoot/Pandoc/templates/colophon/default.tex" "$buildDir/dummy.txt"

# Create the latex chapter heading file to insert into the print documents.
# Note that we don't do this with epub because their chapter headings should be fairly standard looking.
# Select the chapter heading template (can be customized by "chapter-heading" line in metadata file)
$chapterHeading = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^chapter-heading:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }
$chapterHeading = If ($chapterHeading.Length -gt 0) { $chapterHeading } Else { "default" }
Invoke-Pandoc --pdf-engine=xelatex --metadata-file "$bookDir/config.yml" -o "$buildDir/chapter-heading.tex" -t latex `
       --template="$PSScriptRoot/Pandoc/templates/chapter-heading/$chapterHeading.tex" "$buildDir/dummy.txt"

# Create the author biography file to insert into the print
# TODO: need to be able to exclude this from hardcover editions via metadata
Invoke-Pandoc --pdf-engine=xelatex --metadata-file "$bookDir/config.yml" -o "$buildDir/bio.tex" -t latex `
       --template="$PSScriptRoot/Pandoc/templates/biography/bio.tex" "$buildDir/dummy.txt"

# Create the author biography file to insert into the epub documents
Invoke-Pandoc --metadata-file "$bookDir/config.yml" -o "$buildDir/bio.md" `
       --template="$PSScriptRoot/Pandoc/templates/biography/bio.md" `
       "$buildDir/dummy.txt"

# format for print (i.e., LaTeX) conversion
If ($buildPrint -ne "false")
    {
    Write-Output "Formatting for print..."
    foreach ($file in $mdFiles)
        {
        $fileInfo = New-Object System.IO.FileInfo($file)

        $content = [IO.File]::ReadAllText($file)

        # replace *** with scene separator (e.g., flourishes)
        $sceneSeparator = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^scene-separator-latex:[ ]*(.*)' | % {($_.matches.groups[1].Value) }
        if ($sceneSeparator.Length -gt 0)
            {
            $content = $content -replace '([\r\n]+)([ ]*[*]{3,}[ ]*)',
                                     "`$1$sceneSeparator"
            }

        # Add drop caps (on the first paragraph below the top-level header [i.e., chapter title])
        # Note that a leading quotation mark at start of paragraph will be removed, per Chicago Manual of Style
        $dropCapStyle = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^drop-cap-style:[ ]*([\w-]*)' | % {($_.matches.groups[1].Value) }

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
        # (deleted text can contain dashes, so match up to the first closing "--}")
        $content = $content -replace '({--)([\s\S]*?)(--})', '\st{$2}' # deletion
        $content = $content -replace '({[+]{2})([^+]*)([+]{2}})', '\underline{$2}' # addition
        $content = $content -replace '({>>)([^<]*)(<<})', '\marginpar{$2}' # comment
        $content = $content -replace '({==)([^=]*)(==})', '\hl{$2}' # highlight
        $content = $content -replace '({~~)([^~]*)(~>)([^}]*)(~~})', '\st{$2}\underline{$4}' # change
    
        # files that don't start with zero should be new scenes in a chapter, so unindent their first paragraph
        if ($fileInfo.BaseName -match '^[^0].*')
            {
            # unless the file starts with a heading, which shouldn't be prefixed
            $content = $content -replace '^(\s*)([^#\s])', '$1\noindent $2'
            }

        [void] [IO.File]::WriteAllText($file, $content)
        }
    }

# format for epub (i.e., html) conversion
If ($buildEpub -ne "false")
    {
    Write-Output "Formatting for epub..."
    $epubChapterNumber = 0
    $chapterName = Get-ConfigValue (Get-Content -LiteralPath "$bookDir/config.yml") 'chapter-name'
    $chapterName = If ($chapterName) { $chapterName.Value } Else { 'Chapter' }
    foreach ($file in $epubMdFiles)
        {
        $content = [IO.File]::ReadAllText($file)

        # A chapter with no title (e.g., "# " or folder named "01-") should
        # still show a heading in the epub, so inject "Chapter N" here. (Print uses the
        # LaTeX "Chapter N" label instead, so its heading is left empty.)
        $fileInfo = New-Object System.IO.FileInfo($file)
        $firstNonEmptyLine = ($content -split '\r\n|\r|\n' | Where-Object { $_.Trim().Length -gt 0 } | Select-Object -First 1)
        if ($firstNonEmptyLine -match '^#(\s|$)')
            {
            $chapterFolderName = $fileInfo.Directory.Name -replace '^[0-9]*-','' -replace '_',' '
            $isUnnumberedEpubChapter = ($unnumberedChapters -contains $chapterFolderName) -or ($firstNonEmptyLine -match '\{-\}')
            if (-not $isUnnumberedEpubChapter)
                { $epubChapterNumber++ }
            if ((-not $isUnnumberedEpubChapter) -and ($firstNonEmptyLine -match '^#[ \t]*(\{[^}]*\})?[ \t]*$'))
                {
                $chapterLabel = "$chapterName $epubChapterNumber"
                $emptyHeadingRegex = [regex]::new('^(\s*)#[ \t]*(\{[^}]*\})?[ \t]*(?=\r?$)', [Text.RegularExpressions.RegexOptions]::Multiline)
                $content = $emptyHeadingRegex.Replace($content, ('$1# ' + $chapterLabel), 1)
                }
            }

        # replace *** with scene separator (e.g., flourishes)
        $sceneSeparator = Get-Content -LiteralPath "$bookDir/config.yml" | Select-String -Pattern '^scene-separator-html:[ ]*(.*)' | % {($_.matches.groups[1].Value) }
        if ($sceneSeparator.Length -gt 0)
            {
            $content = $content -replace '([\r\n]+)([ ]*[*]{3,}[ ]*)',
                                     "`$1$sceneSeparator"
            }

        # Add drop caps (on the first paragraph below the top-level header [i.e., chapter title])
        $content = $content -replace "(^[\s]*#[^\r\n]+[\r\n]+)([$sq1'`"$q1$gm1 ]?[A-Z$agrave-$oumlauts$ostroke-$yacute])([\w'$sq2]*[\s,])",
                                     '$1<span class="drop-caps">$2</span><span class="small-caps">$3</span>'

        # CriticMarkup
        $content = $content -replace '({--)([\s\S]*?)(--})', '<del>$2</del>' # deletion
        $content = $content -replace '({[+]{2})([^+]*)([+]{2}})', '<ins>$2</ins>' # addition
        $content = $content -replace '({>>)([^<]*)(<<})', '<aside><mark>$2</mark></aside>' # comment
        $content = $content -replace '({==)([^=]*)(==})', '<mark>$2</mark>' # highlight
        $content = $content -replace '({~~)([^~]*)(~>)([^}]*)(~~})', '<del>$2</del><ins>$4</ins>' # change

        [void] [IO.File]::WriteAllText($file, $content)
        }
    }

# Build the books
###############################################################
Set-Location -LiteralPath "$buildDir/"

# epub
If ($buildEpub -ne "false")
   {
    Write-Output "Building for e-pub..."
    Invoke-Pandoc --top-level-division=chapter --metadata-file "$bookDir/config.yml" `
           $includeToc --toc-depth=1 `
           --template="$PSScriptRoot/Pandoc/templates/custom-epub.html" `
           $coverImageOption `
           --css="$PSScriptRoot/Pandoc/css/style.css" -f markdown+smart -t epub3 -o "$outputDir/$bookName.epub" `
           "$buildDir/copyright.md" $includeSeriesPageEpub `
           $epubMdFiles `
           "$buildDir/bio.md"
    }

# Amazon (KDP) epub; same as the standard epub, except for the Amazon-specific series page
If ($buildEpub -ne "false" -and $buildAmazonEpub -ne "false")
   {
    Write-Output "Building epub for Amazon KDP..."
    Invoke-Pandoc --top-level-division=chapter --metadata-file "$bookDir/config.yml" `
           $includeToc --toc-depth=1 `
           --template="$PSScriptRoot/Pandoc/templates/custom-epub.html" `
           $coverImageOption `
           --css="$PSScriptRoot/Pandoc/css/style.css" -f markdown+smart -t epub3 -o "$outputDir/$bookName-amazon.epub" `
           "$buildDir/copyright.md" $includeSeriesPageAmazonEpub `
           $epubMdFiles `
           "$buildDir/bio.md"
    }

# Optional epub validation
$epubFiles = @("$bookName.epub", "$bookName-amazon.epub") |
    ForEach-Object { Get-Item -LiteralPath "$outputDir/$_" -ErrorAction SilentlyContinue }
if ($epubFiles)
    {
    $epubcheck = Get-Command epubcheck -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $epubcheck)
        {
        Write-Output "epubcheck not found. Skipping epub validation."
        }
    else
        {
        foreach ($epubFile in $epubFiles)
            {
            Write-Output "Validating '$($epubFile.Name)'..."
            & $epubcheck.Source $epubFile.FullName
            if ($LASTEXITCODE -ne 0)
                { Write-Problem -File $epubFile.FullName -Message "epubcheck found problems in '$($epubFile.Name)'." }
            }
        }
    }

# Print publication output
If ($buildPrint -ne "false")
    {
    Write-Output "Building for print..."
    Invoke-Pandoc --top-level-division=chapter --template="$PSScriptRoot/Pandoc/templates/custom-print.tex" --pdf-engine=xelatex --pdf-engine-opt=-output-driver="xdvipdfmx -V 3 -z 0" `
           --metadata-file "$bookDir/config.yml" `
           -f markdown+smart $mdFiles -o "$outputDir/$bookName-print.pdf"

    # Optional print checks (requires Ghostscript, skipped if not installed)
    $ghostscript = Get-Command gs, gswin64c, gswin32c -ErrorAction SilentlyContinue | Select-Object -First 1
    If ($null -eq $ghostscript)
        {
        Write-Output "Ghostscript not found. Skipping print PDF checks."
        }
    Else
        {
        $printPdf = "$outputDir/$bookName-print.pdf"

        # Printers need an even page count (a sheet has two sides)
        # (the path is inside a PostScript string, where '\' is an escape character and parentheses delimit the string,
        #  so use forward slashes and escape any parentheses)
        $psPrintPdf = ($printPdf -replace '\\', '/') -replace '([()])', '\$1'
        $pageCount = & $ghostscript.Source -q -dNODISPLAY -dNOSAFER -dBATCH -dNOPAUSE -c "($psPrintPdf) (r) file runpdfbegin pdfpagecount = quit" 2>&1
        If ($pageCount -match '^\d+$')
            {
            If ([int]$pageCount % 2 -ne 0)
                {
                Write-Problem -File $printPdf -Message "'$bookName-print.pdf' has an odd number of pages ($pageCount). Most printers require an even page count."
                }
            }
        Else
            {
            Write-Problem -File $printPdf -Message "Unable to determine the page count of '$bookName-print.pdf' with Ghostscript."
            }

        # Printers require all fonts to be embedded
        $pdfInfo = & $ghostscript.Source -q -dNODISPLAY -dNOSAFER -dBATCH -dNOPAUSE -dPDFINFO $printPdf 2>&1
        $unembeddedFonts = $pdfInfo | Where-Object { $_ -match 'Font' -and $_ -match 'not embedded' }
        If ($unembeddedFonts)
            {
            Write-Problem -File $printPdf -Message "'$bookName-print.pdf' contains fonts that are not embedded: $(($unembeddedFonts | ForEach-Object { $_.ToString().Trim() }) -join '; ')"
            }
        }
    }

# clean up
###############################################################
Set-Location "$PSScriptRoot"

Remove-Item -LiteralPath $buildDir -Recurse -Force

# the build succeeded, but pandoc may have reported warnings (e.g., characters missing from a font)
if ([IO.File]::Exists($buildLog))
    {
    Write-Host -ForegroundColor Yellow "pandoc reported warnings while building. Please review 'Fiction-Publisher-Output/$bookName Build Errors.log'."
    }
