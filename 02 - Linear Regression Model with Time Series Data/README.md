## Linear Regression with Time Series Dataset  

This repository main objective is to examine how to perform linear regression model using Time Series Dataset. I employ Indonesia's macroeconomic variables, 
covering inflation,interest rate, nominal exchange rate, output gap, and others. The empirical implementation of estimation is based on 
New Keynesian Phillips Curve (NKPC) function, following Horstein (2008) paper entitled "Introduction to the New Keynesian Phillips Curve". This theorem stems
from Phillips Curve theory in which examines inverse relationship between inflation and unemployment rate, Postulated by A.W. Phillips in The United Kingdom.  

After stagflation occurred within The US Economy during 1970s where both inflation and unemployment rate are in high position, many economists questioned this model 
and took various endeavors to develop this model further, such as NKPC function. The model postulates that inflation is the function of marginal costs and forward-looking
of inflation expectation. Hence, the model representation can be expressed as follows:  

```math
\pi_t = \gamma_f \mathbb{E}_t[\pi_{t+1}] + \kappa mc_t + u_t
```
where $\pi_t$ denotes inflation rate of an economy; $E_t[\pi_{t+1}]$ examines forward-looking inflation expectations for the next one-period of month/quarter; $mc_t$
is marginal costs of an economy; $u_t$ represents error term or external factors; and $\gamma_f$ and $\kappa$ denoted as elasticities for both inflation expectation and
marginal costs, respectively. 
