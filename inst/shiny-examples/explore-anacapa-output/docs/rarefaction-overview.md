## Background on rarefaction 

You might notice a great deal of variation in the number of sequences generated per sample- this can happen for a variety of reasons- e.g. the sequencer may have worked less efficiently on certain samples than others. This makes comparison between samples difficult- e.g. you might find more species in one sample than another simply because it has been sequenced more deeply than others.


One approach in this scenario is to 'rarefy' your samples by subsampling a defined number of sequences from each sample. You can choose a specific depth to rarefy to, or can choose to rarefy down to the minimum number of reads sequenced in any single sample (e.g. if you have 50000 reads in the least well-sequenced sample, all samples will be subsampled down to 50000 reads. Replicating this subsampling many times allows us to have better estimates of the diversity in the rarefied samples.

We note that there has been considerable discussion regarding the best way of dealing with unequal sampling, and we refer users to  [Weiss et al. 2017, Microbiome](https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-017-0237-y), and to [McMurdie & Holmes 2014, PLoS Comp. Biol](http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1003531) although we have not yet implemented alternative options in `ranacapa`.



