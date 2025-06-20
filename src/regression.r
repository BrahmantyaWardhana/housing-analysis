#setwd("")
#source("")

library(tidyverse)
library(corrplot)
library(broom)

train <- read.csv("dataset/train.csv")
test <- read.csv("dataset/test.csv")

# analyzing dataset
# Check missing values
colSums(is.na(train)) %>% sort(decreasing = TRUE)

# Plot SalePrice distribution
ggplot(train, aes(x = SalePrice)) + 
  geom_histogram(fill = "blue", bins = 50) +
  labs(title = "Distribution of SalePrice")


# vars for regression, take only numeric values
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
  model.regression
}

print(summary(simple_regression()))

simple_regression_final <- function () {
  # find significant predictors
  predictors <- tidy(simple_regression()) %>%
    filter(term != "(Intercept)") %>%
    filter(p.value < 0.05) %>%
    pull(term)
  
  formula_str <- paste("SalePrice ~", paste(predictors, collapse = " + "))
  model.regression.final <- lm(formula_str, data = numeric_vars)
  
  model.regression.final
}

print(summary(simple_regression_final()))

predicting_data <- function() {
  final_model <- simple_regression_final()
  
  # Prepare test data
  test_numeric <- test %>% 
    select_if(is.numeric) %>%
    select(-GarageYrBlt) %>%
    mutate(
      LotFrontage = ifelse(is.na(LotFrontage), median(LotFrontage, na.rm = TRUE), LotFrontage),
      MasVnrArea = ifelse(is.na(MasVnrArea), median(MasVnrArea, na.rm = TRUE), MasVnrArea)
    )
  
  # Make predictions
  predictions <- predict(final_model, newdata = test_numeric)
  
  # Return results as a dataframe
  data.frame(Id = test$Id, SalePrice = predictions)
}

create_submission <- function() {
  predictions <- predicting_data()
  
  # Ensure directory exists
  if (!dir.exists("submissions")) {
    dir.create("submissions")
  }
  
  # Create timestamped filename
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  filename <- paste0("submissions/submission_", timestamp, ".csv")
  
  # Write file
  write.csv(predictions, filename, row.names = FALSE)
  message(paste("Submission file created:", filename))
  
  return(predictions)
}

submission <- create_submission()