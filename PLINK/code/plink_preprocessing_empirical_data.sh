#!/bin/bash -l

# Change working directory
HOME=/home/jonathan

cd $HOME


# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate plink

echo "conda activated?"


# Defining input directory
raw_data_dir=$HOME/data/raw
german_shepherd_empirical_data_dir=$raw_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813


# Defining output directory
preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

# Running PLINK preprocessing command

plink \
  --file $german_shepherd_empirical_data_dir/Wang_HDGenetDogs_Genotypes_100621_UK \
  --out $preprocessed_german_shepherd_dir/german_shepherd_filtered \
  --make-bed \
  --dog \
  --geno 0.05 --mind 0.1 \
  --pca 2
 
#--geno 0.05: maximum threshold for allowed missing genotype rate per marker (5%). If more than 5 % of the individuals in the sampled population has missing genotype at that marker, then the marker will be pruned away
#--mind 0.1: maximum threshold for allowed non-genotyped markers per individual (10%). Individuals with more non-genotyped markers than this threshold, will be pruned away.
# --pca 2: Performing PCA analysis to identify outliers in the dataset by calculating 2 principal components (PCA1,PCA2) that captures the major sources of variation in the dataset while reducing the dimensionality of the data.
echo "PLINK preprocessing completed"


# Creating the PCA directory if it doesnt already exist
mkdir -p $german_shepherd_empirical_data_dir/PCA/

# Performing PCA on the non-preprocessed dataset for comparison. 
plink \
  --file $german_shepherd_empirical_data_dir/Wang_HDGenetDogs_Genotypes_100621_UK \
  --out $german_shepherd_empirical_data_dir/PCA/Wang_HDGenetDogs_Genotypes_100621_UK_PCA \
  --dog \
  --pca 2
