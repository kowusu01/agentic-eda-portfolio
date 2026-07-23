library(tidyverse)
data("mtcars")

library(arrow)
str(mtcars)

p1 <- ggplot(mtcars, aes(x = wt, y = mpg)) + 
  geom_point()

saveRDS(p1,"mtcars.RDS")