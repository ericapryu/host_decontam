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
|- snakefile		            # Pipeline info
|
|- host_decontam.yml		    # Conda environment
|
|- snakemake_submission.sh		# Submission script for pipeline
+
```

## snakefile
This file contains the pipeline info. Assuming no changes to bowtie2 or SNAP steps (which are default), the only aspects that need modifying are the variables starting at line 3 in order to point to the sequences, references, conda environment, and number of threads. All output directories will be generated as the files are created. Please note that snakefile assumes that fastqc is loaded as a module (line 41), so this may need to be modified and loaded within a conda environment.

## host_decontam.yml
This file contains info for building the conda environment used in this pipeline. It contains samtools, bowtie2, and SNAP. 

## snakemake_submission.sh
This file is the slurm script for submitting and running the pipeline.