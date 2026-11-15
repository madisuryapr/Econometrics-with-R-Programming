## MONTHLY DATA TRANSFORMATION PROCESSES
# This code file main objective is to perform data transformation
# for all variables based on Raw Dataset within Raw Data folder for Monthly Data

## Load all library
library(dplyr)
library(tidyr)
library(readxl)
library(writexl)
library(zoo)
library(mFilter)

## Assign folder path
folder_path = "Raw Data"

# Get a list of all datasets
file_list <- list.files(
  path = folder_path,
  pattern = "^monthly_.*\\.xlsx$",
  ignore.case = TRUE,
  full.names = TRUE
)

## Real all monthly datasets
for (file in file_list) {
  var_name <- tools::file_path_sans_ext(
    basename(file)
  )
  assign(
    var_name,
    read_excel(
      file, sheet = "Data",
      na = "N/A"
    )
  )
}

## Re-assign all dataframe names for convenience
m_econ  <- `Monthly_Inflation and Output`
m_inter <- `Monthly_International Variables`

## Remove all prior data
rm(
  `Monthly_Inflation and Output`,
  `Monthly_International Variables`
)

##
str(m_econ)
str(m_inter)

## Convert the POSIXct format into Date and Create monthly date using zoo package
dataframe <- c(
  "m_econ", "m_inter"
)

for (df in dataframe) {
  data <- get(df)

  data <- data %>%
    mutate(
      date = as.Date(date),
      monthly_date = as.yearmon(date)
    )
  assign(df, data)
  message(
    "Data Transformation process is success for: ",
    df
  )
}

## Perform dataframe joining process
m_combined <- inner_join(
  m_econ, m_inter,
  by = "monthly_date"
)

## Perform data manipulation process
m_combined <- m_combined %>%
  select(
    date = date.x,
    monthly_date,
    everything(),
    -date.y
  ) %>%
  mutate(
    lnIPI     = log(IPI), # natural logarithm of Indonesia's Industrial Production Index (IPI)
    lnWTI     = log(WTI), # natural logarithm of West Texas Intermediate (WTI) Oil Prices
    lnEXR     = log(EXR), # natural logarithm of USD/IDR nominal exchange rate
    INF_lag1  = lag(INF, n = 1L), # one-month lag of inflation rate
    INF_lag2  = lag(INF, n = 2L), # two-month lag of inflation rate
    INF_lag3  = lag(INF, n = 3L), # three-month lag of inflation rate
    INF_lead1 = lead(INF, n = 1L), # one-month lead of inflation rate
    INF_lead2 = lead(INF, n = 2L), # two-month lead of inflation rate
    INF_lead3 = lead(INF, n = 3L)  # three-month lead of inflation rate
  )

## Perform output gap calculation
m_combined <- m_combined %>%
  mutate(
    # peform potential output extraction using HP Filter, 
    # where lambda = 14400 for monthly data
    pot_ipi = hpfilter(lnIPI, freq = 14400)$trend, 
    output_gap = (lnIPI - pot_ipi)*100 # Calculate output gap with percentage points approach
  )

## Select several variables for cleansed data
cleansed_data <- m_combined %>%
  select(
    date, monthly_date,
    INF, INF_lag1, INF_lag2, INF_lag3,
    INF_lead1, INF_lead2, INF_lead3,
    lnIPI, lnEXR, INR,
    lnWTI, pot_ipi, output_gap
  )

## Write cleansed data into .xlsx file format
write_xlsx(cleansed_data, "Clean Data/Cleansed Monthly Data.xlsx")
