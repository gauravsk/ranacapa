## Analysis of variance  

A frequent question in ecology is whether different communities (or different types of communities) differ in their species richness or in their Shannon diversity -- for example, do soils from grasslands, forests, and shrubby communities all have equal bacterial diversity? One basic way of asking this question is to perform an [ANOVA](https://en.wikipedia.org/wiki/Analysis_of_variance) between the groups we are interested in. In its simplest form, an ANOVA asks whether the mean diversity differs significantly between groups. If it does, that we would expect to see a very small P-value in the table below. 

**Notes**:   

- There are many assumptions of an ANOVA, and the dataset you are investigating may break some of these assumptions. We encourage you to do more rigorous statistics if this question is of particular interest.   
- ANOVAs only work when each group is represented by a few samples- in other words, if your data set only has one sample from a grassland, one from a forest, and two from a shrubland, it is impossible to statistically tease apart the differences among these groups. You will see NAs in the table below if this is the case. 
