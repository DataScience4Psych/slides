#!/usr/bin/env Rscript
# validate.R - Check slide deck repository for common issues
#
# Usage:
#   Rscript validate.R           # run all checks
#   Rscript validate.R --fix     # show suggested fixes

suppressPackageStartupMessages({
  library(yaml)
})

args <- commandArgs(trailingOnly = TRUE)
show_fixes <- "--fix" %in% args

issues <- list()
warnings_list <- list()

add_issue <- function(file, msg, fix = NULL) {
  issues[[length(issues) + 1]] <<- list(file = file, msg = msg, fix = fix)
}

add_warning <- function(file, msg) {
  warnings_list[[length(warnings_list) + 1]] <<- list(file = file, msg = msg)
}

# --- Find all slide Rmd files ------------------------------------------------

SKIP_DIRS <- c("d00_template", "alt", "img", "templates")

rmd_files <- list.files(".", pattern = "\\.Rmd$", recursive = TRUE,
                        full.names = TRUE)
rmd_files <- rmd_files[grepl("^\\./d\\d|^\\./workshop/", rmd_files)]
for (skip in SKIP_DIRS) {
  rmd_files <- rmd_files[!grepl(paste0("/", skip, "/"), rmd_files)]
}
rmd_files <- rmd_files[!grepl("setup\\.Rmd$|index\\.Rmd$", rmd_files)]

cat(sprintf("Validating %d slide decks...\n\n", length(rmd_files)))

# --- Check 1: YAML header consistency ----------------------------------------

cat("1. Checking YAML headers...\n")
for (f in rmd_files) {
  lines <- readLines(f, warn = FALSE)
  yaml_start <- which(lines == "---")[1]
  yaml_end   <- which(lines == "---")[2]

  if (is.na(yaml_start) || is.na(yaml_end)) {
    add_issue(f, "Missing or malformed YAML header")
    next
  }

  yaml_text <- paste(lines[(yaml_start + 1):(yaml_end - 1)], collapse = "\n")
  header <- tryCatch(yaml::yaml.load(yaml_text), error = function(e) NULL)

  if (is.null(header)) {
    add_issue(f, "YAML header failed to parse")
    next
  }

  # Check for xaringan output
  output <- header$output
  if (is.null(output) || is.null(output$`xaringan::moon_reader`)) {
    add_warning(f, "Not using xaringan::moon_reader output format")
    next
  }

  moon <- output$`xaringan::moon_reader`

  # Check CSS reference
  css <- moon$css
  if (is.null(css) || !any(grepl("slides\\.css", css))) {
    add_warning(f, "Missing ../slides.css in CSS references")
  }

  # Check ratio
  nature <- moon$nature
  if (!is.null(nature) && !is.null(nature$ratio) && nature$ratio != "16:9") {
    add_warning(f, sprintf("Non-standard ratio: %s (expected 16:9)", nature$ratio))
  }
}

# --- Check 2: Setup chunk inclusion -------------------------------------------

cat("2. Checking setup.Rmd inclusion...\n")
for (f in rmd_files) {
  content <- readLines(f, warn = FALSE)
  has_setup <- any(grepl('child\\s*=\\s*["\']\\.\\.(/|\\\\)setup\\.Rmd["\']', content))
  if (!has_setup) {
    add_issue(f, "Missing setup.Rmd child inclusion",
              fix = 'Add: ```{r child = "../setup.Rmd"}\\n```')
  }
}

# --- Check 3: HTML output freshness ------------------------------------------

cat("3. Checking HTML output freshness...\n")
for (f in rmd_files) {
  html_path <- sub("\\.Rmd$", ".html", f)
  if (!file.exists(html_path)) {
    add_issue(f, "No compiled HTML output found",
              fix = sprintf("Run: Rscript build.R %s", dirname(f)))
  } else if (file.mtime(f) > file.mtime(html_path)) {
    add_warning(f, "Rmd is newer than HTML - needs recompilation")
  }
}

# --- Check 4: Directory/file naming consistency -------------------------------

cat("4. Checking naming conventions...\n")
dirs <- list.dirs(".", recursive = FALSE)
slide_dirs <- dirs[grepl("^\\./d\\d+", dirs)]
for (d in slide_dirs) {
  dir_name <- basename(d)
  expected_rmd <- file.path(d, paste0(dir_name, ".Rmd"))
  if (!file.exists(expected_rmd)) {
    actual_rmds <- list.files(d, pattern = "\\.Rmd$", full.names = TRUE)
    actual_rmds <- actual_rmds[!grepl("setup\\.Rmd$", actual_rmds)]
    if (length(actual_rmds) > 0) {
      for (r in actual_rmds) {
        rmd_base <- tools::file_path_sans_ext(basename(r))
        if (rmd_base != dir_name) {
          add_warning(r, sprintf(
            "Filename '%s' doesn't match directory '%s'", basename(r),
            paste0(dir_name, ".Rmd")))
        }
      }
    }
  }
}

# --- Check 5: Duplicate numbering --------------------------------------------

cat("5. Checking for duplicate numbering...\n")
dir_numbers <- list()
for (d in slide_dirs) {
  dir_name <- basename(d)
  m <- regmatches(dir_name, regexpr("^d\\d+(\\.\\d+)?", dir_name))
  if (length(m) > 0) {
    num <- m[1]
    if (num %in% names(dir_numbers)) {
      dir_numbers[[num]] <- c(dir_numbers[[num]], dir_name)
    } else {
      dir_numbers[[num]] <- dir_name
    }
  }
}
for (num in names(dir_numbers)) {
  if (length(dir_numbers[[num]]) > 1) {
    add_issue(
      paste(dir_numbers[[num]], collapse = ", "),
      sprintf("Duplicate slide number '%s' used by multiple directories", num))
  }
}

# --- Report -------------------------------------------------------------------

cat("\n")
cat(paste(rep("=", 60), collapse = ""), "\n")
cat("VALIDATION REPORT\n")
cat(paste(rep("=", 60), collapse = ""), "\n\n")

if (length(issues) > 0) {
  cat(sprintf("ISSUES (%d):\n", length(issues)))
  for (i in issues) {
    cat(sprintf("  [!] %s\n      %s\n", i$file, i$msg))
    if (show_fixes && !is.null(i$fix)) {
      cat(sprintf("      Fix: %s\n", i$fix))
    }
  }
  cat("\n")
}

if (length(warnings_list) > 0) {
  cat(sprintf("WARNINGS (%d):\n", length(warnings_list)))
  for (w in warnings_list) {
    cat(sprintf("  [~] %s\n      %s\n", w$file, w$msg))
  }
  cat("\n")
}

if (length(issues) == 0 && length(warnings_list) == 0) {
  cat("All checks passed!\n")
} else {
  cat(sprintf("Total: %d issues, %d warnings across %d slide decks.\n",
              length(issues), length(warnings_list), length(rmd_files)))
}

quit(status = if (length(issues) > 0) 1 else 0)
