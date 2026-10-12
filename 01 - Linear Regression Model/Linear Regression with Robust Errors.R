## LINEAR REGRESSION WITH ROBUST STANDARD ERROR USING R LANGUAGE
# This file is the continuation of prior Linear Regression.R linear regression
# However, one disctinction from this file is the utilization
# of Robust Standard Errors named Heteroskedasticity and Autocorrelation Consistent (HAC)
# standard errors by Newey and West (1979)

# Load all needed packages
library(lmtest)       # Performing linear regression diagnostic tests
library(nortest)      # Library for executing Jarque-Berra (JB) test for normality
library(readxl)       # Importing .xlsx data format
library(gt)           # Creating HTML-format table
library(sandwich)     # Package for estimating Newey and West (1979) Standard Errors
library(dplyr)        # Utilized for Data Manupulation Routine
library(modelsummary) # Create neat model summary tables

# Load cleansed data
md <- read_excel("Data/clean_money_demand.xlsx")

# View the data and convert data into Date format
md
md <- md %>%
  mutate(
    date = as.Date(date)
  )

# Estimate Both Real M1 and M2 Money Demand Function
m1_linear_mdf <- lm(
  formula = lnRM1 ~ INRD + lnGDP + lnRER + INRF,
  data = md
)

m2_linear_mdf <- lm(
  formula = lnRM2 ~ INRD + lnGDP + lnRER + INRF,
  data = md
)

# Create model summary for both estimations and compare the performance
models_perform <- list(
  "Real M1 Money Demand" = m1_linear_mdf,
  "Real M2 Money Demand" = m2_linear_mdf
)

modelsummary(
  models_perform,
  stars = TRUE,
  coef_rename = c(
    "INRD"  = "Domestic Interest Rate",
    "lnGDP" = "Real GDP",
    "lnRER" = "Real Exchange Rate",
    "INRF"  = "Foreign Interest Rate"
  ),
  estimate = c(
    "{estimate}{stars}[{p.value}]",
    "{estimate}{stars}[{p.value}]"
  )
)

# Estimate Robust Standard Error
nw_m1_linear <- coeftest(
  m1_linear_mdf,
  vcov. = NeweyWest(
    m1_linear_mdf,
    lag = 4,
    prewhite = FALSE,
    adjust = TRUE
  )
)

nw_m2_linear <- coeftest(
  m2_linear_mdf,
  vcov. = NeweyWest(
    m2_linear_mdf,
    lag = 4,
    prewhite = FALSE,
    adjust = TRUE
  )
)