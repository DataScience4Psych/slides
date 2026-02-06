# Makefile for managing xaringan slide decks
#
# Usage:
#   make list          - List all slide decks
#   make validate      - Run repo health checks
#   make build-all     - Compile all slide decks
#   make build-changed - Compile only modified decks
#   make build DECK=d03_dataviz  - Compile a specific deck
#   make index         - Rebuild the slide index page
#   make clean-cache   - Remove knitr cache directories
#   make deps          - Install R package dependencies
#   make status        - Show which decks need recompilation

.PHONY: list validate build-all build-changed build index clean-cache deps status help

help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

list: ## List all slide decks found in the repo
	@Rscript scripts/build.R --dry-run

validate: ## Run validation checks on all slide decks
	@Rscript scripts/validate.R

validate-fix: ## Run validation checks with suggested fixes
	@Rscript scripts/validate.R --fix

build-all: ## Compile all slide decks
	Rscript scripts/build.R

build-changed: ## Compile only decks with modified .Rmd files
	Rscript scripts/build.R --changed

build: ## Compile a specific deck (usage: make build DECK=d03_dataviz)
ifndef DECK
	$(error DECK is not set. Usage: make build DECK=d03_dataviz)
endif
	Rscript scripts/build.R $(DECK)

index: ## Rebuild the slide index/sitemap page
	Rscript scripts/build.R --index

clean-cache: ## Remove all knitr cache and intermediate files
	find . -type d -name "*_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*_files" -not -path "./.git/*" -exec rm -rf {} + 2>/dev/null || true
	@echo "Cache directories cleaned."

deps: ## Install R package dependencies from DESCRIPTION
	Rscript -e 'if (!requireNamespace("remotes", quietly=TRUE)) install.packages("remotes"); remotes::install_deps(dependencies=TRUE)'

status: ## Show which slide decks need recompilation
	@echo "Decks needing recompilation:"
	@Rscript -e '\
		rmds <- list.files(".", "\\.Rmd$$", recursive=TRUE, full.names=TRUE); \
		rmds <- rmds[grepl("^\\\\./d\\\\d", rmds)]; \
		rmds <- rmds[!grepl("d00_template|setup\\.Rmd", rmds)]; \
		for (f in rmds) { \
			h <- sub("\\.Rmd$$", ".html", f); \
			if (!file.exists(h)) cat("  [missing]", f, "\n") \
			else if (file.mtime(f) > file.mtime(h)) cat("  [stale]  ", f, "\n"); \
		}'
