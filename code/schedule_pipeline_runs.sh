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

# Defining the working directory
export HOME="$(dirname "$(dirname "$(realpath "$0")")")"
export script_dir="$HOME/code"
export pipeline_scripts_dir="$script_dir/pipeline_scripts"
export data_dir="$HOME/data"
raw_data_dir="$data_dir/raw"
preprocessed_data_dir="$data_dir/preprocessed"

# -------------[ Load Configuration ]-------------
CONFIG_FILE="$script_dir/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    echo -e "${GREEN}[INFO]${NC} Loading configuration from ${CONFIG_FILE}"
    source "$CONFIG_FILE"
else
    echo -e "${RED}[ERROR]${NC} Could not find config file at ${CONFIG_FILE}"
    exit 1
fi

cd $HOME

# Logging when the script starts
echo "$(date +'%Y-%m-%d %H:%M:%S') - Starting the pipeline script..." >> script.log

################################################### 
###########           First Run        ################
################################################### 
run_name="test_1_run" 

# export Variant_One_Individual_Origin=TRUE #TRUE: Soft Sweep Scenario: The causative variant comes from one homozygous individual (Likely multi-origin soft sweep)
export Variant_One_Individual_Origin=FALSE # FALSE: Soft Sweep Scenario: The causative variant doesnt come from one homozygous individual
export allele_copies_threshold=1 # This variable sets an upper limit of allele copies present in the population for the sampled causative variant. 
export Simulate_Hard_Sweep=TRUE # TRUE: Hard Sweep Simulation, FALSE: Soft Sweep Simulation

export results_dir="${HOME}/results_${run_name}" 
simulation_run_names="simulated-${run_name}"
export runtime_log="${script_dir}/pipeline_runtime_${run_name}.txt"

# # #### Population History Parameters ####
# chr_specific_recombination_rate: This parameter determines whether the modeled chromosome (selected by the Chr parameter), will use the chromosome-specific recombination rate of the modeled chromosome, or
# the genomic average recombination rate for dogs (False). 
# As a consequence, this parameter influences whether the simulation models are tailored to reflect the specific chromosome selected in Chr (True) or a more generic chromosome of the studied species(False).
export chr_specific_recombination_rate=FALSE # TRUE/FALSE
export chr_simulated="chr1"  # Define the empirical chromosome to simulate.
export Ne_burn_in=3185 # The effective population size of the ancestral ”burn-in” population
export N_bottleneck=5 # The population size of the bottleneck generations during the simulated bottleneck scenario.
export nInd_founder_population=$N_bottleneck # Number of founder individuals from the coalescent simulations.
export n_generations_bottleneck=1 # The extent of the bottleneck scenario in terms of generations passed
export n_simulated_generations_breed_formation=110 # The number of generations for the forward-in-time post-bottleneck breeding scenario
export n_individuals_breed_formation=330 # The number of bred individuals per generation in the aforementioned breeding scenario

source $script_dir/run_scheduled_pipeline_runs.sh
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

# export Variant_One_Individual_Origin=TRUE #TRUE: Soft Sweep Scenario: The causative variant comes from one homozygous individual (Likely multi-origin soft sweep)
export Variant_One_Individual_Origin=FALSE # FALSE: Soft Sweep Scenario: The causative variant doesnt come from one homozygous individual
export allele_copies_threshold=1 # This variable sets an upper limit of allele copies present in the population for the sampled causative variant. 
export Simulate_Hard_Sweep=FALSE # TRUE: Hard Sweep Simulation, FALSE: Soft Sweep Simulation

export results_dir="${HOME}/results_${run_name}" 
simulation_run_names="simulated-${run_name}"
export runtime_log="${script_dir}/pipeline_runtime_${run_name}.txt"

# # #### Population History Parameters ####
# chr_specific_recombination_rate: This parameter determines whether the modeled chromosome (selected by the Chr parameter), will use the chromosome-specific recombination rate of the modeled chromosome, or
# the genomic average recombination rate for dogs (False). 
# As a consequence, this parameter influences whether the simulation models are tailored to reflect the specific chromosome selected in Chr (True) or a more generic chromosome of the studied species(False).
export chr_specific_recombination_rate=FALSE # TRUE/FALSE
export chr_simulated="chr1"  # Define the empirical chromosome to simulate.
export Ne_burn_in=3185 # The effective population size of the ancestral ”burn-in” population
export N_bottleneck=5 # The population size of the bottleneck generations during the simulated bottleneck scenario.
export nInd_founder_population=$N_bottleneck # Number of founder individuals from the coalescent simulations.
export n_generations_bottleneck=1 # The extent of the bottleneck scenario in terms of generations passed
export n_simulated_generations_breed_formation=110 # The number of generations for the forward-in-time post-bottleneck breeding scenario
export n_individuals_breed_formation=330 # The number of bred individuals per generation in the aforementioned breeding scenario

source $script_dir/run_scheduled_pipeline_runs.sh
# Logging when the script starts
echo "$(date +'%Y-%m-%d %H:%M:%S') - Second Pipeline run completed..." >> script.log
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
