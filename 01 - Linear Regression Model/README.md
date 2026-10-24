## Linear Regression Model with R Programming

This folder demonstrate how to estimate linear regression model with R programming language. It analyzes the impact of independent variables on target (dependent)
variable. Furthermore, in this folder, I also demonstrate how to perform Gauss-Markov tests, including autocorrelation, normality, and heteroskedasticity
to ascertain whether the model achieve Best Linear Unbiased Estimator (BLUE) assumption.  

I performed linear regression to test Cash-in-Advance model for Indonesia's Demand for Money Function based on Narayan (2007) and Narayan, Narayan, and Mishra (2009)
prior literature. The formal equations for estimated model can be written as follows:  

- Narrow Money (M1) Demand Model:
```math
\ln(\frac{M1^d_t}{P_t}) = \beta_0 + \beta_1\ln RGDP_t + \beta_2 INR_{d,t} + \beta_3\ln REXR_t + \beta_4 INR_{f,t} + \varepsilon_t
```
- Broad Money (M2) Demand Model:
```math
\ln(\frac{M2^d_t}{P_t}) = \beta_0 + \beta_1\ln RGDP_t + \beta_2 INR_{d,t} + \beta_3\ln REXR_t + \beta_4 INR_{f,t} + \varepsilon_t
```

where $(\frac{M^d_t}{P_t})$ denotes real demand for money; $RGDP_t$ represents real economic output, proxied by Real Gross Domestic Product (GDP); $INR_{d,t}$ and
$INR_{f,t}$ are domestic and foreign interest rates, proxied by Bank Indonesia 7-Day Reverse Repo Rate (BI7-DRR) and The Fed Federal Funds Rate (FFR), respectively; $REXR_t$ is real exchange rate of USD/IDR, calculated as $REXR = NEXR * (\frac{CPI_{ID,2015=100}}{CPI_{US,2015=100}}$ where $CPI_{ID,2015=100}$ and $CPI_{US,2015=100}$ denoted as Indonesia and US Consumer Price Index with 2015 as base year; $\beta_0$ and $beta_{1,...,4}$ are constant and variables' elasticities; and $ln$ and $\varepsilon$ present natural logarithm and error of estimation.  

Bibliography:
- Narayan, P. K. (2007). Is money targeting an option for Bank Indonesia? *Journal of Asian Economics*, 18, 726-738. [http://dx.doi.org/10.1016/j.asieco.2007.06.002]
- Narayan, P. K., Narayan, S., & Mishra, V. (2009). Estimating money demand functions for South Asian countries. *Empirical Economics*, 36, 685-696. [http://dx.doi.org/10.1007/s00181-008-0219-9]

