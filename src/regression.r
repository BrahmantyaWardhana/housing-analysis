#setwd("")
#source("")

library(tidyverse)
library(corrplot)

train <- read.csv("dataset/train.csv")
test <- read.csv("dataset/test.csv")

# analyzing dataset
# Check missing values
colSums(is.na(train)) %>% sort(decreasing = TRUE)

# Plot SalePrice distribution
ggplot(train, aes(x = SalePrice)) + 
  geom_histogram(fill = "blue", bins = 50) +
  labs(title = "Distribution of SalePrice")


# vars for regression, take only numeric values and
# 
numeric_vars <- train %>% select_if(is.numeric)
#print(colSums(is.na(numeric_vars)) %>% sort(decreasing = TRUE))

# use median to replace missing values
numeric_vars <- numeric_vars %>%
  mutate(
    LotFrontage = ifelse(is.na(LotFrontage), median(LotFrontage, na.rm = TRUE), LotFrontage),
    MasVnrArea = ifelse(is.na(MasVnrArea), median(MasVnrArea, na.rm = TRUE), MasVnrArea)
  )

# remove GarageYrBlt
numeric_vars <- numeric_vars %>% select(-GarageYrBlt)
colSums(is.na(numeric_vars)) %>% sort(decreasing = TRUE)

simple_regression <- function () {
  model.regression <- lm(SalePrice ~ . - Id, data = numeric_vars)
  summary <- summary(model.regression)
  summary
}