## ROBUST STANDARD ERRORS LINEAR REGRESSION WITH TIME SERIES DATA
# This code demostrate how to estimate robust standard error linear regression with time series data
# Using quarterly date, covering 2000 Q3 until 2025 Q4

# Load all library
library(lmtest)
library(readxl)
library(gt)
library(zoo)
library(tidyr)
library(dplyr)
library(modelsummary)
library(tinytable)
library(sandwich)

# Load cleansed data
hnkpc <- read_excel("Clean Data/Cleansed Quarterly Data.xlsx", sheet = "Sheet1")

# View data structure
str(hnkpc)

# Convert the data and quarterly_date format into appropriate one, and rename output_gap var.
hnkpc <- hnkpc %>%
  mutate(
    date = as.Date(date),
    quarterly_date = as.yearqtr(quarterly_date)
  ) %>%
  rename(
    econgap = output_gap
  )

# Re-check data structure
str(hnkpc)

# Create a formula to be estimated
hnkpc_function <- INF ~ INF_lag1 + INF_lag2 + INF_lead1 + INF_lead2 + INR + econgap + lnEXR + lnWTI

# Perform linear regression model with quarterly time series data
# for full sample (2000 Q3 - 2025 Q4)
hnkpc_estimation <- lm(
  formula = hnkpc_function,
  data = hnkpc,
  na.action = na.omit
)
summary(hnkpc_estimation) # preview the estimation result

# Split the data and estimate the pre-pandemic era of Hybrid NKPC model
pre_pandemic_hnkpc <- hnkpc %>%
  filter(
    quarterly_date >= as.yearqtr("2000 Q1") &
    quarterly_date <= as.yearqtr("2019 Q4")
  )

pre_hnkpc_estimation <- lm(
  formula = hnkpc_function,
  data = pre_pandemic_hnkpc,
  na.action = na.omit
)
summary(pre_hnkpc_estimation) # preview the pre-pandemic result

# Perform Robust Standard Errors Linear Regression estimation for both models
# by using prior result
robust_full_hnkpc <- coeftest( # Robust Errors estimation for full sample
  hnkpc_estimation,
  vcov. = NeweyWest(
    hnkpc_estimation,
    lag = 4,
    prewhite = FALSE,
    adjust = TRUE
  )
)
robust_full_hnkpc # preview the result

robust_pre_hnkpc <- coeftest( # Robust Errors estimation for pre-pandemic sample
  pre_hnkpc_estimation,
  vcov. = NeweyWest(
    pre_hnkpc_estimation,
    lag = 4,
    prewhite = FALSE,
    adjust = TRUE
  )
)
robust_pre_hnkpc # preview the result

# Create comparison table using modelsummary() function
model_performance <- list(
  "Full Sample<br>(2000 Q3 - 2025 Q4)"         = hnkpc_estimation,
  "Pre-Pandemic Sample<br>(2000 Q3 - 2019 Q4)" = pre_hnkpc_estimation,
  "Full Sample<br>(2000 Q3 - 2025 Q4)"         = robust_full_hnkpc,
  "Pre-Pandemic Sample<br>(2000 Q3 - 2019 Q4)" = robust_pre_hnkpc   
)

modelsummary(
  model_performance,
  output = "tinytable",
  title = "<div style='text-align: center;'>
    <b>Hybrid New Keynesian Phillips Curve (NKPC) Estimations for Indonesian Economy</b></div>",
  stars = c(
    '*'   = 0.1,
    '**'  = 0.05,
    '***' = 0.01
  ),
  coef_rename = c(
    "INF_lag1"  = "&pi;<sub>t-1</sub> (inflation, lag 1)",
    "INF_lag2"  = "&pi;<sub>t-2</sub> (inflation, lag 2)",
    "INF_lead1" = "E<sub>t</sub>[&pi;<sub>t+1</sub>] (inflation, lead 1)",
    "INF_lead2" = "E<sub>t</sub>[&pi;<sub>t+2</sub>] (inflation, lead 2)",
    "INR"       = "Central bank rate",
    "econgap"   = "Output gap",
    "lnEXR"     = "Nominal exchange rate",
    "lnWTI"     = "WTI oil prices"
  ),
  estimate = c(
    "{estimate}{stars} [{p.value}]"
  ),
  notes = list(
    "***, **, and * denote significance at 1%, 5%, and 10% values, respectively.",
    "Standard Errors and p-value are respectively presented in parenthesis and square brackets.",
    "Source: Authors' computation"
  )
) %>%
  group_tt(
    j = list(
      "<b>OLS with Ordinary S.E.</b>" = 2:3, # number of columns for OLS estimation with Ordinary Standard Errors
      "<b>OLS with Robust S.E.</b>"   = 4:5  # number of columns for OLS estimation with Newey-West Robust Standard Errors
    )
  )
