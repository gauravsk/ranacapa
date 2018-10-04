
You can conver this file into to a `BIOM` file using the following command in the terminal (assuming you have the `biom` software installed):

```
biom convert --to-hdf5 --table-type="OTU table" -i taxonomy-for-biom.txt -o taxonomy-as-biom.biom
```

Once converted, the `BIOM` file can be imported into QIIME2 using the steps outlined at [this page](https://docs.qiime2.org/2018.8/tutorials/importing/#feature-table-data)


------
#### Download taxonomy table for downstream analysis as a phyloseq object

You can also download your taxonomy table as a Phyloseq object for downstream analyses in `R`. You can import this phyloseq object into `R` using the following command:

```
phyloseq_obect <- readRDS("phyloseq-object.Rds")
```

