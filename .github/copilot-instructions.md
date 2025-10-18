# GitHub Copilot Instructions for DataScience4Psych Slides

## Repository Overview

This repository contains slide decks for a Data Science course designed for psychology students. The slides are built using R Markdown and the **xaringan** package, which creates HTML presentations that are mobile-friendly and integrate code, output, and narrative in a single document.

## Technology Stack

- **R**: Primary programming language
- **xaringan**: R package for creating HTML presentations from R Markdown
- **R Markdown**: Document format combining R code with narrative text
- **tidyverse**: Collection of R packages for data science (dplyr, ggplot2, etc.)
- **knitr**: R package for dynamic report generation

## Project Structure

- Each slide deck is located in its own directory (e.g., `d01_welcome/`, `d02_toolkit/`, etc.)
- Slide decks are numbered with a `d##_` prefix indicating their sequence
- Each directory contains:
  - A main `.Rmd` file (e.g., `d01_welcome.Rmd`) with the slide content
  - Generated `.html` output file
  - Supporting files (images, R scripts, etc.) in subdirectories
- Shared resources:
  - `setup.Rmd`: Common setup chunk included in all slide decks
  - `slides.css` and `slides_dark.css`: Custom CSS styling
  - `index.Rmd`: Generates a sitemap of all slides

## Building and Compiling Slides

To compile a slide deck:

1. Open the `.Rmd` file in RStudio
2. Run: `xaringan::inf_mr(cast_from = "..")`
3. This launches the slides in the Viewer and auto-updates as you edit

The `cast_from = ".."` parameter is important as it references the parent directory where custom CSS files are located.

## Code Conventions

### R Markdown YAML Headers

Standard slide deck headers should include:
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

### Setup Chunk

All slide decks include the common setup:
```r
{r child = "../setup.Rmd"}
```

This provides:
- Standard knitr options (figure dimensions, DPI, etc.)
- Consistent ggplot2 theme (base size 16)
- Seed setting for reproducibility
- Package conflict resolution (e.g., preferring dplyr::filter)

### Code Style

- Use tidyverse conventions for R code
- Set `echo = TRUE` by default in code chunks to show code
- Figure dimensions: width = 8, aspect ratio = 0.618, out.width = "60%"
- DPI = 400 for high-quality figures
- Enable duplicate labels with `knitr.duplicate.label = "allow"`

## Common Packages

The repository uses various R packages including:
- **tidyverse**: Core data science packages (dplyr, ggplot2, tidyr, etc.)
- **emo**: For emoji support in slides
- **conflicted**: For managing package function conflicts
- **gt**: For creating formatted tables
- **various visualization packages**: jasmines, mathart (installed from GitHub)

## Git and Version Control

### Files to Ignore

The `.gitignore` includes:
- R workspace files (`.RData`, `.Rproj.user`)
- Generated files (`.svg`, `.utf8.md`)
- Archive and alternative versions
- Specific excluded slides and workshop archives

### File Naming

- Slide decks use the pattern: `d##_name/d##_name.Rmd`
- Workshop materials are in the `workshop/` directory
- Templates are in `d00_template/`

## Best Practices for Contributing

1. **Maintain consistency**: Follow existing naming conventions and structure
2. **Include setup**: Always include `{r child = "../setup.Rmd"}` in new slides
3. **Use relative paths**: Reference CSS files with `../slides.css`
4. **Test compilation**: Compile slides with `xaringan::inf_mr(cast_from = "..")` before committing
5. **Self-contained output**: Keep `self_contained: TRUE` in YAML headers for portability
6. **Preserve formatting**: Maintain the 16:9 aspect ratio for consistency
7. **Package management**: Install GitHub packages conditionally (check with `require()` first)

## Slide Content Guidelines

- Use xaringan slide separators (`---`) between slides
- Apply custom CSS classes as needed (e.g., `.bg_orange` for backgrounds)
- Include alt text and accessibility considerations
- Maintain mobile-friendly layouts
- Keep code chunks readable with appropriate options

## Working with Custom CSS

The repository uses two CSS themes:
- `slides.css`: Light theme
- `slides_dark.css`: Dark theme

Custom CSS classes are defined within individual `.Rmd` files using CSS chunks when needed for specific visual effects.

## Additional Notes

- The course is divided into three parts: exploratory data analysis, statistical tools (modeling/inference), and advanced topics
- Slides are designed to be both educational and visually engaging
- The repository includes workshop materials in addition to lecture slides
- Some slides include interactive elements and visualizations
