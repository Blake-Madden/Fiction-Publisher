# Fills Book projects (in "Books" folder) with configuration, bio, bibliography, and review templates

# create empty Books folder in not not available
New-Item -ItemType Directory -Path "./Books" -Force | Out-Null

# get list of book projects
$Books = Get-ChildItem "./Books" -Directory

foreach ($bookName in $Books)
  {
  if ("$bookName" -eq "Output")
    { continue }
  # create a skeleton bio
  if (-not (Test-Path "./Books/$bookName/bio.md" -PathType Leaf))
    {
    try
      {
      Set-Content -Encoding UTF8 -Path "./Books/$bookName/bio.md" -Value "" -ErrorAction Stop
      }
    catch
      { Write-Error "Unable to create file. The error was $($_.Exception.Message)" }
    }
  # create a skeleton bibliography
  if (-not (Test-Path "./Books/$bookName/bibliography.md" -PathType Leaf))
    {
    try
      {
      Set-Content -Encoding UTF8 -Path "./Books/$bookName/bibliography.md" -Value "" -ErrorAction Stop
      }
    catch
      { Write-Error "Unable to create file. The error was $($_.Exception.Message)" }
    }
  # create a skeleton magnet_tah
  if (-not (Test-Path "./Books/$bookName/magnet_tah.md" -PathType Leaf))
    {
    try
      {
      Set-Content -Encoding UTF8 -Path "./Books/$bookName/magnet_tah.md" -Value "" -ErrorAction Stop
      }
    catch
      { Write-Error "Unable to create file. The error was $($_.Exception.Message)" }
    }
  # create a skeleton amazon_review
  if (-not (Test-Path "./Books/$bookName/amazon_review.md" -PathType Leaf))
    {
    try
      {
      Set-Content -Encoding UTF8 -Path "./Books/$bookName/amazon_review.md" `
        -Value ("\\" + [environment]::NewLine + "\\" + [environment]::NewLine + [environment]::NewLine + "##### If you enjoyed this book please consider leaving a [review](https://www.amazon.com/review/create-review?asin=XXXXXXXXXX) on Amazon.") `
        -ErrorAction Stop
      }
    catch
      { Write-Error "Unable to create file. The error was $($_.Exception.Message)" }
    }
  # create a skeleton configuruation (YAML) file
  if (-not (Test-Path "./Books/$bookName/config.yml" -PathType Leaf))
    {
    try
      {
      Set-Content -Encoding UTF8 -Path "./Books/$bookName/config.yml" `
        -Value ("---" + [environment]::NewLine + `
               "title:" + [environment]::NewLine + `
               "subtitle:" + [environment]::NewLine + `
               "author:" + [environment]::NewLine + `
               "website:" + [environment]::NewLine + `
               "type: [GENRE]" + [environment]::NewLine + `
               "lang: en-US" + [environment]::NewLine + `
               "date: YYYY-MM-DD" + [environment]::NewLine + `
               "year: YYYY" + [environment]::NewLine + `
               "cover-image: Source/images/XXXXX.jpg" + [environment]::NewLine + `
               "publisher:" + [environment]::NewLine + `
               "rights: This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 Unported License." + [environment]::NewLine + `
               "paperback-isbn:" + [environment]::NewLine + `
               "hardcover-isbn:" + [environment]::NewLine + `
               "epub-isbn:" + [environment]::NewLine + `
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
               "      artist:" + [environment]::NewLine + `
               "      editor:" + [environment]::NewLine + `
               "book1:" + [environment]::NewLine + `
               "    - title: Any book you've written" + [environment]::NewLine + `
               "      link: http://www.amazon.com/dp/XXXXXXXX" + [environment]::NewLine + `
               "book2:" + [environment]::NewLine + `
               "    - title: These books get added to the title page" + [environment]::NewLine + `
               "      link: and for Amazon, they use the links you provide here" + [environment]::NewLine + `
               "book3:" + [environment]::NewLine + `
               "    - title: You can add up to 5 books" + [environment]::NewLine + `
               "      link:" + [environment]::NewLine + `
               "review:" + [environment]::NewLine + `
               "    - amazon: https://www.amazon.com/review/create-review?asin=XXXXXXX" + [environment]::NewLine + `
               "---") `
        -ErrorAction Stop
      }
    catch
      { Write-Error "Unable to create file. The error was $($_.Exception.Message)" }
    }
  }
