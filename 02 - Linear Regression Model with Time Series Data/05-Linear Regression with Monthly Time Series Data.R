## LINEAR REGRESSION WITH MONTHLY TIME SERIES DATA
# This codes demonstrate how to estimate linear regression with monthly time series data
# using monthly data, covering 2007 M06 until 2026 M03

# Load all library
library(lmtest)
library(nortest)
library(readxl)
library(gt)
library(zoo)
library(tidyr)
library(dplyr)
library(modelsummary)

# Load cleansed data
hnkpc <- read_excel("Clean Data/Cleansed Monthly Data.xlsx", sheet = "Sheet1")

# View data structure
str(hnkpc)

# Convert the date and monthly_date format into appropriate one, and rename output_gap var.
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

# Perform descriptive statistics for several variables
descriptive_stat <- hnkpc %>%
  select(
    INF, lnEXR, lnWTI,
    INR, econgap
  ) %>%
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
    names_to = c("Variables", ".value"),
    names_sep = "_"
  ) %>%
  mutate(
    Variables = case_match(
      Variables,
      "INF" ~ "Inflation",
      "lnEXR" ~ "Nominal Exchange Rate",
      "lnWTI" ~ "WTI Oil Prices",
      "INR" ~ "Interest Rate",
      "econgap" ~ "Output Gap",
      .default = Variables
    )
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
    subtitle = md("Covering 2007M01 until 2026M06")
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
    source_note = (
      "Source: Bank Indonesia, International Monetary Fund (IMF), 
      OECD Data Portal, Investing.com, Statistics of Indonesia (2026, Authors' Computation)"
    )
  )

# View descriptive statistics table
descriptive_stat

# Perfomr linear regression model with monthly time series data
# for full sample
hnkpc_estimation <- lm(
  formula = INF ~ INF_lag1 + INF_lag2 + INF_lag3 +
    INF_lead1 + INF_lead2 + INF_lead3 + INR +
    econgap + lnEXR + lnWTI,
  data = hnkpc,
  na.action = na.omit
)
summary(hnkpc_estimation) # preview the estimation result

# Split the data into both pre-pandemic and during-post pandemic samples
# and re-estimate the Hybrid NKPC model

# Data for pre-pandemic sample
pre_pandemic_hnkpc <- hnkpc %>%
  filter(
    monthly_date >= as.yearmon("2007-01") &
    monthly_date <= as.yearmon("2020-02")
  )

# Dara for during-post pandemic sample
dpse_pandemic_hnkpc <- hnkpc %>%
  filter(
    monthly_date >= as.yearmon("2020-03") &
    monthly_date <= as.yearmon("2026-03")
  )

# Hybrid NKPC Model estimation for pre-pandemic sample
pre_hnkpc_estimation <- lm(
  formula = INF ~ INF_lag1 + INF_lag2 + INF_lag3 +
    INF_lead1 + INF_lead2 + INF_lead3 + INR +
    econgap + lnEXR + lnWTI,
  data = pre_pandemic_hnkpc,
  na.action = na.omit
)
summary(pre_hnkpc_estimation) # preview the pre-pandemic result

# Hybrid NKPC Model estiamtion for during-post pandemic sample
dpse_hnkpc_estimation <- lm(
  formula = INF ~ INF_lag1 + INF_lag2 + INF_lag3 +
    INF_lead1 + INF_lead2 + INF_lead3 + INR +
    econgap + lnEXR + lnWTI,
  data = dpse_pandemic_hnkpc,
  na.action = na.omit
)
summary(pre_hnkpc_estimation) # preview the during-post pandemic result

# Create comparison table using modelsummary() function
model_performance <- list(
  "Full Sample<br>(2007 M04 - 2026 M03)"                 = hnkpc_estimation,
  "Pre-Pandemic Sample<br>(2007 M04 - 2020 M02)"         = pre_hnkpc_estimation,
  "During-Post Pandemic Sample<br>(2020 M03 - 2026 M03)" = dpse_hnkpc_estimation
)

modelsummary(
  model_performance,
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
    "INF_lag3"  = "&pi;<sub>t-1</sub> (inflation, lag 3)",
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
)

# Diagnostic tests for all sample estimations
# Extract erros of all models
error_pre <- residuals(pre_hnkpc_estimation)
error_dpse <- residuals(dpse_hnkpc_estimation)
error_full <- residuals(hnkpc_estimation)

# A. Jarque-Berra (JB) test for Normality
ad.test(error_pre)
ad.test(error_dpse)
ad.test(error_full)

# B. Durbin-Watson (DW) test for autocorrelation
dwtest(pre_hnkpc_estimation)
dwtest(dpse_hnkpc_estimation)
dwtest(hnkpc_estimation)

# C. Breusch-Pagan (BP) test for Heteroskedasticity
bptest(pre_hnkpc_estimation)
bptest(dpse_hnkpc_estimation)
bptest(hnkpc_estimation)
