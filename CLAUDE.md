# CLAUDE.md

## Project Overview

Educational slide decks for "Data Science for Psychologists" (DataScience4Psych). Built with R Markdown and **xaringan** for HTML presentations. Author: S. Mason Garrison. License: CC BY-SA 4.0.

## Tech Stack

- **R** + **xaringan** (HTML slide presentations from R Markdown)
- **tidyverse** ecosystem (dplyr, ggplot2, tidyr, stringr, etc.)
- **knitr** for dynamic code execution within slides
- CSS themes: `slides.css` (light) and `slides_dark.css` (dark)

## Project Structure

```
d01_welcome/ through d32_llmapplications/  # Numbered slide modules
workshop/                                   # Workshop materials
alt/                                        # Alternative slide formats
img/                                        # Shared images
templates/                                  # HTML/CSS templates
setup.Rmd                                   # Common setup chunk (included in ALL decks)
slides.css / slides_dark.css                # Custom CSS themes
index.Rmd                                   # Slide sitemap generator
references.bib                              # Bibliography
```

Each slide deck lives in its own `d##_name/` directory containing a `.Rmd` source and compiled `.html` output.

## Building Slides

Compile a slide deck from its directory:
```r
xaringan::inf_mr(cast_from = "..")
```
The `cast_from = ".."` is required to locate the CSS files in the parent directory. There is no automated CI/CD pipeline — slides are compiled manually.

## Key Conventions

### YAML Header (required for all slide decks)
```yaml
---
title: "Slide Title"
author: "S. Mason Garrison"
output:
  xaringan::moon_reader:
    css: "../slides.css"
    lib_dir: libs
    self_contained: TRUE
    nature:
      ratio: "16:9"
      highlightLines: true
      highlightStyle: solarized-light
      countIncrementalSlides: false
---
```

### Setup Chunk (required in every deck)
Every `.Rmd` slide deck must include:
```r
{r child = "../setup.Rmd"}
```
This provides: knitr options (fig width 8, aspect 0.618, DPI 400), ggplot2 theme (base_size 16), seed 1234, Font Awesome, dplyr::filter conflict resolution, and output line truncation hooks.

### Code Style
- Follow tidyverse conventions
- `echo = TRUE` by default (show code in slides)
- Figures: `out.width = "60%"`, centered
- Use `---` as xaringan slide separators
- Apply CSS classes for styling (e.g., `.bg_orange`, `.bg_dark_blue`)

### File Naming
- Slide decks: `d##_name/d##_name.Rmd` (e.g., `d03_dataviz/d03_dataviz.Rmd`)
- Workshop files: `workshop/d##_##_name.Rmd`
- Templates: `d00_template/`

## Common R Packages

Core: tidyverse, knitr, xaringan, rmarkdown, conflicted, gt, emo
Visualization: ggplot2, jasmines (GitHub), mathart (GitHub)
Install GitHub packages conditionally: check with `require()` first.

## What NOT to Do

- Do not remove `{r child = "../setup.Rmd"}` from any slide deck
- Do not change the 16:9 aspect ratio
- Do not modify `setup.Rmd` without understanding it affects ALL slide decks
- Do not commit `.RData`, `.Rproj.user`, or other gitignored artifacts
- Do not change CSS paths — they must use `../slides.css` (relative to deck directory)

## No Linting/Formatting Tools

There are no configured linters, formatters, or pre-commit hooks. Follow existing code style by example.
