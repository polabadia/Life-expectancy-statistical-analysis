#---Load libraries and datasets---#
#https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who
install.packages("dplyr")
library(comprehenr)
library(dplyr)
library(MASS)

dataset <- read.csv(file='Life_expectancy.csv')

summary(dataset)

#---histograms of the predictors---#
`%notin%` <- function(x, y) !(x %in% y)

variables = to_list(for(variable in colnames(dataset)) if(variable %notin% c('Country','Status')) variable)
print(variables)

for (variable in variables) {
  hist(dataset[[variable]], col = "lightskyblue",
       main = paste("Histogram of", variable),
       xlab = variable, ylab = "Frequency")
}

#---Plots of Life expectancy vs other variables---#
data_2015 <- subset(dataset, Year == 2015, c(Country,BMI,Life.expectancy))

plot(data_2015$BMI, data_2015$Life.expectancy, 
     main= "BMI vs. Life expectancy",
     xlab= "BMI",
     ylab= "Life expectancy (in years)",
     col= "lightskyblue", pch = 19, cex = 1, lty = "solid", lwd = 2)
#text(dataset$GDP, dataset$Life.expectancy, labels=data_2015$Country, cex= 0.7, pos=3)

#---Trying out models. First Linear regression---#
#Here we remove the Country feature since it's not useful for predicting new values
dataset <- dataset %>% select(-Country)

gdp_log_model <- lm(Life.expectancy ~ log(GDP), data = dataset )

summary(gdp_log_model)

schooling_lin_model <- lm(dataset$Life.expectancy ~ Schooling,data = dataset)

summary(schooling_lin_model)

adult_lin_model <- lm(dataset$Life.expectancy ~ Adult.Mortality, data = dataset)

summary(adult_lin_model)

#---Studying model with all variables---#

full_model <- lm(dataset$Life.expectancy ~ GDP + Schooling + Adult.Mortality, data = dataset)
summary(full_model)

#---Performing backward selection---#
full_model <- lm(Life.expectancy ~.,data=dataset)
model_back <- stepAIC(full_model, direction = "backward")
summary(model_back)

#---Performing forward selection---#
null_model <- lm(Life.expectancy ~1, data = dataset)
model_forward <- stepAIC(null_model, direction = "forward", scope       
       =list(lower=null_model,upper=full_model),trace=TRUE)
summary(model_forward)


#---USING BOOTSTRAPPING TECHNIQUES---#

library(boot)
#---Non-parametric bootstraping---#
bootstrap_fn <- function(data, indices,predictors) {
  dataset <- data[indices, ] 
  #We exclude the variables absent from the stepwise models
  dataset <- dataset %>% select(-c(GDP,Polio,Measles,Hepatitis.B,Population,thinness..1.19.years))
  fit <- lm(Life.expectancy ~ . ,data=dataset)
  return(coef(fit))
}
results <- boot(data = dataset, statistic = bootstrap_fn, R = 1000)
print(results)

boot.ci(results, type = "perc")

#Calculate the relative difference between the bootstrap estimation and the previous backward model estimation
bootstrap_means <- apply(results$t, 2, mean)
print(abs((coef(model_back)- bootstrap_means))/coef(model_back))

#---Parametric bootstraping
parametric_bootstrap_fn <- function(data, indices) {
  #We exclude the variables absent from the stepwise models
  dataset <- data %>% select(-c(GDP,Polio,Measles,Hepatitis.B,Population,thinness..1.19.years))

  # We extract fitted values and residuals
  fitted_values <- fitted(model_back)
  residuals <- residuals(model_back)

  new_y <- fitted_values + rnorm(length(fitted_values), mean = 0, sd = sd(residuals))
  new_data <- dataset
  new_data$Life.expectancy <- new_y
  fit <- lm(Life.expectancy ~ ., data = new_data)
  return(coef(fit))
}

parametric_results <- boot(data = dataset, statistic = parametric_bootstrap_fn, R = 1000)
#Calculate the relative difference between the bootstrap estimation and the previous backward model estimation
parametric_means <- apply(parametric_results$t, 2, mean)

print(abs((coef(model_back)- parametric_means))/coef(model_back))

ci_list <- lapply(1:length(parametric_results$t0), function(i) boot.ci(parametric_results, type = "perc", index = i))
ci_list
