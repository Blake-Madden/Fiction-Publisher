## What is Fiction Publisher
**Fiction Publisher** is a fork of [Open Publisher](https://github.com/chrisanthropic/Open-Publisher), redesigned to work with [Manuskript](https://github.com/olivierkes/manuskript) projects. It is a PowerShell script that wraps Pandoc, KindleGen, and LaTeX and uses a set of custom Pandoc templates (created with a focus on fiction).

Write your manuscript in markdown, write a Pandoc [metadata](Metadata-Doc.md) file, run a script, and receive some beautifully formatted ePub, Mobi, and print-ready PDF books.

Full documentation on the [wiki](https://github.com/Blake-Eryx/Fiction-Publisher/wiki).

## Fiction Publisher v2 Roadmap

- [X] Remove Jekyll dependency
- [X] Create PowerShell new project script
- [X] Create PowerShell build script
  - [X] PDF (print)
  - [X] epub
  - [X] mobi
- [X] Add markdown validations
  - [X] Check for paragraphs not separated by blank lines (this is recommended over ending lines with double spaces because it makes the intention clearer and avoids possible errors)
  - [X] Check for straight quotes (proper smart quotes should be included in source markdown to avoid ambiguity)
  - [X] Check for '--' (en dashes and em dashes should be included in source markdown to avoid ambiguity)
  - [X] Check for correct ordering of closing quotation marks and commas/periods
  - [X] Check for Unicode ellipsis (should be spaced periods)
  - [X] Check for en dash at the end of a quote (should be an em dash)
  - [X] Check for hyphen between numbers (should be an en dash)
  - [X] Check for extra spaces
  - [X] Check for indenting spaces (these should not be hardcoded in source markdown files)
  - [X] Check for tabs
  - [X] Check for a line that ends with space(s), followed by single newline (indicates ambiguous intention as to whether this should be a new paragraph [a full blank line is recommended here] or the same paragraph [the newline should be removed])
  - [X] Check for items that should be italicized (items are user-defined in metadata)
- [ ] Remove YAML headers from markdowns files
- [X] Add configurable copyright page templates
  - [X] Add creative commons templates
  - [ ] Add commercial templates
- [X] Add configurable bibliography page templates
  - [X] Add default LaTeX template
  - [X] Add default HTML template
- [X] Add configurable author biography page templates
  - [X] Add default LaTeX template
  - [X] Add default HTML template
- [X] Add header to start of chapters if missing (based on parent folder name)
- [X] Add formatting to print output
  - [X] Format start of chapter with drop cap and smart caps
  - [X] Add flourishes between scene breaks/POV changes
  - [X] Unindent starting paragraph of new scenes/POV changes
- [ ] Add formatting to epub/mobi output
  - [X] Format start of chapter with drop cap and smart caps
  - [ ] Add flourishes between scene breaks/POV changes
- [X] Add draft (Word) output
- [X] Add ability to build from multiple markdown files (instead of monolith Chapters.md)
  - [X] Support [Manuskript](https://github.com/olivierkes/manuskript) folder structure
- [X] Support for [CriticMarkup](https://github.com/CriticMarkup/CriticMarkup-toolkit)