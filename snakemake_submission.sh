#!/bin/bash 

# The purpose of this script is to separate the qiagen pilot mapped and unmapped reads into separate directories

#SBATCH --time=12:00:00  
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=15
#SBATCH --mem=128gb
#SBATCH -o full_snakemake.txt  
#SBATCH -A exd44

d1=$(date +%s) 

# set variables
RUN_PATH="/storage/group/exd44/default/epr5208/Hershey_project/snakemake_run"

# set working directory
cd $RUN_PATH

pwd 
echo "Job started"

# load conda environment
module load anaconda3
source activate snakemake

# run snakemake
snakemake --use-conda --cores 15 -p 

sleep 60
echo "Job ended"

d2=$(date +%s) 
sec=$(( ( $d2 - $d1 ) )) 
hour=$(echo - | awk '{ print '$sec'/3600}') 
echo Runtime: $hour hours \($sec\s\) 