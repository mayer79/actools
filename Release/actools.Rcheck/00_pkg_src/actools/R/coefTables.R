#' From lm object, extract nice coefficient tables
#' 
#' @importFrom stats dummy.coef setNames
#' @importFrom magrittr %>%
#' @importFrom tibble rownames_to_column 
#' @importFrom tidyr separate_
#' @importFrom dplyr inner_join pull
#'
#' @description Turns an lm object fitted on factors (with or without interactions) into
#' coefficient tables. Factor levels are not allowed to contain ":".
#' 
#' @param object An object of class lm.
#' @param rebase Logical flag indicating if the coefficient tables (and intercept) should be 
#' rebased so that reference levels of factors are associated with coefficients 0.
#'
#' @return \code{list} of coefficient tables in long form.
#' 
#' @export
#'
#' @examples 
#' CO2[["conc"]] <- factor(CO2[["conc"]])
#' fit <- lm(uptake ~ Type + Type:Treatment:conc, data = CO2)
#' coefTables(fit)
#' coefTables(fit, rebase = TRUE)
coefTables <- function(object, rebase = FALSE) {
  stopifnot(inherits(object, "lm"))
 
  # Factor levels are not allowed to contain ":".
  if (length(badLevels <- grep(":", unlist(object$xlevels), value = TRUE))) {
    stop("':' not allowed in factor levels: ", paste(paste0("'", badLevels, "'"), collapse = ", "))
  }
  out <- dummy.coef(object)
  refLevels <- as.data.frame(lapply(object$xlevels, `[[`, 1), check.names = FALSE)
  out[["(Intercept)"]] <- data.frame(effect = out[["(Intercept)"]], row.names = NULL)

  for (nm in setdiff(names(out), "(Intercept)")) { # nm <- "Type:conc"
    xx <- out[[nm]] %>% 
      as.data.frame %>% 
      setNames("effect") %>% 
      rownames_to_column %>% 
      separate_("rowname", into = unlist(strsplit(nm, ":")), ":")
    
    stopifnot(setdiff(colnames(xx), "effect") %in% names(refLevels))
    
    if (rebase) {
      suppressWarnings(suppressMessages(
        baseLvl <- xx %>% 
          inner_join(refLevels) %>% 
          pull(effect)
      ))
      xx[["effect"]] <- xx[["effect"]] - baseLvl
      out[["(Intercept)"]] <- out[["(Intercept)"]] + baseLvl
    }
      
    out[[nm]] <- xx
  }
  
  class(out) <- "coefTable"
  out
}

utils::globalVariables("effect")

#' Predicted values based on \code{coefTable} object.
#' 
#' @importFrom stats var
#' @importFrom dplyr left_join pull
#' @importFrom magrittr %>%
#' @method predict coefTable
#'
#' @description Takes a data frame and replaces randomly part of the values by missing values. 
#' 
#' @param object Object of class coefTable.
#' @param newdata New data.
#' @param trafo Transformation to be applied to resulting predictions, e.g. \code{exp}.
#' @param ... Further arguments passed to \code{trafo}.
#'
#' @return Vector of predictions.
#' 
#' @export
#'
#' @examples 
#' CO2[["conc"]] <- factor(CO2[["conc"]])
#' fit <- lm(uptake ~ Type:Treatment + conc:Treatment + Type:conc, data = CO2)
#' coefT <- coefTables(fit, rebase = TRUE)
#' predict(fit, head(CO2))
#' predict(coefT, head(CO2))
predict.coefTable <- function(object, newdata, trafo = I, ...) {
  fn <- function(cT) {
    suppressWarnings(suppressMessages(
      newdata %>% 
        left_join(cT) %>% 
        pull(effect)
    ))
  }
  
  nms <- setdiff(names(object), "(Intercept)")
  effectList <- lapply(object[nms], fn)
  stopifnot(var(sapply(effectList, length)) == 0)
  trafo(Reduce(`+`, effectList, init = object[["(Intercept)"]][, "effect"]), ...)
}
