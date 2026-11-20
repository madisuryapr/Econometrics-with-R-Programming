## ROBUST STANDARD ERROR LINEAR REGRESSION WITH MONTHLY TIME SERIES DATA
# This code main objective is to examine regarding how to estimate robust standard errors linear regression
# Using monthly data, covering 2007-01 until 2026-06

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
hnkpc <- read_excel("Clean Data/Cleansed Monthly Data.xlsx", sheet = "Sheet1")

# View data structure
str(hnkpc)

# Convert the date and monthly_date into appropriate format, and rename output_gap var.
hnkpc <- hnkpc %>%
  mutate(
    date = as.Date(date),
    monthly_date = as.yearmon(monthly_date)
  ) %>%
  rename(
    econgap = output_gap
  )

# Re-check data structure
str(hnkpc)

# Create a formula to be estimated
hnkpc_function <- INF ~ INF_lag1 + INF_lag2 + INF_lag3 + INF_lead1 + INF_lead2 + INF_lead3 + INR + econgap + lnEXR + lnWTI

# Perform linear regression model with monthly time series data
# for full sample (2007 M04 - 2026 M03)
hnkpc_estimation <- lm(
  formula = hnkpc_function,
  data = hnkpc,
  na.action = na.omit
)
summary(hnkpc_estimation) # preview the estimation result

# Split the data into pre-pandemic and during-post pandemic samples
# and re-estimate the Hybrid NKPC model

# Data for pre-pandemic sample
pre_pandemic_hnkpc <- hnkpc %>%
  filter(
    monthly_date >= as.yearmon("2007-01") &
    monthly_date <= as.yearmon("2020-02")
  )

# Data for during-post pandemic sample
dpse_pandemic_hnkpc <- hnkpc %>%
  filter(
    monthly_date >= as.yearmon("2020-03") &
    monthly_date <= as.yearmon("2026-03")
  )

# Hybrid NKPC Model estimation for pre-pandemic sample
pre_hnkpc_estimation <- lm(
  formula = hnkpc_function,
  data = pre_pandemic_hnkpc,
  na.action = na.omit
)
summary(pre_hnkpc_estimation) # preview pre-pandemic result

# Hybrid NKPC Model estimation for during-post pandemic sample
dpse_hnkpc_estimation <- lm(
  formula = hnkpc_function,
  data = dpse_pandemic_hnkpc,
  na.action = na.omit
)
summary(dpse_hnkpc_estimation) # preview during-post pandemic result

# Perform Robust Standard Errors Linear Regression estimation for all models
# by using prior results

# Robust Errors estimation for full sample
robust_full_hnkpc <- coeftest(
  hnkpc_estimation,
  vcov. = NeweyWest(
    hnkpc_estimation,
    lag = 5,
    prewhite = FALSE,
    adjust = TRUE
  )
)
robust_full_hnkpc # preview Robust Standard Errors result for full sample model

# Robust Errors estimation for pre-pandemic sample
robust_pre_hnkpc <- coeftest(
  pre_hnkpc_estimation,
  vcov. = NeweyWest(
    pre_hnkpc_estimation,
    lag = 5,
    prewhite = FALSE,
    adjust = TRUE
  )
)
robust_pre_hnkpc # preview Robust Standard Errors result for pre-pandemic model

# Robust Errors estimation for during-post pandemic sample
robust_dpse_hnkpc <- coeftest(
  dpse_hnkpc_estimation,
  vcov. = NeweyWest(
    dpse_hnkpc_estimation,
    lag = 5,
    prewhite = FALSE,
    adjust = TRUE
  )
)
robust_dpse_hnkpc # preview Robust Standard Errors results for during-post pandemic model

# Create comparison table using modelsummary() function
model_performance <- list(
  "Full Sample<br>(2007M04 - 2026M03)"                 = hnkpc_estimation,
  "Pre-Pandemic Sample<br>(2007M04 - 2020M02)"         = pre_hnkpc_estimation,
  "During-Post Pandemic Sample<br>(2020M03 - 2026M03)" = dpse_hnkpc_estimation,
  "Full Sample<br>(2007M04 - 2026M03)"                 = robust_full_hnkpc,
  "Pre-Pandemic Sample<br>(2007M04 - 2020M02)"         = robust_pre_hnkpc,
  "During-Post Pandemic Sample<br>(2020M03 - 2026M03)" = robust_dpse_hnkpc
)

modelsummary(
  model_performance,
  output = "tinytable",
  title = "<div style='text-align: center;'>
    <b>HYBRID NEW KEYNESIAN PHILLIPS CURVE (NKPC) ESTIMATION RESULTS FOR INDONESIAN ECONOMY</b></div>",
  stars = c(
    '*'   = 0.1,
    '**'  = 0.05,
    '***' = 0.01 
  ),
  coef_rename = c(
    "INF_lag1"  = "&pi;<sub>t-1</sub> (inflation, lag 1)",
    "INF_lag2"  = "&pi;<sub>t-2</sub> (inflation, lag 2)",
    "INF_lag3"  = "&pi;<sub>t-3</sub> (inflation, lag 3)",
    "INF_lead1" = "E<sub>t</sub>[&pi;<sub>t+1</sub>] (inflation, lead 1)",
    "INF_lead2" = "E<sub>t</sub>[&pi;<sub>t+2</sub>] (inflation, lead 2)",
    "INF_lead3" = "E<sub>t</sub>[&pi;<sub>t+3</sub>] (inflation, lead 3)",
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
      "<b>OLS with Ordinary S.E.</b>" = 2:4, # Number of columns for OLS estimation with Ordinary Standard Errors
      "<b>OLS with Robust S.E.</b>"   = 5:7  # Number of columd for OLS estimation with Newey-West Robust Standard Errors
    )
  )
