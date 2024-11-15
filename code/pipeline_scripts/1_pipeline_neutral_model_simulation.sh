#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME

# pipeline_script_dir=$HOME/code/pipeline_scripts
# pipeline_script_dir=$script_dir/pipeline_scripts


#################################### 
# Defining Simulation parameters
#################################### 
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
output_dir_neutral_simulation=$data_dir/raw/simulated/neutral_model
# export chr_simulated="chr3"
# n_simulation_replicates=20 #20
mkdir -p $output_dir_neutral_simulation
#����������������������������������������������������������������������������
# Function: 
# Founder population simulation for Dogs (Neutral Model) in AlphaSimR
#
###Input: 
# 
###Output: 
#����������������������������������������������������������������������������
cd $output_dir_neutral_simulation

# Number of parallel jobs to run at a time
# max_parallel_jobs_neutral_model_simulations=20 # Variable defined in the main script!

# Function to run a single simulation
run_simulation() {
    local counter=$1
    local knit_document_check=$2 # Variable that controls the knitting of the .rmd file   

    export chr_simulated="$chr_simulated"  #Variable defined in run_pipeline.sh
    export Ne_burn_in="$Ne_burn_in"  #Variable defined in run_pipeline.sh
    export nInd_founder_population="$nInd_founder_population" #Variable defined in run_pipeline.sh
    export Inbred_ancestral_population="$Inbred_ancestral_population" #Variable defined in run_pipeline.sh
    export N_e_bottleneck="$N_e_bottleneck"  #Variable defined in run_pipeline.shs
    export n_simulated_generations_breed_formation="$n_simulated_generations_breed_formation" #Variable defined in run_pipeline.sh 
    export n_individuals_breed_formation="$n_individuals_breed_formation" #Variable defined in run_pipeline.sh 
    export reference_population_for_snp_chip="$reference_population_for_snp_chip" #Variable defined in run_pipeline.sh 
    export output_sim_files_basename="sim_${counter}_neutral_model_${chr_simulated}"
    export output_dir_neutral_simulation="$output_dir_neutral_simulation" 
    export selected_chr_snp_density_mb="$selected_chr_snp_density_mb" #Variable defined in run_pipeline.sh
    export Introduce_mutations="$Introduce_mutations" #Variable defined in run_pipeline.sh

    # # Check if rmarkdown is installed, if not, install it
    # Rscript -e "if (!require('rmarkdown')) install.packages('rmarkdown', repos = 'https://cloud.r-project.org/')"

    if [ "$knit_document_check" -eq 1 ]; then
        Rscript -e "rmarkdown::render('$pipeline_scripts_dir/1-1_dogs_founder_pop_sim_neutral_model.Rmd')"
    else
        Rscript -e "rmarkdown::render('$pipeline_scripts_dir/1-1_dogs_founder_pop_sim_neutral_model.Rmd', run_pandoc=FALSE)" # Run the .rmd script without knitting!
    fi         

    echo "Simulation $counter of $n_simulation_replicates completed"
}

# Running the simulation 20 times with job control
for ((counter=1; counter<=$n_simulation_replicates; counter++))
do
    if [ "$counter" -eq 1 ]; then
        knit_document_check=1  # Only knit for the first simulation
    else
        knit_document_check=0  # Just run the script for all other cases
    fi

    run_simulation $counter $knit_document_check &  # Run the job in the background
    
    # If the number of background jobs reaches the limit, wait for one to finish
    while [ $(jobs -r | wc -l) -ge $max_parallel_jobs_neutral_model_simulations ]; do
        wait -n
    done
done

# Wait for all remaining jobs to finish
wait


# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo "Neutral model simulations of dogs completed"
echo "The outputfiles are stored in: $output_dir_neutral_simulation"
echo "Runtime: $script_runtime seconds"