param(
    # the book project folder to add a configuration template to (kept outside of this project)
    [string]$BookFolder
)

# Adds a configuration template (config.yml) to a book project

# Resolve the book folder
if ([string]::IsNullOrWhiteSpace($BookFolder))
    {
    Write-Host -ForegroundColor Red "Please specify the book project folder (e.g., pwsh -File New.ps1 -BookFolder ~/Novels/MyBook)."
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

# create a skeleton configuration (YAML) file
if (Test-Path -LiteralPath "$bookDir/config.yml" -PathType Leaf)
  {
  Write-Output "'$bookDir/config.yml' already exists; leaving it as is."
  }
else
  {
  try
    {
    Set-Content -Encoding UTF8 -LiteralPath "$bookDir/config.yml" `
      -Value ("---" + [environment]::NewLine + `
             "title:" + [environment]::NewLine + `
             "subtitle:" + [environment]::NewLine + `
             "author:" + [environment]::NewLine + `
             "website:" + [environment]::NewLine + `
             "type: [GENRE]" + [environment]::NewLine + `
             "lang: en-US" + [environment]::NewLine + `
             "date: YYYY-MM-DD" + [environment]::NewLine + `
             "year: YYYY" + [environment]::NewLine + `
             "cover-image:" + [environment]::NewLine + `
             "publisher:" + [environment]::NewLine + `
             "rights: This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 Unported License." + [environment]::NewLine + `
             "paperback-isbn-13:" + [environment]::NewLine + `
             "paperback-isbn-10:" + [environment]::NewLine + `
             "hardcover-isbn-13:" + [environment]::NewLine + `
             "hardcover-isbn-10:" + [environment]::NewLine + `
             "epub-isbn-13:" + [environment]::NewLine + `
             "epub-isbn-10:" + [environment]::NewLine + `
             "dedication: Dedicated to my readers." + [environment]::NewLine + `
             "toc: true" + [environment]::NewLine + `
             "top-margin:" + [environment]::NewLine + `
             "bottom-margin:" + [environment]::NewLine + `
             "inner-margin:" + [environment]::NewLine + `
             "outer-margin:" + [environment]::NewLine + `
             "identifier:" + [environment]::NewLine + `
             "    - scheme: UUID" + [environment]::NewLine + `
             "      text: [Grab a free Version4 UUID from here: https://www.uuidgenerator.net/version4]" + [environment]::NewLine + `
             "contributors:" + [environment]::NewLine + `
             "    - designer:" + [environment]::NewLine + `
             "      cover-artist:" + [environment]::NewLine + `
             "      editor:" + [environment]::NewLine + `
             "series-book1:" + [environment]::NewLine + `
             "    - title: Any book you've written" + [environment]::NewLine + `
             "      link: http://www.amazon.com/dp/XXXXXXXX" + [environment]::NewLine + `
             "series-book2:" + [environment]::NewLine + `
             "    - title: These books get added to the title page" + [environment]::NewLine + `
             "      link: and for Amazon, they use the links you provide here" + [environment]::NewLine + `
             "series-book3:" + [environment]::NewLine + `
             "    - title: You can add up to 5 books" + [environment]::NewLine + `
             "      link:" + [environment]::NewLine + `
             "---") `
      -ErrorAction Stop
    Write-Output "Created '$bookDir/config.yml'."
    }
  catch
    { Write-Error "Unable to create file. $($_.Exception.Message)" }
  }

# create VS Codium/VS Code tasks for building the book from its own folder
# (points to the scripts in this copy of Fiction-Publisher; always replaced, so that it stays up to date)
$tasksFile = "$bookDir/.vscode/tasks.json"
$tasksExisted = Test-Path -LiteralPath $tasksFile -PathType Leaf
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
