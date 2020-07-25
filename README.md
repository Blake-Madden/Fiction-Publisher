## What is Fiction Publisher
**Fiction Publisher** is a fork of [Open Publisher](https://github.com/chrisanthropic/Open-Publisher), redesigned to work with [Manuskript](https://github.com/olivierkes/manuskript) projects. It is a PowerShell script that wraps Pandoc, KindleGen, and LaTeX and uses a set of custom Pandoc templates (created with a focus on fiction).

Write your manuscript in markdown, run a script, and receive some beautifully formatted ePub, Mobi, and print-ready PDF books.

Full documentation on the [wiki](https://github.com/Blake-Eryx/Fiction-Publisher/wiki).

## Fiction Publisher v2 Roadmap

- [X] Remove Jekyll dependency
- [X] Create PowerShell new project script
- [X] Create PowerShell build script
  - [X] PDF (print)
  - [X] epub
  - [X] mobi
- [X] Add markdown validations
  - [X] Check for paragraphs not separated by blank lines
  - [X] Check for straight quotes
  - [X] Check for '--'
  - [X] Check for Unicode ellipsis (should be spaced periods)
  - [X] Check for en dash at the end of a quote (should be an em dash)
  - [X] Check for extra spaces
  - [X] Check for tabs
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
  - [ ] Add swash font style to drop cap
  - [X] Add flourishes between scene breaks
  - [X] Unindent starting paragraph of new scenes
- [ ] Add formatting to epub/mobi output
  - [X] Format start of chapter with drop cap and smart caps
  - [ ] Add swash font style to drop cap
  - [ ] Add flourishes between scene breaks
- [X] Add draft (Word) output
- [X] Add ability to build from multiple markdown files (instead of monolith Chapters.md)
  - [X] Support [Manuskript](https://github.com/olivierkes/manuskript) folder structure
