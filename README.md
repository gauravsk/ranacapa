## ranacapa: Explore output from Anacapa in R

### How to install:


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

2. The package installation may take a few minutes.


### How to run, option 1 (interactive shiny app):
1. Launch the shiny app by running the following line in `R`:

```
library(ranacapa)
ranacapa::runExample()
```

### How to run, option 2 (scripted output of all possible graphs and tables, not interactive):
1. Download the `ranacapa_automated.R` file from the `Anacapa` repo: https://github.com/limey-bean/Anacapa/blob/master/Anacapa_db/scripts/downstream-analyses/ranacapa_automated.R

2. In the terminal the script runs as:

```
Rscript ranacapa_automated.R /path/to/input_biom.txt /path/to/input_metadata.txt /path/to/desired_output_directory
```
