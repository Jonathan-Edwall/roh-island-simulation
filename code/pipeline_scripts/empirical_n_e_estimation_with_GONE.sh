#!/bin/bash -l

# Defining the path to the Conda initialization script
# conda_setup_script_path="/home/martin/anaconda3/etc/profile.d/conda.sh"
# source $conda_setup_script_path  # Source Conda initialization script
# Activate the conda environment
# conda activate roh_island_sim_env

######################################  
####### Defining parameter values #######
######################################
empirical_preprocessed_data_basename="${empirical_breed}_filtered"
# empirical_raw_data_basename=LR_fs
# empirical_autosomal_chromosomes="1-38" # Variable Defined in run_pipeline.sh
empirical_geneticmap_filetype_raw_data=.bim


# Extract the start and end of the chromosome range (e.g., "1-19")
start_chromosome=$(echo $empirical_autosomal_chromosomes | cut -d'-' -f1)
end_chromosome=$(echo $empirical_autosomal_chromosomes | cut -d'-' -f2)

# Calculate the number of chromosomes in the range
num_chromosomes=$((end_chromosome - start_chromosome + 1))

# empirical_species="dog" # Variable Defined in run_pipeline.sh
# Define species-specific options
if [[ "$empirical_species" == "dog" ]]; then
    species_flag="--dog"
else
    species_flag="--chr-set $num_chromosomes"
fi


####################################  
# Defining the working directory
#################################### 
# HOME=/home/jonathan
cd $HOME

####################################  
# Defining the input files
#################################### 

# Defining input directory
raw_data_dir="$data_dir/raw"
raw_empirical_breed_dir=$raw_data_dir/empirical/$empirical_breed
# raw_empirical_breed_dir=$raw_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

preprocessed_data_dir=$HOME/data/preprocessed
# preprocessed_empirical_breed_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
preprocessed_empirical_breed_dir=$preprocessed_data_dir/empirical/$empirical_breed

####################################  
# Defining the output files
#################################### 
GONE_dir=$HOME/GONE



###############################################################################################  
# RESULTS - Using Preprocessed Data
############################################################################################### 

##########################  
# Estimating N_e from raw data  #
##########################

# ¤¤¤¤ Use if the geneticmap is in .bim format
plink \
--bfile $raw_empirical_breed_dir/$empirical_raw_data_basename \
--recode \
$species_flag \
--chr $empirical_autosomal_chromosomes \
--out $GONE_dir/$empirical_raw_data_basename 

empirical_data_basename=$empirical_raw_data_basename

# #################################  
# # Estimating N_e from preprocessed data   #
# ################################# 

# # Convert .bed, .bim, .fam to .ped and .map
# plink \
# --bfile $preprocessed_empirical_breed_dir/$empirical_preprocessed_data_basename \
# --recode \
# $species_flag \
# --out $GONE_dir/$empirical_preprocessed_data_basename


# empirical_data_basename=$empirical_preprocessed_data_basename


####################  
####### GONE #######  
####################

echo ".Map and .Ped files created."
echo "GONE will now be run for N_e estimation of the empirical dataset"


cd $GONE_dir 
# Making all the relevant programmes for GONE executable
chmod u+x PROGRAMMES/*


bash script_GONE.sh $empirical_data_basename 

###################  
# Viewing the results #  
###################
cd $pipeline_scripts_dir


export GONE_results_dir="$GONE_dir"
export empirical_data_prefix="$empirical_data_basename"


Rscript -e "rmarkdown::render('$pipeline_scripts_dir/GONE_Ne_estimation.Rmd')"

rm $GONE_dir/$empirical_data_basename.*


# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Total Runtime: $runtime seconds"
