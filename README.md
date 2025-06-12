# Summary

Analyzing housing prices using linear regression using r. Dataset taken from [Link](https://www.kaggle.com/c/house-prices-advanced-regression-techniques/overview)

# Linear Regression

## Preprocessing data

Numerical were collected for modeling and preprocessing revealed that there were **missing/invalid** data. These missing data were simply substituted with the median of their respective classes.

Initial modelling was done with all **numerical** predictors:

- `MSSubClass`
- `LotFrontage`
- `LotArea`
- `OverallQual`
- `OverallCond`
- `YearBuilt`
- `YearRemodAdd`
- `MasVnrArea`
- `BsmtFinSF1`
- `BsmtFinSF2`
- `BsmtUnfSF`
- `TotalBsmtSF`
- `X1stFlrSF`
- `X2ndFlrSF`
- `LowQual`

## Model evaluation

Using `summary()` on the newly created linear regression model revealed these model fit statistics:

```
Residual standard error: 34780

Multiple R-squared: 0.8127

Adjusted R-squared: 0.8084
```

The `summary()` also revealed that some predictors have **multicolinearity** and are more significant than others based on their **p-values**.

_full `summary` output:_

```
Call:
lm(formula = SalePrice ~ . - Id, data = numeric_vars)

Residuals:
    Min      1Q  Median      3Q     Max
-469705  -16674   -2121   13685  304327

Coefficients: (2 not defined because of singularities)
                Estimate Std. Error t value Pr(>|t|)
(Intercept)    5.236e+05  1.414e+06   0.370 0.711303
MSSubClass    -1.795e+02  2.767e+01  -6.487 1.20e-10 ***
LotFrontage   -5.806e+01  5.172e+01  -1.123 0.261797
LotArea        4.235e-01  1.021e-01   4.148 3.56e-05 ***
OverallQual    1.740e+04  1.188e+03  14.650  < 2e-16 ***
OverallCond    4.406e+03  1.023e+03   4.306 1.77e-05 ***
YearBuilt      3.224e+02  6.094e+01   5.290 1.41e-07 ***
YearRemodAdd   1.692e+02  6.602e+01   2.563 0.010490 *
MasVnrArea     3.133e+01  5.938e+00   5.277 1.52e-07 ***
BsmtFinSF1     1.908e+01  4.670e+00   4.085 4.66e-05 ***
BsmtFinSF2     7.832e+00  7.059e+00   1.110 0.267379
BsmtUnfSF      9.339e+00  4.197e+00   2.225 0.026239 *
TotalBsmtSF           NA         NA      NA       NA
X1stFlrSF      4.840e+01  5.805e+00   8.338  < 2e-16 ***
X2ndFlrSF      4.857e+01  4.981e+00   9.750  < 2e-16 ***
LowQualFinSF   3.098e+01  1.975e+01   1.569 0.116918
GrLivArea             NA         NA      NA       NA
BsmtFullBath   9.332e+03  2.614e+03   3.570 0.000368 ***
BsmtHalfBath   1.761e+03  4.091e+03   0.430 0.666961
FullBath       3.970e+03  2.825e+03   1.405 0.160107
HalfBath      -1.812e+03  2.665e+03  -0.680 0.496749
BedroomAbvGr  -1.026e+04  1.701e+03  -6.032 2.06e-09 ***
KitchenAbvGr  -1.210e+04  5.216e+03  -2.321 0.020451 *
TotRmsAbvGrd   5.132e+03  1.237e+03   4.148 3.55e-05 ***
Fireplaces     3.605e+03  1.766e+03   2.041 0.041472 *
GarageCars     1.063e+04  2.856e+03   3.721 0.000206 ***
GarageArea    -6.667e-01  9.739e+00  -0.068 0.945430
WoodDeckSF     2.514e+01  7.991e+00   3.146 0.001691 **
OpenPorchSF   -1.136e+00  1.516e+01  -0.075 0.940312
EnclosedPorch  1.168e+01  1.688e+01   0.692 0.489024
X3SsnPorch     2.025e+01  3.142e+01   0.645 0.519333
ScreenPorch    5.527e+01  1.720e+01   3.213 0.001341 **
PoolArea      -3.044e+01  2.382e+01  -1.278 0.201447
MiscVal       -7.344e-01  1.856e+00  -0.396 0.692469
MoSold        -5.723e+01  3.450e+02  -0.166 0.868279
YrSold        -7.720e+02  7.031e+02  -1.098 0.272343
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 34780 on 1426 degrees of freedom
Multiple R-squared:  0.8127,	Adjusted R-squared:  0.8084
F-statistic: 187.5 on 33 and 1426 DF,  p-value: < 2.2e-16

```

The model will be retrained only with significant predictors based on their **p-values** (`p < 0.05`):

- `OverallQual`
- `MSSubClass`
- `LotArea`
- `YearBuilt`
- `MasVnrArea`
- `BsmtFinSF1`
- `X1stFlrSF`
- `X2ndFlrSF`
- `BedroomAbvGr`
- `TotRmsAbvGrd`
- `GarageCars`
- `WoodDeckSF`
- `ScreenPorch`
- `OverallCond`
- `BsmtFullBath`
- `YearRemodAdd`
- `BsmtUnfSF`
- `KitchenAbvGr`
- `Fireplaces`

### Notes:

Predictors `TotalBsmtSF` and `GrLivArea` showed singularities and should be investigated for multicollinearity

## Predicting with test data

`regression_evaluate_train.r` was created for **cross validation**. `Q1`, `Q3`, `mean`, `median`, `sd`, `rse`, and `rmse` were measured

```
Q1 = -16958.71
Q3 = 17236.49
mean = 2323.698
median = 1655.94
sd = 30372.04
rse = 31391.85
rmse = 30408.91
```

The high variance in residuals indicates that the model
