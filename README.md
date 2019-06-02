# actools

Some tools for actuarial science.
 
## Description

The package can e.g. be used to extract coefficient tables from an all-factor linear regression model with arbitrarily interaction levels fitted by `lm`. 

## Examples

``` r
# devtools::install_github("mayer79/actools/Release/actools")
library(actools)

  CO2[["conc"]] <- factor(CO2[["conc"]])
  fit <- lm(uptake ~ Type:Treatment + conc:Treatment + Type:conc, data = CO2)
  (coefT <- coefTables(fit, rebase = TRUE))
  head(pred_classic <- predict(fit, CO2))
  head(pred_fancy <- predict(coefT, CO2))
      
  perf(CO2$uptake, pred_classic, lab = "classic")
  perf(CO2$uptake, pred_fancy, lab = "fancy")  
  
  # Same with logs
  fit <- lm(log(uptake) ~ Type:Treatment + conc:Treatment + Type:conc, data = CO2)
  (coefT <- coefTables(fit, rebase = TRUE))
  head(pred_classic <- exp(predict(fit, CO2)))
  head(pred_fancy <- predict(coefT, CO2, trafo = exp))
  
  perf(CO2$uptake, pred_classic, lab = "classic")
  perf(CO2$uptake, pred_fancy, lab = "fancy")
``` r

## References
