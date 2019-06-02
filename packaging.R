#=====================================================================================
# BUILD THE PACKAGE "actools"
#=====================================================================================

library(devtools)

stopifnot(basename(getwd()) == "actools")

pkg <- "release/actools"
unlink(pkg, force = TRUE, recursive = TRUE)
create(pkg, descr = list(
            Title = "Tools for actuarial science",
            Type = "Package",
            Version = "1.0.0",
            Date = Sys.Date(),
            Description = "A collection of tools for actuarial science.",
            
            `Authors@R` = "person('Michael', 'Mayer', email = 'mayermichael79@gmail.com', role = c('aut', 'cre', 'cph'))",
            Depends = "R (>= 3.5.0)",
            Imports = list("stats", "magrittr", "dplyr", "tibble", "tidyr"),
            License = "GPL(>= 3)",
            Author = "Michael Mayer [aut, cre, cph]",
            Maintainer = "Michael Mayer <mayermichael79@gmail.com>"), 
  rstudio = FALSE)

# Add R files
Rfiles <- c("coefTables.R", "perf.R")
stopifnot(file.exists(fp <- file.path("R", Rfiles)))
file.copy(fp, file.path(pkg, "R"))

# Create Rd files
document(pkg)

# Add further files
# devtools::use_cran_comments(pkg) (is required)
mdfiles <- c("NEWS.md", "README.md")
stopifnot(file.exists(mdfiles))
file.copy(mdfiles, pkg)

# Check
check(pkg, document = FALSE, manual = TRUE, check_dir = dirname(normalizePath(pkg)))

# tar and zip file plus check
build(pkg, manual = TRUE) # tar
# build(pkg, binary = TRUE) # zip

# Install the package (locally)
install(pkg) # tar

# check_rhub(pkg)
check_win_devel(pkg)

setwd(file.path("C:/projects/catools", pkg))
devtools::release()


# RESTART RSTUDIO
if (FALSE) {
  devtools::install_github("mayer79/actools/Release/actools")
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
}
