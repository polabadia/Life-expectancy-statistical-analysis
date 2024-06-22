# Life expectancy statistical analysis

# Overview
This study aims to explore the relationship between various social, economic, and health factors and the life expectancy of 179 countries from the year 2000 to 2015. By analyzing this dataset, we hope to identify significant predictors of life expectancy and understand the impact of these factors on a global scale. The study employs both parametric and non-parametric bootstrap techniques to ensure the robustness of our statistical inferences.

The dataset is made up of data gathered from the WHO open database which was uploaded on kaggle and can be found in the following link: https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who


## Objectives
To fit a linear regression model to predict life expectancy based on the available factors.
To apply non-parametric and parametric bootstrap methods to estimate the variability of the regression coefficients.
To construct confidence intervals for the regression coefficients using bootstrap techniques.

## Methodology
### Linear Regression Model
We fit a linear regression model using the lm() function in R, with life expectancy as the dependent variable and the various factors as independent variables.

### Non-Parametric Bootstrap
Bootstrap Function Definition: We define a function to fit the linear regression model and extract the coefficients.
Bootstrap Application: Using the boot function from the boot package, we perform 1000 resamples of the dataset and fit the linear model to each resample.
Coefficient Analysis: We calculate the mean and standard error of the regression coefficients from the bootstrap samples.

### Parametric Bootstrap
Original Model Fit: Fit the initial linear model to the original data to obtain parameter estimates.
Generate Parametric Resamples: Generate new datasets by sampling from the fitted model's estimated distribution.
Refit Model to Each Resample: For each resample, refit the linear model and store the estimated coefficients.
Confidence Intervals: Construct bootstrap confidence intervals for each coefficient.
