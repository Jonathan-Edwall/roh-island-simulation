#!/bin/bash
# Function to handle user interruption
handle_interrupt() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Pipeline interrupted. Terminating all background jobs..." >> script.log
    # Kill all background jobs (this will stop the .Rmd scripts running in parallel)
    jobs -p | xargs kill
    # Optionally clean up any files created up until the interruption
    exit 1
}

# Trap the SIGINT signal (Ctrl+C) and call the handle_interrupt function
trap 'handle_interrupt' SIGINT SIGTERM

####################################  
# Setting up the pipeline script
#################################### 
# Defining the path to the Conda initialization script
conda_setup_script_path=""
# conda_setup_script_path="/home/jonat/pipeline/anaconda3/etc/profile.d/conda.sh"
source $conda_setup_script_path  # Source Conda initialization script
# Activate the conda environment
conda activate roh_island_sim_env

# Defining the working directory
# export HOME="$(dirname "$(dirname "$(realpath "$0")")")"
export HOME="$(dirname "$(dirname "$(realpath "$0")")")"


echo "$HOME"


cd $HOME

export script_dir="$HOME/code"

export empirical_breed="labrador_retriever"
export empirical_raw_data_basename="LR_fs"
# Set the species for the empirical dataset to determine which species-specific options will be applied during the preprocessing.
export empirical_species="dog"
# Defines the range of autosomal chromosomes to be used in the analysis. This value should be set according to the species being analyzed.  
# The format follows PLINK's chromosome specification (e.g., "1-38" for dog). 
export empirical_autosomal_chromosomes="1-38"
# To list the Vertebrate Breed Ontology ID:s to use for associating phenotypes with the studied species, define it in
# the  'vertebrate_breed_ontology_ids' variable below. If you wish to use more than one VBO ID, the ID:s should be commaseparated as in
# the following example:  vertebrate_breed_ontology_ids="VBO_0200800,Unspecified".
# In the following example, VBO_0200800 refers to Labrador Retriever Dog, while "Unspecified" is an option to associate phenotypes
# with unknown (Unspecified) VBO ID to be able to be mapped to the studied species.
# A straight forward way to find the VBO ID of theg studied species, is by using the link below and replace "Labrador Retriever" with the studied species.'
#trieve the VBO ID for the studied breed/species, search on the following site: 
# https://ontobee.org/search?ontology=VBO&keywords=labrador+retriever&submit=Search+terms
export vertebrate_breed_ontology_ids="VBO_0200800,Unspecified" 


export data_dir="$HOME/data"
raw_data_dir="$data_dir/raw"
preprocessed_data_dir="$data_dir/preprocessed"

export gene_annotations_filepath="$data_dir/preprocessed/empirical/gene_annotations/canFam3.ncbiRefSeq.gtf.gz" 
export omia_scraped_phenotypes_data_filepath="$data_dir/raw/empirical/omia_scraped_phene_data/OMIA_dog_phenotype_data_raw.csv"
export omia_phenotypes_filepath="$data_dir/preprocessed/empirical/omia_phenotype_data/All_dog_phenotypes.bed"

# Logging when the script starts
echo "$(date +'%Y-%m-%d %H:%M:%S') - Starting the pipeline script..." >> script.log

################################################### 
###########           First Run        ################
################################################### 
run_name="test_1_run" 

######################################  
####### Defining parameter values #######
######################################
# export Variant_One_Individual_Origin=TRUE # Soft Sweep Scenario: The causative variant comes from one homozygous individual (Likely multi-origin soft sweep)
export Variant_One_Individual_Origin=FALSE # Soft Sweep Scenario: The causative variant doesnt come from one homozygous individual
export allele_copies_threshold=1
export Simulate_Hard_Sweep=TRUE # Hard Sweep Simulation
# export Simulate_Hard_Sweep=FALSE # Soft Sweep Simulation


export results_dir="${HOME}/results_${run_name}" 
simulation_run_names="simulated-${run_name}"
export runtime_log="${script_dir}/pipeline_runtime_${run_name}.txt"

# ####  ####
export chr_specific_recombination_rate=FALSE
export chr_simulated="chr1" # "chr28" or "chr1"
export Ne_burn_in=3185
export N_bottleneck=5 # [30,40,50,60,70]
export n_generations_bottleneck=1
export n_simulated_generations_breed_formation=110 # [40,45,50,55,60,65,70]
export n_individuals_breed_formation=330 # [40-70]


source $script_dir/run_pipeline_scheduled.sh
# Logging when the script starts
echo "$(date +'%Y-%m-%d %H:%M:%S') - First Pipeline run completed..." >> script.log
wait
mv "$raw_data_dir/simulated" "$raw_data_dir/$simulation_run_names" 
mv "$preprocessed_data_dir/simulated" "$preprocessed_data_dir/$simulation_run_names" 
wait


################################################### 
###########          Second Run       ################
################################################### 
run_name="test_2_run" 

# export Variant_One_Individual_Origin=TRUE # Soft Sweep Scenario: The causative variant comes from one homozygous individual (Likely multi-origin soft sweep)
export Variant_One_Individual_Origin=FALSE # Soft Sweep Scenario: The causative variant doesnt come from one homozygous individual
export allele_copies_threshold=1
# export Simulate_Hard_Sweep=TRUE # Hard Sweep Simulation
export Simulate_Hard_Sweep=FALSE # Soft Sweep Simulation


export results_dir="${HOME}/results_${run_name}" 
simulation_run_names="simulated-${run_name}"
export runtime_log="${script_dir}/pipeline_runtime_${run_name}.txt"

# ####  ####
export chr_specific_recombination_rate=FALSE
export chr_simulated="chr1" # "chr28" or "chr1"
export Ne_burn_in=3185
export N_bottleneck=5 # [30,40,50,60,70]
export n_generations_bottleneck=1
export n_simulated_generations_breed_formation=110 # [40,45,50,55,60,65,70]
export n_individuals_breed_formation=330 # [40-70]


source $script_dir/run_pipeline_scheduled.sh
# Logging when the script starts
echo "$(date +'%Y-%m-%d %H:%M:%S') - First Pipeline run completed..." >> script.log
wait
mv "$raw_data_dir/simulated" "$raw_data_dir/$simulation_run_names" 
mv "$preprocessed_data_dir/simulated" "$preprocessed_data_dir/$simulation_run_names" 
wait


# Logging the completion of the script
if [ $? -eq 0 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Python script executed successfully." >> script.log
else
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Python script failed." >> script.log
fi
