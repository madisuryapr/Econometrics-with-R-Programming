## LINEAR REGRESSION WITH TIME SERIES DATA
# This code demonstrate how to estimate linear regression with time series data
# using quarterly data, covering 2000 Q3 until 2025Q4

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
hnkpc <- read_excel("Cleansed Quarterly Data.xlsx", sheet = "Sheet1")

# View data structure
str(hnkpc)

# convert the date and quarterly_date format into appropriate one, and rename output_gap var.
hnkpc <- hnkpc %>%
  mutate(
    date = as.Date(date),
    quarterly_date = as.yearqtr(quarterly_date),
  ) %>%
  rename(
    econgap = output_gap
  )

# Re-check data structure
str(hnkpc)

# perform descriptive statistics for several variables
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
    names_to  = c("Variables", ".value"),
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
    title    = md("**Descriptive Statistics for All Variables**"),
    subtitle = md("Covering 2000Q1 until 2026Q2")
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
      "Source: Bank Indonesia, International Monetary Fund (IMF),
      OECD Data Portal, Investing.com (2026, Authors' Computation)"
    )
  )

# view descriptive statistics table
descriptive_stat

# Perform linear regression model with quarterly time series data
hnkpc_estimation <- lm(
  formula = INF ~ INF_lag1 + INF_lag2 + INF_lead1 + INF_lead2
    + INR + econgap + lnEXR + lnWTI,
  data = hnkpc,
  na.action = na.omit
)
summary(hnkpc_estimation)

# Split the data and estimate the pre-pandemic era of Hybrid NKPC model
pre_pandemic_hnkpc <- hnkpc %>%
  filter(
    quarterly_date >= as.yearqtr("2000 Q1") &
    quarterly_date <= as.yearqtr("2019 Q4")
  )

pre_hnkpc_estimation <- lm(
  formula = INF ~ INF_lag1 + INF_lag2 + INF_lead1 + INF_lead2
    + INR + econgap + lnEXR + lnWTI,
  data = pre_pandemic_hnkpc,
  na.action = na.omit
)
summary(pre_hnkpc_estimation)

# Create comparison table using modelsummary function()
model_performance <- list(
  "Full Sample<br>(2000 Q3 - 2025 Q4)" = hnkpc_estimation,
  "Pre-Pandemic Sample<br>(2000 Q3 - 2019 Q4)" = pre_hnkpc_estimation
)

modelsummary(
  model_performance,
  title = "<b>Hybrid New Keynesian Phillips Curve (NKPC) Estimations for Indonesian Economy</b>",
  stars = TRUE,
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
    "{estimate}{stars}[{p.value}]",
    "{estimate}{stars}[{p.value}]"
  ),
  notes = list(
    "***, **, and * denote significance at 1%, 5%, and 10% values, respectively.",
    "Standard Errors and p-value are respectively presented in parenthesis and square brackets.",
    "Source: Authors' computation"
  )
)

# Diagnostic tests for both pre-pandemic and full sample models
# Extract errors of both models
error_pre <- residuals(pre_hnkpc_estimation)
error_full <- residuals(hnkpc_estimation)

# A. Jarque-Berra (JB) test for Normality
ad.test(error_pre)
ad.test(error_full)

# B. Durbin-Watson (DW) test for autocorrelation
dwtest(pre_hnkpc_estimation)
dwtest(hnkpc_estimation)

# C. Breusch-Pagan (BP) test for Heteroskedasticity
bptest(pre_hnkpc_estimation)
bptest(hnkpc_estimation)
