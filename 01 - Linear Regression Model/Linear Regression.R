## LINEAR REGRESSION WITH R LANGUANGE
# In this file, author demonstrate how to estimate linear regression model
# using R programming language

# Load all needed packages
library(lmtest)       # Performing linear regression diagnostic tests
library(nortest)      # Library for executing Jarque-Berra (JB) test for normality
library(readxl)       # Importing .xlsx data format
library(gt)           # Creating HTML-format table
library(tidyr)        # Performing table manipulation
library(dplyr)        # Utilized for Data Manupulation Routine
library(modelsummary) # Create neat model summary tables

# Load cleansed data
md <- read_excel("Data/clean_money_demand.xlsx")

# View the data and convert date into Date format
md
md <- md %>%
  mutate(
    date = as.Date(date)
  )

# Perform descriptive statistics
descriptive_stat <- md %>%
  select(-date) %>%
  summarise(
    across(
      everything(),
      list(
        Mean   = ~mean(.x, na.rm = TRUE),
        SD     = ~sd(.x, na.rm = TRUE),
        Median = ~median(.x, na.rm = TRUE),
        Min    = ~min(.x, na.rm = TRUE),
        Max    = ~max(.x, na.rm = TRUE)
      )
    )
  ) %>%
  pivot_longer(
    everything(),
    names_to  = c("Variable", ".value"),
    names_sep = "_",
    values_to = "Value"
  ) %>%
  gt() %>%
  opt_table_font(
    font = list(
      "Times New Roman",
      "Arial"
    )
  ) %>%
  tab_header(
    title = md("**Descriptive Statistics for All Variables**"),
    subtitle = md("*Real M1*, *Real M2*, *RER*, and *GDP* are transformed into Natural Logarithm")
  ) %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels(everything())
  ) %>%
  fmt_number(
    columns = c(Mean, SD, Median, Min, Max),
    decimals = 3
  ) %>%
  tab_source_note(
    source_note = md(
      "source: *Bank Indonesia*, *Statistics of Indonesia (BPS)*, *OECD Data* 
        (Authors' Computation)"
    )
  )

# View descriptive statistics table
descriptive_stat

# perform linear regression model
# 1. Linear Regression with one independent variables
slinear_mod <- lm(
  formula = lnRM1 ~ lnGDP,
  data = md
)
summary(slinear_mod)

# 2. Linear Regression with two independent variables
tlinear_mod <- lm(
  formula = lnRM2 ~ INRD + lnGDP,
  data = md
)
summary(tlinear_mod)

# 3. Linear Regression more than two independent variables
# Performing Money Demand Function (MDF) Estimation Based on Narayan (2007)
# and Narayan, Narayan, and Mishra (2009) with Cash-in-Advance model

# function for Narrow Money (M1) 
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

# Diagnostic tests for both Real M1 and M2 models
# Extract errors of both models
error_m1 <- m1_linear_mdf$residuals
error_m2 <- m2_linear_mdf$residuals

# A. Jarque-Berra (JB) test for Normality
ad.test(error_m1)
ad.test(error_m2)

# B. Durbin-Watson (DW) test for Autocorrelation
dwtest(m1_linear_mdf)
dwtest(m2_linear_mdf)

# C. Breusch-Pagan (BP) test for Heteroskedasticity
bptest(m1_linear_mdf)
bptest(m2_linear_mdf)
