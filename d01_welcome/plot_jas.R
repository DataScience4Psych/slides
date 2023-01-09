#adapted from: https://towardsdatascience.com/getting-started-with-generative-art-in-r-3bc50067d34b
library(dplyr) # or install.packages("dplyr") first
library(jasmines) # or devtools::install_github("djnavarro/jasmines")
p0 <- use_seed(1000) %>% # Set the seed of R‘s random number generator, which is useful for creating simulations or random objects that can be reproduced.
  scene_discs(
    rings = 10,
    points = 50000,
    size = 50
  ) %>%
  mutate(ind = 1:n()) %>%
  unfold_warp(
    iterations = 10,
    scale = .5,
    output = "layer"
  ) %>%
  unfold_tempest(
    iterations = 5,
    scale = .015
  ) %>%
  style_ribbon(
    color = "#F26BAA",
    colour = "ind",
    alpha = c(1,1),
    background = "#34c9f4"
  )
ggsave("img/p0.png", p0, width = 20, height = 20, units = "in")
