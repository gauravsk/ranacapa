## Beta diversity analyses

The previous tab lets us visually inspect whether sites are similar or dissimilar, but it would be useful to verify the similarity or dissimilarity between groups samples using statistical tests. One way to do this is with a [multivariate version of an ANOVA](https://en.wikipedia.org/wiki/Multivariate_analysis_of_variance). This test lets us test whether samples from within a single habitat (or within any other group of interest) have more similar compositions that samples from different habitat types. Here, we use a [nonparametric](https://cran.r-project.org/web/packages/vegan/vegan.pdf) version of a multivariate ANOVA test called a [PERMANOVA](https://en.wikipedia.org/wiki/Permutational_analysis_of_variance). 

We follow up this test with a subsequent test that compares the dissimilarity between particular factors-- this is analogous to the "Post-hoc Tukey test" from the ANOVA page. 
