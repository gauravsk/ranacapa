## ranacapa: Explore output from Anacapa in R

#### How to run:

0. Install the `phyloseq` and `devtools` packages into `R` if you don't already have them:  
  ```
  source('http://bioconductor.org/biocLite.R')
  biocLite('phyloseq')
  
  install.packages('devtools')
  ```

1. Install ranacapa:
```
library(devtools)

devtools::install_github("gauravsk/ranacapa", auth_token = "897487ba3b86fdebd56c35ef75d039479296f882")
```

3. The package installation may take a few minutes.

4. Launch the shiny app by running the following line in `R`:

```
library(ranacapa)
ranacapa::runExample()
```
