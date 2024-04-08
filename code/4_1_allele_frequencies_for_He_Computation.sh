#!/bin/bash -l

# Start the timer 
start=$(date +%s)

# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate plink
# /home/martin/anaconda3/envs/bedtools/bin/bedtools --version: bedtools v2.30.0  


####################################  
# Defining the working directory
#################################### 
HOME=/home/jonathan
cd $HOME

####################################  
# Defining the input files
#################################### 

# Defining input directory
raw_data_dir=$HOME/data/raw
#¤¤¤¤¤¤¤¤¤¤
# Empirical
#¤¤¤¤¤¤¤¤¤¤
#german_shepherd_empirical_data_dir=$raw_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
#¤¤¤¤¤¤¤¤¤¤
# Simulated
#¤¤¤¤¤¤¤¤¤¤
simulated_data_dir=$raw_data_dir/simulated


#################################### 
# Defining the output dirs
#################################### 

plink_output_dir=$HOME/results/PLINK
#¤¤¤¤¤¤¤¤¤¤
# Empirical
#¤¤¤¤¤¤¤¤¤¤
#german_shepherd_plink_output_dir=$plink_output_dir/empirical/german_shepherd/allele_freq
german_shepherd_plink_output_dir=$plink_output_dir/empirical/german_shepherd/allele_freq
mkdir -p $german_shepherd_plink_output_dir
#¤¤¤¤¤¤¤¤¤¤¤
# Simulated
#¤¤¤¤¤¤¤¤¤¤¤
simulated_data_plink_output_dir=$plink_output_dir/simulated/allele_freq
mkdir -p $simulated_data_plink_output_dir

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Function: bedtools freq
#
###Input: .map and .ped files
# 
###Output:
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Calculating the allele frequencies


#plink --bfile $preprocessed_german_shepherd_dir/german_shepherd_filtered --freq counts --dog --out $german_shepherd_plink_output_dir/german_shepherd_allele_freq


#plink --file $german_shepherd_empirical_data_dir/Wang_HDGenetDogs_Genotypes_100621_UK --freq counts --dog --nonfounders --out $german_shepherd_plink_output_dir/german_shepherd_allele_freq

plink --bfile $preprocessed_german_shepherd_dir/german_shepherd_filtered --freq --dog --nonfounders --allow-no-sex --out $german_shepherd_plink_output_dir/german_shepherd_allele_freq

plink --file $simulated_data_dir/Neutral_simulation_chr3 --freq --dog --nonfounders --allow-no-sex --out $simulated_data_plink_output_dir/neutral_model_chr_3_allele_freq



#plink --file $preprocessed_german_shepherd_dir/german_shepherd_filtered --freq 

# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Allele frequencies computed successfully."
echo "The output file are stored in: $german_shepherd_plink_output_dir & $simulated_data_plink_output_dir " 
echo "Runtime: $runtime seconds"
