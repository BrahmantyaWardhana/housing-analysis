#setwd("")
#source("")

set.seed(123)
library(tidyverse)
library(corrplot)
library(broom)

train <- read.csv("dataset/train.csv")
train_indices <- sample(1:nrow(train), 0.8 * nrow(train))  # 80% training, 20% validation
test <- train[-train_indices, ]
train <- train[train_indices, ]

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
  
  # Ensure test data has same columns as model
  required_vars <- all.vars(formula(final_model))[-1]
  missing_vars <- setdiff(required_vars, names(test_numeric))
  
  if(length(missing_vars) > 0) {
    warning(paste("Missing variables in test data:", paste(missing_vars, collapse = ", ")))
    # Add missing columns filled with
    test_numeric[missing_vars] <- NA
  }
  
  # Make predictions
  predictions <- predict(final_model, newdata = test_numeric)
  
  # Return results as a dataframe
  data.frame(Id = test$Id, SalePrice = predictions)
}

evaluate_predictions <- function() {
  pred <- predicting_data()

  # residuals
  eval_df <- data.frame(
    Actual = test$SalePrice,
    Predicted = pred$SalePrice
  )

  # basic metrics
  residuals <- eval_df$Actual - eval_df$Predicted
  
  MEAN <- mean(residuals)
  MEDIAN <- median(residuals)
  SD <- sd(residuals)
  Q1 <- quantile(residuals, 0.25)
  Q3 <- quantile(residuals, 0.75)

  RMSE = sqrt(mean(residuals^2))
  
  # Calculate RSE
  n <- nrow(eval_df)
  p <- length(coef(simple_regression_final())) - 1
  RSE <- sqrt(sum(residuals^2) / (n - p - 1))
  
  named_list <- list(q1 = Q1, q3 = Q3, mean = MEAN, median = MEDIAN,
                     sd = SD, rse = RSE, rmse = RMSE)
  named_list
}

median_baseline_pred <- median(train$SalePrice)  
print(baseline_rmse <- sqrt(mean((test$SalePrice - median_baseline_pred)^2)))
