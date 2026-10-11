## DATA TRANSFORMATION USING R LANGUAGE
# This file main objective is to demonstrate a guide to preparing data
# for linear regression model estimation using R programming language

# Load all corresponding package
library(dplyr)
library(readxl)
library(writexl)

# Import inital excel Data
money_demand <- read_excel("Data/money_demand.xlsx")

# Inspect loaded Data
money_demand

# Perform Data Processing
money_demand <- money_demand %>%
  mutate(
    date = as.Date(date), # Convert quarterly date from dttm format into date
    RER = (EXR * CPIF) / CPID, # Calculate Real Exchange Rate
    RM1 = M1 / CPID, # Calculate Real M1 Money Demand
    RM2 = M2 / CPID, # Calculate Real M2 Money Demand
    # transform several variables into natural logarithm
    lnM1 = log(M1),
    lnM2 = log(M2),
    lnGDP = log(GDP),
    lnRER = log(RER),
    lnRM1 = log(RM1),
    lnRM2 = log(RM2)
  )

# Re-inspect data
money_demand

# select only several variables for estimation only
linear_md <- money_demand %>%
  select(date, lnRM1, lnRM2, lnGDP, lnRER, INRD, INRF, INF)

# view cleaned data for linear regression and perform descriptive statistics
linear_md
summary(linear_md)

# Write cleaned data into .xlsx format
write_xlsx(
  linear_md, 
  path = "Data/clean_money_demand.xlsx"
)
