## ranacapa: Explore output from Anacapa in R

### How to install:


#### NOTE! 21 April 2018: If you are having problems with the Beta Diversity options, follow the steps in the issue linked below.

[Temporary workaround to beta diversity issue](https://github.com/gauravsk/ranacapa/issues/5)


0. Install the `phyloseq` and `devtools` packages into `R` if you don't already have them:  
  ```
  source('http://bioconductor.org/biocLite.R')
  biocLite('phyloseq')
  
  install.packages('devtools')
  ```

1. Install ranacapa:
```
library(devtools)

devtools::install_github("gauravsk/ranacapa")
```

2. The package installation may take a few minutes.


### How to run the interactive shiny app:
1. Launch the shiny app by running the following line in `R`:

```
library(ranacapa)
ranacapa::runExample()
```


### How to run, option 2 (Only relevant for command line Anacapa users. Scripted output of all possible graphs and tables, not interactive):
1. Download the `ranacapa_automated.R` file from the `Anacapa` repo: https://github.com/limey-bean/Anacapa/blob/master/Anacapa_db/scripts/downstream-analyses/ranacapa_automated.R

2. In the terminal the script runs as:

```
Rscript ranacapa_automated.R /path/to/input_biom.txt /path/to/input_metadata.txt /path/to/desired_output_directory rarefaction_depth rarefaction_replicates
```

