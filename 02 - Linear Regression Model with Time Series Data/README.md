## Linear Regression with Time Series Dataset  

This repository main objective is to examine how to perform linear regression model using Time Series Dataset. I employ Indonesia's macroeconomic variables, 
covering inflation,interest rate, nominal exchange rate, output gap, and others. The empirical implementation of estimation is based on 
New Keynesian Phillips Curve (NKPC) function, following Horstein (2008) paper entitled "Introduction to the New Keynesian Phillips Curve". This theorem stems
from Phillips Curve theory in which examines inverse relationship between inflation and unemployment rate, Postulated by A.W. Phillips in The United Kingdom.  

After stagflation occurred within The US Economy during 1970s where both inflation and unemployment rate are in high position, many economists questioned this model 
and took various endeavors to developing it further, such as NKPC function. The model postulates that inflation is the function of marginal costs and forward-looking
of inflation expectation. Hence, the model representation can be expressed as follows:  

```math
\pi_t = \gamma_f \mathbb{E}_t[\pi_{t+1}] + \lambda mc_t + u_t
```

where $\pi_t$ denotes inflation rate of an economy; $E_t[\pi_{t+1}]$ examines forward-looking inflation expectations for the next one-period of month/quarter; $mc_t$
is marginal costs of an economy; $u_t$ represents error term or external factors; and $\gamma_f$ and $\lambda$ denoted as elasticities for both inflation expectation and
marginal costs, respectively. 

Gali and Gertler (1999) introduced the modification of above model, namely Hybrid NKPC by incorporating the backward-looking firm behavior towards inflation, represented by one-period lagged inflation into the model. Thus, the expanded model representation can be written as:  

```math
\pi_t = \gamma_b \pi_{t-1} + \gamma_f \mathbb{E}_t[\pi_{t+1}] + \lambda mc_t + u_t
```
This equation further expands the NKPC model, suggesting that inflation within an economy is examined by firms "rule-of-thumb" backward-looking of past inflation data, forward-looking inflation expectations, alongside the marginal costs. Furthermore, several prior studies incorporate more than one-period on both lag and lead, offering longer backward-looking of inflation past behavior, as well as forward-looking inflation expectations. The representation of this phenomenon can be expressed as follows:  

```math
\pi_t = \sum_{i = -k}^{k}\gamma_b \pi_{t-k} + \sum_{i = +k}^{k}\gamma_f \mathbb{E}_t[\pi_{t+k}] + \lambda mc_t + u_t
```

In addition, prior studies incorporate international variables, including import price, oil prices, and exchange rate to take the effect of external shocks into account on inflation dynamics of small open-economy country (see _inter alia_, Sahu (2014) and Narayan _et al._ (2019) in the case of India and Indonesia, respectively). Interest rate can be taken into consideration to the model, since it represents the monetary policy stances conducted by the central bank. Using linear approximation based on Hybrid NKPC for small open-economy and two leads and lags for inflation, therefore, the estimation model for this project can be written as:  

```math
\pi_t = \alpha + \beta_1^b \pi_{t-1} + \beta_2^b \pi_{t-2} + \theta_1^f \mathbb{E}[\pi_{t-1}] + \theta_2^f \mathbb{E}[\pi_{t-2}] + \gamma_1 r_t + \gamma_2 y_t^{*} + \gamma_3 wti_t + \gamma_4 exr_t + \varepsilon_t
```
This project's model considers that Indonesia's inflation is influenced by two-quarter of backward-looking inflation inertia and forward-looking inflation expectation, monetary policy interest rate, output gap, alongside a set of variables within which reflect external factors, namely oil prices and exchange. We use quarterly data, covering 2000-Q1 until 2026-Q2 period of time. Moreover, due to leads and lags effect, this project will only utilize 2000-Q3 until 2025-Q4 as the final data range for estimation. It does not incorporate import price index due to the unavailability of data that includes all period of time.
