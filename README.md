[![Build Status](https://travis-ci.org/gauravsk/ranacapa.svg?branch=master)](https://travis-ci.org/gauravsk/ranacapa)     [![DOI](https://zenodo.org/badge/117275741.svg)](https://zenodo.org/badge/latestdoi/117275741)



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

devtools::install_github("gauravsk/ranacapa")
```

2. The package installation may take a few minutes.


### How to run the interactive shiny app:
1. Launch the shiny app by running the following line in `R`:

```
library(ranacapa)
ranacapa::runRanacapaApp()
```


### How to run, option 2 (Only relevant for command line Anacapa users. Scripted output of all possible graphs and tables, not interactive):
1. Download the `ranacapa_automated.R` file from the `Anacapa` repo: https://github.com/limey-bean/Anacapa/blob/master/Anacapa_db/scripts/downstream-analyses/ranacapa_automated.R

2. In the terminal the script runs as:

```
Rscript ranacapa_automated.R /path/to/input_biom.txt /path/to/input_metadata.txt /path/to/desired_output_directory rarefaction_depth rarefaction_replicates
```


------------------------

## Structure of the package  


Last updated 22 April 2018

### Input files

1. As of right now the package is designed to visualize the output from the Anacapa pipeline. At minimum, the Anacapa output file has one column that contains the full taxonomic path assigned to the read, and one column for each of the samples sequenced. A file may look something like this:

```
site_1 site_2 site_3 site_4 site_5 site_6 site_7 site_8 site_9 sum.taxonomy                                                         
      1      0      0      0      0      0      0      0      0 Annelida;Clitellata;Haplotaxida;Megascolecidae;Amynthas;Amynthas sze…
      0      0      0      0      0      0      0      0      0 Nemertea;Palaeonemertea;NA;Cephalothricidae;Cephalothrix;Cephalothri…
      0      0      0      0      0      0      0      0      0 ""                                                                   
      0      0      0      0      0      0      0      0      0 Nematoda;Chromadorea;Monhysterida;Monhysteridae;NA;Monhysteridae sp.…
      0      1      0      0      0      0      0      0      0 NA;Oomycetes;Pythiales;Pythiaceae;Pythium;Pythium rostratifingens    
```

In some cases, the output file also contains a column called `[xxx]_seq_number` that contains a unique sequence identifier for each row. Here's what the file would look like if the sequence number was written by Anacapa:

```
CO1_seq_number    site_1 site_2 site_3 site_4 site_5 site_6 site_7 site_8 site_9 sum.taxonomy                                       
forward_CO1_9136       1      0      0      0      0      0      0      0      0 Annelida;Clitellata;Haplotaxida;Megascolecidae;Amy…
forward_CO1_13513      0      0      0      0      0      0      0      0      0 Nemertea;Palaeonemertea;NA;Cephalothricidae;Cephal…
forward_CO1_14071      0      0      0      0      0      0      0      0      0 ""                                                 
forward_CO1_13891      0      0      0      0      0      0      0      0      0 Nematoda;Chromadorea;Monhysterida;Monhysteridae;NA…
forward_CO1_3833       0      1      0      0      0      0      0      0      0 NA;Oomycetes;Pythiales;Pythiaceae;Pythium;Pythium …
```

Anacapa outputs this information because the user can use this sequence ID to go back to a FASTA file and find the sequence; it is of no use right now to the `ranacapa` package. There are functions that exist within `ranacapa` that scrub out columns with `seq_number` in their name.

**Eventually**, `ranacapa` will also be able to accept qiime-formatted biom tables. 

**NOTE**: As of now there is inconsistency in the terminology for this particular file type. I some times call it the "anacapa out" file and frequently use the variable name `ana_out` in functions to deal with it; sometimes, I might refer to it as the "biom table" or "biom file". **One goal is to make the terminology more consistent**.  

2. The other input file that `ranacapa` cares about is called the "mapping file", which contains the metadata for all of the samples. For example, we might include the season in which the sample was collected, whether it was collected from under an Oak or in the grasslands, etc., in this file. The mapping file has (at least) as many rows of information as there are samples in the study, and one column per "metadata" variable. **The first column of the mapping file must match the names of the samples (i.e. all non-taxonomy column names of the biom file**. A valid mapping file looks like:

```
sample_name sample_id season texture depth main_plant
site_1         186B1       s      sand      10. other     
site_2         16A2        w      sand      20. other     
site_3         201A1       s      clay      10. oak       
site_4         201C2       s      sand      30. sage      
site_5         181C1       s      sand      30. oak       
site_6         PPM6mo      p      clay      30. other     
site_7         181B2       s      clay      10. sage      
site_8         182C1       s      clay      20. other     
site_9         15C2        w      silt      30. other     
```

### rancapa under the hood

Apart from the shiny app, which does all the visualizations, most of `ranacapa` functions to convert between files that the users upload (i.e. the Anacapa output file and the associated Metadata file) and the `phyloseq` objects that ultimately get used for a lot of the analyses. This converting between formats happens in just a few core functions:  

1. `group_anacapa_by_taxonomy()`: sometimes, in anacapa output, the same taxonomic path can appear in multiple rows- for example, if two different sequences had the same taxon identification. This function groups such rows together, and adds up the values in the sample columns. It's important because physeq objects can only have one row per identified taxonomy.

2. `convert_anacapa_to_phyloseq()` This function takes the output file and the mapping file as its inputs, and spits out a `phyloseq` class object that has both the taxonomic and the metadata information in the same object. To do this, the function does the folllowing:   

- A. Convert the table into a phyloseq `otu_table` object   
- B. Then, it extracts the rownames of the `otu_table` created in step 1 (the rownames contain the full taxonomic path), and splits it up on each semicolon (`;`) to make a new matrix with 6 columns, one for each of the taxonomic ranks. The matrix is then converted into a `tax_table` object.  
- C. The `otu_table` and `tax_table` from steps A and B are united into the phyloseq style object.  
- D. The information from the mapping file is converted to class `sample_data`
- E. The phyloseq object in step C is merged with the sample_data from step D with the phyloseq function `merge_phyloseq`  .

3. `vegan_otu()` This function just takes a phyloseq style object, e.g. the one made by `convert_anacapa_to_phyloseq`, and extracts the otu table in the format of a community matrix that can be read by `vegan` functions. 

4. A series of validator functions for the input files, currently only in the `development` branch.
