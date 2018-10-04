## Background on Beta Diversity

A second way to consider the diversity among samples is to investigate the extent to which samples differ in their species composition. For example, consider a pair of sites, each of which contains the same ten species- both are equally diverse (Observed richness of 10), and have the same 10 species. Now consider a second pair of sites, each of which contains ten species- but in this case, the ten species in the first site are entirely different than the ten species in the second. In other words, the two sites in the second pair are equally diverse, but quite dissimilar in terms of their species composition. Quantifying differences in species composition between sites is at the crux of [Beta diversity](https://en.wikipedia.org/wiki/Beta_diversity). 

Beta diversity is a complex topic and there are [many ways to measure it](https://methodsblog.wordpress.com/2015/05/27/beta_diversity/). In fact, measuring and interpreting beta diversity is still an unresolved question in community ecology (e.g. [Anderson et al. 2011](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1461-0248.2010.01552.x), and new metrics for quantifying beta diversity continue to be developed (e.g. [Ricotta 2017](https://onlinelibrary.wiley.com/doi/abs/10.1002/ece3.2980)). 

In this app we consider some simple ways of exploring beta diversity. All of these methods can be calculated using one of two measures of dissimilarity:

- The [Jaccard index](https://cals.arizona.edu/classes/rnr555/lecnotes/10.html), which incorporates differences in species presence or absence between sites, but not differences in species abundance, or   

- The [Bray-Curtis index](https://en.wikipedia.org/wiki/Bray%E2%80%93Curtis_dissimilarity), which integrates information about species abundance. 

We recommend using the Jaccard index, as eDNA-based abundance data might not always be reliable, but encourage you to explore both indices. Do you get the same results using both? If not, what might be driving the disparity?

In the [PCoA](https://en.wikipedia.org/wiki/Multidimensional_scaling#Types) plot below, samples are plotted such that points that are near each other on the plot are more similar in their taxonomic composition; samples that are distant in this plot have very different species lists.



