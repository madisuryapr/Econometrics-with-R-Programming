## DATA TRANSFORMATION PROCESSES
# This code file main objective is to perform data transformation
# for all variables based on Raw Data set within Raw Data folder

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
  pattern = "\\.xlsx$",
  full.names = TRUE
)

## Read all datasets
for (file in file_list) {
  var_name <- tools::file_path_sans_ext(
    basename(file)
  )
  assign(
    var_name,
    read_excel(
      file, sheet = "data",
      na = "N/A"
    )
  )
}

## Re-assign all dataframe names for convenience
q_econ <- `Quarterly_Inflation and Output`
q_inter <- `Quarterly_International Variables`

## Remove all prior data
rm(
  `Quarterly_Inflation and Output`,
  `Quarterly_International Variables`
)

## check data structure
str(q_econ)
str(q_inter)

## Convert the POSIXct format into Date and Create quarterly date using zoo package
dataframe <- c(
  "q_econ", "q_inter"
)

for (df in dataframe) {
  data <- get(df)

  data <- data %>%
    mutate(
      date = as.Date(date),
      quarterly_date = as.yearqtr(date)
    )
  assign(df, data)
  message(
    "Data Transformation process is success: ",
    df
  )
}

## Perform dataframe joining process
q_combined <- inner_join(
  q_econ, q_inter,
  by = "quarterly_date"
)

## Perform data manipulation process
q_combined <- q_combined %>%
  select(
    date = date.x,    # assign date.x as the date period 
    quarterly_date,   # quarterly date based on as.yearqtr() function of zoo
    everything(),     # include all variables within combined dataframe
    -date.y           # remove duplicated date column
  ) %>%
  mutate(
    lnRGDP    = log(RGDP),   # natural logarithm of Indonesia's Real Gross Domestic Product (GDP)
    lnWTI     = log(WTI),    # natural logarithm of West Texas Intermediate (WTI) Oil Prices
    lnEXR     = log(EXR),    # natural logarithm of USD/IDR nominal exchange rate
    INF_lag1  = lag(INF, n = 1L), # one-quarter lag of inflation rate
    INF_lag2  = lag(INF, n = 2L), # two-quarter lag of inflation rate
    INF_lead1 = lead(INF, n = 1L), # one-quarter lead of inflation rate
    INF_lead2 = lead(INF, n = 2L)  # two-quarter lead of inflation rate
  )

## Perform output gap calculation
q_combined <- q_combined %>%
  mutate(
    pot_rgdp = hpfilter(lnRGDP, freq = 1600)$trend, # perform potential output extraction using HP filter
    output_gap = (lnRGDP - pot_rgdp)*100 # Calculate output gap with percentages point approach
  )

## Select several variables for cleansed data
cleansed_data <- q_combined %>%
  select(
    date, quarterly_date,
    INF, INF_lag1, INF_lag2,
    INF_lead1, INF_lead2,
    lnRGDP, lnEXR, INR,
    lnWTI, pot_rgdp, output_gap  
  )


## Write cleansed data into .xlsx file format
write_xlsx(cleansed_data, "Cleansed Quarterly Data.xlsx")
