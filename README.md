# Pipeline for removing host contaminant reads

This repository contains a pipeline that can be used for filtering out host contaminant reads. It is specifically optimized for filtering human contaminant reads from microbiome sequences, but can be modified for use with other hosts or sequences. Please note that [Bush et al.](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7478626/) came up with the original method; this pipeline is purely for easy implementation of the method.

This pipeline entails:
1. Running fastqc on initial reads to check sequence quality
2. Passing reads through bowtie2 for initial host contaminant removal
3. Passing reads through SNAP for secondary contaminat removal
4. Running fastqc on filtered reads as a sanity check.

The pipeline is conducted in shell via Snakemake. The snakefile is written such that the pipeline, data, and outputs are assumed to originate from the same base directory. More specifically, within the base directory are sub-directories called `data\` and `output\`. Within `data\` are directories called `raw\` and `refs\`. Data is stored in the `raw\` directory and references are stored in `refs\`. Additonal files within base include `snakemake_submission.sh` and `host_decontam.yml`. Files are described in further detail below.

```
base directory
|- README		                # Description of pipeline
|
|- data/		                # Any data put into pipeline - raw or processed
|    |- raw/		          
|    |- refs/
|
|- output/		                # Will contain output from pipeline after it is run
|
|- snakemake_submission.sh		# Submission script for pipeline
|
|- snakefile		            # Pipeline info
|
|- host_decontam.yml		    # Conda environment
+
```

## Ta
1. `oral_phyloseq.Rmd` - clean 16S rRNA gene amplicon sequence data and generate phyloseq object
2. `decontam.Rmd` - remove potential contaminants
3. `qc.Rmd` - additional QC and cleaning of the phyloseq object
4. `extraction_comparison.Rmd` - compare Qiagen and PowerSoil extraction kit data
5. `microbiome_characterization.Rmd` - examine metrics for standard microbiome characteristics (alpha and beta diversity)
6. `random_forest.Rmd` - use Random Forests to predict lifestyle based on lifestyle survey and microbiome data
7. `differential_abundance.Rmd` - perform differential abundance analysis with ALDEx2 to identify taxa that differ based on lifestyle
8. `microbiome_trend.Rmd` - perform trend test on all genera to see which microbial abundances follow the lifestyle trend
9. `CCA.Rmd` - conduct CCA to identify which specific lifestyle factors correlate with microbiome composition
10. `taxa_lifestyle.Rmd` - identify significant associations between specific lifestyle factors and DA microbes identified from the trend test.
11. `picrust2_prep.Rmd` - prepping data for PICRUSt2
12. `picrust_stratified.sh` (shell) - run stratified version of PICRUSt2 to predict pathway abundances.
13. `picrust_analysis.Rmd` - analyze PICRUSt2 output. All PICRUSt2 output from `picrust_stratified.sh` is assumed to be stored in its own directory `picrust2_qiagen_output\`
14. `network_analysis.Rmd` - conduct network analysis of the microbiome using SparCC
15. `gut_oral_comparison.Rmd` - examine the relationship between the oral and gut microbiomes

