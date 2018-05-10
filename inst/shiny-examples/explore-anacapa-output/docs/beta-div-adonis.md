## Beta diveristy analyses

The previous tab lets us visually inspect whether sites are similar or dissimilar, but it would be useful to statistically test whether sites that belong to a particular group are more similar to each other than to sites outside of the group. One way to do that is with a [multivariate version of an ANOVA](https://en.wikipedia.org/wiki/Multivariate_analysis_of_variance). Specifically, we use a [nonparametric](https://cran.r-project.org/web/packages/vegan/vegan.pdf) version of that test. 


We follow up this test with a subsequent test that compares the dissimilarity between particular factors-- this is analogous to the "Post-hoc Tukey test" from the ANOVA page. 
