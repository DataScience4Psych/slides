## Workshop: Data Science for Psychologists in R

### Hour 1: Introduction to R and Data Manipulation with base R and the tidyverse

- Introduction to R and its capabilities in data science
- Overview of the tidyverse ecosystem and its key packages (e.g., dplyr, tidyr)
- Exploring data manipulation using base R functions
- Data wrangling with dplyr: filtering, selecting, mutating, summarizing, and arranging data
- Reshaping data with tidyr: pivot_longer and pivot_wider functions
- Hands-on exercises and examples to practice data manipulation skills

### Hour 2: Data Wrangling and Transformation

- Recap of data manipulation with the tidyverse
- Dealing with missing data: identifying missing values, handling missing data with tidyr and dplyr
- Data transformation: creating new variables, applying functions, and working with dates and times
- Handling categorical variables: factor levels, recoding, and creating dummy variables
- Combining and merging datasets: joining tables based on common keys
- Case study and practical exercises on data wrangling

### Hour 3: Data Visualization and Communication

- Introduction to data visualization and its importance in data science
- Overview of ggplot2 and its grammar of graphics
- Creating basic visualizations: scatter plots, bar plots, histograms, and line plots
- Customizing plots: adding titles, labels, colors, and themes
- Creating advanced visualizations: faceting, layering, and adding statistical transformations
- Interactive visualizations with ggplot2 extensions (e.g., plotly, gganimate)
- Best practices for data visualization and effective communication of results
- Hands-on exercises and examples to create meaningful visualizations

Throughout the workshop, there will be interactive coding exercises, case studies, and opportunities for participants to apply their knowledge and ask questions. By following this structure, participants will gain a solid foundation in R programming, data manipulation, and data visualization for data science tasks.

## Toolkit

Slides are built in using the **xaringan** package. See [here](https://github.com/yihui/xaringan) for more info on xaringan. There are two main reasons for choosing this format:

1. `xaringan` slides are R Markdown based, meaning code, output, and narrative can all live in one place and compiling the slides will run the R code as well.
2. Slide output is mobile friendly.

### Instructions

- Each slide deck is in its own folder, and one level above there is a custom css file. To compile the slides use `xaringan::inf_mr(cast_from = "..")`. This will launch the slides in the Viewer, and it will get updated as you edit and save your work.
