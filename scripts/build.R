#!/usr/bin/env Rscript
# build.R - Batch compile xaringan slide decks
#
# Usage:
#   Rscript build.R              # compile all slides
#   Rscript build.R d03_dataviz  # compile a specific deck
#   Rscript build.R --changed    # compile only decks with modified .Rmd files
#   Rscript build.R --dry-run    # list what would be compiled without doing it
#   Rscript build.R --index      # rebuild only the index page

suppressPackageStartupMessages(library(rmarkdown))

args <- commandArgs(trailingOnly = TRUE)

# --- Configuration -----------------------------------------------------------

# Directories to skip (templates, archives, alternative formats)
SKIP_DIRS <- c("d00_template", "alt", "img", "templates", "libs")

# --- Helpers ------------------------------------------------------------------

find_slide_decks <- function(base_dir = ".") {
  rmd_files <- list.files(base_dir, pattern = "\\.Rmd$", recursive = TRUE,
                          full.names = TRUE)
  # Keep only files inside d##_ directories or workshop/
  rmd_files <- rmd_files[grepl("^\\./d\\d|^\\./workshop/", rmd_files)]
  # Exclude skip dirs
  for (skip in SKIP_DIRS) {
    rmd_files <- rmd_files[!grepl(paste0("/", skip, "/"), rmd_files)]
  }
  # Exclude setup.Rmd and index.Rmd (not slide decks)
  rmd_files <- rmd_files[!grepl("setup\\.Rmd$|index\\.Rmd$", rmd_files)]
  rmd_files
}

needs_rebuild <- function(rmd_path) {
  html_path <- sub("\\.Rmd$", ".html", rmd_path)
  if (!file.exists(html_path)) return(TRUE)
  file.mtime(rmd_path) > file.mtime(html_path)
}

compile_deck <- function(rmd_path) {
  deck_dir <- dirname(rmd_path)
  rmd_file <- basename(rmd_path)
  cat(sprintf("  Compiling: %s\n", rmd_path))
  tryCatch({
    rmarkdown::render(
      input = rmd_path,
      output_dir = deck_dir,
      quiet = TRUE,
      envir = new.env(parent = globalenv())
    )
    cat(sprintf("  ✓ Done: %s\n", sub("\\.Rmd$", ".html", rmd_path)))
    TRUE
  }, error = function(e) {
    cat(sprintf("  ✗ FAILED: %s\n    %s\n", rmd_path, conditionMessage(e)))
    FALSE
  })
}

# --- Main ---------------------------------------------------------------------

dry_run   <- "--dry-run" %in% args
index_only <- "--index" %in% args
changed   <- "--changed" %in% args
targets   <- args[!grepl("^--", args)]

if (index_only) {
  cat("Rebuilding index.Rmd...\n")
  if (!dry_run) {
    rmarkdown::render("index.Rmd", quiet = TRUE)
  }
  cat("Done.\n")
  quit(status = 0)
}

all_decks <- find_slide_decks()

if (length(targets) > 0) {
  # Filter to matching targets (partial match on directory name)
  all_decks <- all_decks[Reduce(`|`, lapply(targets, function(t) grepl(t, all_decks)))]
}

if (changed) {
  all_decks <- all_decks[sapply(all_decks, needs_rebuild)]
}

if (length(all_decks) == 0) {
  cat("Nothing to compile.\n")
  quit(status = 0)
}

cat(sprintf("Found %d slide deck(s) to compile:\n", length(all_decks)))
for (f in all_decks) cat(sprintf("  - %s\n", f))

if (dry_run) {
  cat("\n(Dry run - no files compiled.)\n")
  quit(status = 0)
}

cat("\nCompiling...\n")
results <- sapply(all_decks, compile_deck)

n_ok   <- sum(results)
n_fail <- sum(!results)
cat(sprintf("\nResults: %d succeeded, %d failed out of %d total.\n",
            n_ok, n_fail, length(results)))

if (n_fail > 0) {
  cat("\nFailed decks:\n")
  for (f in names(results[!results])) cat(sprintf("  - %s\n", f))
  quit(status = 1)
}
