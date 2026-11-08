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
  # (e.g., on a different drive)
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
  try
    {
    Set-Content -Encoding UTF8 -LiteralPath "$bookDir/config.yml" `
      -Value ("---" + [environment]::NewLine + `
             $(If ($schemaLine) { $schemaLine + [environment]::NewLine }) + `
             "title:" + [environment]::NewLine + `
             "subtitle:" + [environment]::NewLine + `
             "author:" + [environment]::NewLine + `
             "website:" + [environment]::NewLine + `
             "type:" + [environment]::NewLine + `
             "lang: en-US" + [environment]::NewLine + `
             "date:" + [environment]::NewLine + `
             "year:" + [environment]::NewLine + `
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
             "      text: $([guid]::NewGuid())" + [environment]::NewLine + `
             "contributors:" + [environment]::NewLine + `
             "    - designer:" + [environment]::NewLine + `
             "      cover-artist:" + [environment]::NewLine + `
             "      editor:" + [environment]::NewLine + `
             "# Your other books to list on a series page (up to 5, series-book1 through series-book5)." + [environment]::NewLine + `
             "# The link is used in the Amazon ePub. Remove the leading '#' from these lines to use them." + [environment]::NewLine + `
             "#series-book1:" + [environment]::NewLine + `
             "#    - title: Any book you've written" + [environment]::NewLine + `
             "#      link: http://www.amazon.com/dp/XXXXXXXX" + [environment]::NewLine + `
             "#series-book2:" + [environment]::NewLine + `
             "#    - title: Another book you've written" + [environment]::NewLine + `
             "#      link:" + [environment]::NewLine + `
             "---") `
      -ErrorAction Stop
    Write-Output "Created '$bookDir/config.yml'."
    }
  catch
    { Write-Error "Unable to create file. $($_.Exception.Message)" }
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
