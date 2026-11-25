# Rebuilds 'docs/example-pages.png' from the example book's print PDF,
# and 'docs/chapter-headings.png' by building a one-chapter book with each heading theme.
# (Just for use by this library's maintainer.)
# Build the example and then run this script:
#   pwsh -File Build.ps1 -BookFolder Example
#   Rscript docs/Make-ExamplePages.R

library(pdftools)
library(magick)

args <- commandArgs(trailingOnly = FALSE)
scriptFile <- sub("^--file=", "", args[grep("^--file=", args)])
docsDir <- if (length(scriptFile) == 1) dirname(normalizePath(scriptFile)) else "docs"
repoDir <- normalizePath(file.path(docsDir, ".."))
pdfFile <- file.path(repoDir, "Example", "Fiction-Publisher-Output", "Example-print.pdf")

if (!file.exists(pdfFile))
  stop("Example PDF not found. Build the Example first: ", pdfFile)

gap <- 16
background <- "#E0E0E0"
pageBorder <- "#A0A0A0"

# returns whether a rendered page bitmap has any ink on it
isInk <- function(bitmap)
  {
  # unclass() so that magick's as.integer() for bitmaps doesn't reorder the pixels
  values <- array(as.integer(unclass(bitmap)), dim(bitmap))
  values[1, , ] < 245 | values[2, , ] < 245 | values[3, , ] < 245
  }

# lays the images out in rows, centering a short last row
layoutGrid <- function(cells, perRow)
  {
  cellWidth <- max(sapply(cells, function(p) image_info(p)$width))
  cellHeight <- max(sapply(cells, function(p) image_info(p)$height))
  sheetWidth <- perRow * cellWidth + (perRow + 1) * gap

  rows <- list()
  for (start in seq(1, length(cells), by = perRow))
    {
    rowCells <- cells[start:min(start + perRow - 1, length(cells))]
    # pad each cell to the same size so that rounding diffs don't leave gaps
    rowCells <- lapply(rowCells, function(p)
      image_border(image_extent(p, paste0(cellWidth, "x", cellHeight),
                                gravity = "north", color = background),
                   background, paste0(gap / 2, "x0")))
    row <- image_append(do.call(c, rowCells))
    rows[[length(rows) + 1]] <- image_extent(row, paste0(sheetWidth, "x", cellHeight + gap),
                                             gravity = "north", color = background)
    }

  sheet <- image_append(do.call(c, rows), stack = TRUE)
  sheet <- image_border(sheet, background, paste0("0x", gap / 2))
  image_extent(sheet, paste0(sheetWidth, "x", image_info(sheet)$height + gap / 2),
               gravity = "north", color = background)
  }

###############################################################
# example pages
###############################################################

# render each page, but leave out the blank ones
pageWidth <- 340
pages <- list()
for (i in seq_len(pdf_info(pdfFile)$pages))
  {
  bitmap <- pdf_render_page(pdfFile, page = i, dpi = 150)
  if (!any(isInk(bitmap)))
    next
  page <- image_read(bitmap)
  page <- image_background(page, "white")
  page <- image_resize(page, paste0(pageWidth, "x"))
  pages[[length(pages) + 1]] <- image_border(page, pageBorder, "1x1")
  }

outFile <- file.path(docsDir, "example-pages.png")
image_write(layoutGrid(pages, 5), outFile, format = "png")
cat("Wrote", normalizePath(outFile), "with", length(pages), "pages\n")

###############################################################
# chapter headings
###############################################################

headingThemes <- c("art-deco", "blockletter", "classic", "default", "fantasy", "marker", "minimal",
                   "noir", "oldwest", "romance-calligraphy", "romance-cursive", "scifi", "side-by-side", "watermark")
headingWidth <- 560
labelHeight <- 40

# a small book with one clean chapter for each theme
bookDir <- file.path(tempdir(), "ChapterHeadings")
unlink(bookDir, recursive = TRUE)
chapterDir <- file.path(bookDir, "outline", "01-A_Dark_and_Stormy_Night")
dir.create(chapterDir, recursive = TRUE)
writeLines(c(
  "It was a dark and stormy night. The rain fell in torrents---except at occasional intervals, when it was checked by a violent gust of wind that rattled the shutters of the old harbor house.",
  "",
  "Mabel pressed her nose to the window and read the *Gazette*'s headline for the third time. She had lived through the great storms of 1887--1889, and none of them had sounded quite like this."),
  file.path(chapterDir, "01-Scene.md"))

cells <- list()
for (theme in headingThemes)
  {
  writeLines(c(
    "---",
    "title: A Dark and Stormy Night",
    "author: A. N. Author",
    "lang: en-US",
    "date: 2026-11-08",
    "year: 2026",
    "rights: All rights reserved.",
    "toc: false",
    "build-draft: false",
    "build-epub: false",
    "build-amazon-epub: false",
    paste0("chapter-heading: ", theme),
    "---"),
    file.path(bookDir, "config.yml"))

  status <- system2("pwsh", c("-NoProfile", "-File", shQuote(file.path(repoDir, "Build.ps1")),
                              "-BookFolder", shQuote(bookDir)), stdout = FALSE, stderr = FALSE)
  headingPdf <- file.path(bookDir, "Fiction-Publisher-Output", "ChapterHeadings-print.pdf")
  if (status != 0 || !file.exists(headingPdf))
    stop("Building the '", theme, "' chapter heading failed; see ", file.path(bookDir, "Fiction-Publisher-Output"))

  # the chapter's opening page, cropped from just above its heading
  chapterPage <- grep("dark and stormy night. The rain", pdf_text(headingPdf), fixed = TRUE)[1]
  bitmap <- pdf_render_page(headingPdf, page = chapterPage, dpi = 200)
  ink <- isInk(bitmap)
  inkCols <- which(rowSums(ink) > 0)
  inkRows <- which(colSums(ink) > 0)
  pad <- 50
  left <- max(min(inkCols) - pad, 0)
  right <- min(max(inkCols) + pad, dim(bitmap)[2])
  top <- max(min(inkRows) - pad, 0)
  cropWidth <- right - left
  cropHeight <- round(cropWidth * 0.71)

  page <- image_background(image_read(bitmap), "white")
  page <- image_repage(image_crop(page, sprintf("%dx%d+%d+%d", cropWidth, cropHeight, left, top)))
  page <- image_resize(page, paste0(headingWidth, "x"))
  page <- image_border(page, pageBorder, "1x1")

  label <- image_blank(image_info(page)$width, labelHeight, background)
  label <- image_annotate(label, theme, font = "Consolas", size = 20, color = "#333333",
                          gravity = "center")
  cells[[length(cells) + 1]] <- image_append(c(page, label), stack = TRUE)
  cat("Built the", theme, "chapter heading\n")
  }

unlink(bookDir, recursive = TRUE)
outFile <- file.path(docsDir, "chapter-headings.png")
image_write(layoutGrid(cells, 3), outFile, format = "png")
cat("Wrote", normalizePath(outFile), "with", length(cells), "chapter headings\n")
