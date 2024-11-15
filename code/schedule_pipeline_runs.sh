#!/bin/bash

####################################  
# Setting up the pipeline script
#################################### 
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
export conda_env_full_path=""
# export conda_env_full_path="/home/jonteehh/pipeline/anaconda3/etc/profile.d/conda.sh"

# Defining the working directory
# export HOME="/home/jonathan"
export HOME="$(dirname "$(dirname "$(realpath "$0")")")"

cd $HOME

export script_dir="$HOME/code"
export pipeline_scripts_dir="$script_dir/pipeline_scripts"
export remove_files_scripts_dir="$script_dir/remove_files_scripts"


export empirical_dog_breed="labrador_retriever"
export empirical_raw_data_basename="LR_fs"

# Defining the working directory
export HOME=/home/jonathan
script_dir=$HOME/code
cd $script_dir
export data_dir="$HOME/data"
raw_data_dir="$data_dir/raw"
preprocessed_data_dir="$data_dir/preprocessed"

# Logging when the script starts
echo "$(date +'%Y-%m-%d %H:%M:%S') - Starting the pipeline script..." >> script.log

#################################### 
# First Run
#################################### 
run_name="" 

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
export N_e_bottleneck=5 # [30,40,50,60,70]
export n_generations_bottleneck=1
export n_simulated_generations_breed_formation=110 # [40,45,50,55,60,65,70]
export n_individuals_breed_formation=330 # [40-70]


source $script_dir/run_pipeline.sh
# Logging when the script starts
echo "$(date +'%Y-%m-%d %H:%M:%S') - First Pipeline run completed..." >> script.log
wait
mv "$raw_data_dir/simulated" "$raw_data_dir/$simulation_run_names" 
mv "$preprocessed_data_dir/simulated" "$preprocessed_data_dir/$simulation_run_names" 
wait


#################################### 
# second Run
#################################### 
run_name="" 

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
export N_e_bottleneck=5 # [30,40,50,60,70]
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
