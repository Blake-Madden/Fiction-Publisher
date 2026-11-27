param(
    # the book project folder to add a configuration template to (kept outside of this project)
    [string]$BookFolder
)

# Adds a configuration template (config.yml) to a book project

# Resolve the book folder
if ([string]::IsNullOrWhiteSpace($BookFolder))
    {
    Write-Host -ForegroundColor Red "Please specify the book project folder (e.g., pwsh -File Config.ps1 -BookFolder ~/Novels/MyBook)."
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

# create empty fonts folder if not available
New-Item -ItemType Directory -Path "$PSScriptRoot/Pandoc/fonts" -Force | Out-Null

# Points the YAML extension (redhat.vscode-yaml) to our schema, which provides autocompletion, hover help, and validation.
# This goes inside the YAML block because the draft build also reads config.yml as markdown,
# where a comment above the "---" would become a heading.
# The path is relative to the book's folder, so that the book can be version controlled and used on other machines
# (as long as the book and Fiction-Publisher are kept in the same places relative to each other).
$schemaPath = [IO.Path]::GetRelativePath($bookDir, "$PSScriptRoot/config.schema.json") -replace '\\', '/'
$schemaLine = $null
if ([IO.Path]::IsPathRooted($schemaPath))
  {
  # an absolute path means the book is on a different drive
  Write-Warning "The book isn't on the same drive as Fiction-Publisher, so config.yml can't refer to its schema with a relative path. Autocompletion for config.yml won't be available."
  }
else
  {
  # the extension reads the path up to the first space, so spaces are escaped
  $schemaLine = "# yaml-language-server: `$schema=$($schemaPath -replace ' ', '%20')"
  }

# create a skeleton configuration (YAML) file
if (Test-Path -LiteralPath "$bookDir/config.yml" -PathType Leaf)
  {
  Write-Output "'$bookDir/config.yml' already exists; leaving it as is."
  if ($schemaLine -and [IO.File]::ReadAllText("$bookDir/config.yml") -notmatch 'yaml-language-server:\s*\$schema=')
    {
    Write-Output "To get autocompletion for it in VS Codium/VS Code, add this line below its first '---':"
    Write-Output "  $schemaLine"
    }
  }
else
  {
  # Options users need to fill out are left blank; the rest are commented out, showing their defaults where they have one.
  $config = @'
---
{SCHEMA_LINE}
# ----- Book -----
title:
subtitle:
author:
# email:
website:
type:
lang: en-US
date:
year:
identifier:
    - scheme: UUID
      text: {GUID}

# ----- Title Page -----
# title-latex:
# subtitle-latex:
# title-page-top-margin: 4cm
# title-font:
# title-font-pointsize: 50
# author-font:
# author-by-header:

# ----- Fonts -----
# Each can be a TTF/OTF file in Pandoc/fonts or an installed font name.
# The bold/italic lines are only needed when main-font is a font file.
# main-font: Cochineal
# main-font-bold:
# main-font-italic:
# main-font-bold-italic:

# ----- Cover -----
# cover-image: images/cover.jpg

# ----- Publishing & Copyright -----
publisher:
# publisher-address-latex:
# publisher-address-html:
# copyright-page: creative-commons
# rights:
paperback-isbn-13:
paperback-isbn-10:
hardcover-isbn-13:
hardcover-isbn-10:
epub-isbn-13:
epub-isbn-10:
# first-paperback-date:
# lcc-info-latex:
# lcc-info-html:
# impression-line-years:
# impression-line-printings:
contributors:
    - designer:
      cover-artist:
      editor:
      # illustrator:

# ----- Front Matter -----
# praise:
#     - quote:
#       source:
# praise-title:
dedication: Dedicated to my readers.
# epigraph: |
# epigraph-source:
# epigraph-quote: true
# foreword: |
# foreword-author:
# foreword-title: Foreword
# preface: |
# preface-signoff:
# preface-title: Preface
# Maps need 'bleed: true'
# maps:
#     - image: images/map.png
#       image-epub:
#       title:
#       spread: false
# cast:
#     - group:
#       characters:
#           - name:
#             description:
# cast-title: Cast of Characters
# content-note: |
# content-note-title: Content Note
toc: true
# toc-title:
# toc-depth: 0

# ----- Chapters & Scenes -----
# chapter-heading: default
# fancy-chapter:
# chapter-image: images/chapter.png
# chapter-image-epub: images/chapter-epub.png
# chapter-image-width: 1.5in
# chapter-name: Chapter
# part-name: Part
# chapter-number-words: false
# unnumbered-chapters: Prologue; Epilogue
# drop-cap-style: default
# drop-cap-color: black
# scene-separator-latex:
# scene-separator-html:
# hyphenation-exceptions:

# ----- Page Layout -----
# paper-height: 9in
# paper-width: 6in
# top-margin: 30mm
# bottom-margin: 27mm
# inner-margin: 22mm
# outer-margin: 19mm
# bleed: false
# page-number-position: header
# header-includes:

# ----- Back Matter -----
# author-bio: |
# author-bio-title: About the Author
# afterword: |
# afterword-title: Afterword
# afterword-flourish: none
# acknowledgments: |
# acknowledgments-title: Acknowledgments
# reading-group-intro: |
# reading-group-guide: |
# reading-group-guide-title: Reading Group Guide
# reading-group-subtitle: Questions and Topics for Discussion
# excerpt-title:
# excerpt-heading: Excerpt
# excerpt-preview: A Preview of
# excerpt-closing: To be continued…
# excerpt-note:
# excerpt: |
# backmatter-flourish: 88
# colophon: false

# ----- Series -----
# The link is used in the Amazon ePub.
# series-header: Also Available
# series-books:
#     - title: Any book you've written
#       link: http://www.amazon.com/dp/XXXXXXXX
#     - title: Another book you've written
#       link:

# ----- Proofing -----
# emphasis-check:
# copyedit: false

# ----- Build -----
# build-draft: true
# build-epub: true
# build-amazon-epub: true
# build-print: true
# pdf-x: false
---
'@
  $config = $config.Replace('{GUID}', [guid]::NewGuid().ToString())
  $config = If ($schemaLine) { $config.Replace('{SCHEMA_LINE}', $schemaLine) } Else { $config.Replace("{SCHEMA_LINE}`n", '').Replace("{SCHEMA_LINE}`r`n", '') }
  try
    {
    Set-Content -Encoding UTF8 -LiteralPath "$bookDir/config.yml" -Value $config.TrimEnd() -ErrorAction Stop
    Write-Output "Created '$bookDir/config.yml'."
    }
  catch
    { Write-Error "Unable to create file. $($_.Exception.Message)" }
  }

# create a starter outline (prologue + first chapter) if the book has none
$outlinePath = "$bookDir/outline"
$outlineHasScenes = $false
if (Test-Path -LiteralPath $outlinePath -PathType Container)
    {
    $outlineHasScenes = [bool](Get-ChildItem -LiteralPath $outlinePath -Recurse -Filter '*.md' -File -ErrorAction SilentlyContinue | Select-Object -First 1)
    }
if (-not $outlineHasScenes)
    {
    try
        {
        foreach ($starter in @('00-Prologue', '01-Chapter_One'))
            {
            $chapterFolder = "$outlinePath/$starter"
            [void] [IO.Directory]::CreateDirectory($chapterFolder)
            $sceneFile = "$chapterFolder/00-Scene.md"
            if (-not (Test-Path -LiteralPath $sceneFile -PathType Leaf))
                {
                Set-Content -Encoding UTF8 -LiteralPath $sceneFile -Value ""
                Write-Output "Created '$sceneFile'."
                }
            }
        }
    catch
        { Write-Error "Unable to create outline folder. $($_.Exception.Message)" }
    }

# create VS Codium/VS Code tasks for building the book from its own folder
# (points to the scripts in this copy of Fiction-Publisher and is replaced each time to stay up to date.
#  A tasks file without our problem matcher's owner is the user's own, so it is left alone.)
$tasksFile = "$bookDir/.vscode/tasks.json"
$tasksExisted = Test-Path -LiteralPath $tasksFile -PathType Leaf
if ($tasksExisted -and [IO.File]::ReadAllText($tasksFile) -notmatch '"owner"\s*:\s*"fiction-publisher"')
  {
  Write-Warning "'$tasksFile' wasn't created by Fiction-Publisher, so it was left as is. To add the build tasks, remove it and run Config.ps1 again."
  exit 0
  }
$tasks = @'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build Book",
            "type": "shell",
            "command": "pwsh",
            "args": ["-NoProfile", "-File", "{FICTION_PUBLISHER}/Build.ps1", "-BookFolder", "${workspaceFolder}"],
            "group": { "kind": "build", "isDefault": true },
            "presentation": { "reveal": "always", "revealProblems": "onProblem", "panel": "dedicated", "clear": true },
            "problemMatcher": {
                "owner": "fiction-publisher",
                "fileLocation": ["autoDetect", "${workspaceFolder}"],
                "severity": "warning",
                "pattern": {
                    "regexp": "^(.+)\\((\\d+)\\): (warning|error): (.*)$",
                    "file": 1,
                    "line": 2,
                    "severity": 3,
                    "message": 4
                }
            }
        },
        {
            "label": "Open Format Warnings Log",
            "type": "shell",
            "command": "pwsh",
            "args": [
                "-NoProfile", "-Command",
                "$cli = Get-Command codium, code -ErrorAction SilentlyContinue | Select-Object -First 1; if (-not $cli) { Write-Error 'Neither codium nor code was found on PATH.'; exit 1 }; Get-ChildItem -LiteralPath (Join-Path $env:FP_BOOK 'Fiction-Publisher-Output') -Filter '*Format Warnings.log' -ErrorAction SilentlyContinue | ForEach-Object { & $cli.Source -r $_.FullName }"
            ],
            "options": { "env": { "FP_BOOK": "${workspaceFolder}" } },
            "presentation": { "reveal": "silent" },
            "problemMatcher": []
        }
    ]
}
'@
try
  {
  [void] [IO.Directory]::CreateDirectory("$bookDir/.vscode")
  # JSON strings can't contain raw backslashes, so use forward slashes for the path
  $tasks.Replace('{FICTION_PUBLISHER}', ($PSScriptRoot -replace '\\', '/')) |
    Set-Content -Encoding UTF8 -LiteralPath $tasksFile -ErrorAction Stop
  Write-Output "$(If ($tasksExisted) { 'Updated' } Else { 'Created' }) '$tasksFile'."
  }
catch
  { Write-Error "Unable to create file. $($_.Exception.Message)" }
