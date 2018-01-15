## ranacapa: Explore output from Anacapa in R

#### How to run:

1. Generate a personal access token (PAT) on github at https://github.com/settings/tokens (click on "Generate new token"; give it a name; select the checkbox next to "repo"). Copy the generated authorization token.

2. You will use the access token generated above to install the package into R:

```
library(devtools)

install_github("gauravsk/ranacap", auth_token = "PASTE TOKEN")
```

3. The package installation may take a few minutes.

4. Launch the shiny app by running the following line in `R`:

```
library(ranacapa)
ranacapa::runExample()
```
