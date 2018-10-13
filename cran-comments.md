## Test environments
* Local Ubuntu 16.04, R 3.5.1
* Local Windows 7, R 3.5.1
* Ubuntu 14.04.5 LTS (on travis-ci), R 3.5.1

## R CMD check results
There were no ERRORs or WARNINGs.
There is one NOTE:
  ```
  Namespaces in Imports field not imported from:
  ‘heatmaply’ ‘markdown’ ‘plotly’ ‘scales’ ‘shinythemes’
  All declared Imports should be used.
  ```

These libraries are used within a Shiny app that is packaged inside the `inst` directory of the app- thus, although none of the new functions in `ranacapa` require these packages, running the Shiny app at the core of this package does require these packages.
