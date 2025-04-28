#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME

# pipeline_script_dir=$HOME/code/pipeline_scripts

#################################### 
# Defining Simulation parameters
#################################### 
# data_dir=$HOME/data # Variable defined in the main pipeline script!
output_dir_neutral_simulation=$data_dir/raw/simulated/neutral_model
# export chr_simulated="chr3" # Defined in the main script
# n_simulation_replicates=20 # Defined in the main script
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

rmd_script_full_path="${pipeline_scripts_dir}/1_2_neutral_model_simulation.Rmd"

# Function to run a single simulation
run_simulation() {
    local counter=$1
    local knit_document_check=$2 # Variable that controls the knitting of the .rmd file   
    export chr_simulated="$chr_simulated"  #Variable defined in the main pipeline script!
    export model_chromosome_physical_length_bp="$model_chromosome_physical_length_bp"  #Variable defined in the main pipeline script!
    export Ne_burn_in="$Ne_burn_in"  #Variable defined in the main pipeline script!
    export nInd_founder_population="$nInd_founder_population" #Variable defined in the main pipeline script!
    export Inbred_ancestral_population="$Inbred_ancestral_population" #Variable defined in the main pipeline script!
    export N_bottleneck="$N_bottleneck"  #Variable defined in the main pipeline script!s
    export n_simulated_generations_breed_formation="$n_simulated_generations_breed_formation" #Variable defined in the main pipeline script! 
    export n_individuals_breed_formation="$n_individuals_breed_formation" #Variable defined in the main pipeline script! 
    export reference_population_for_snp_chip="$reference_population_for_snp_chip" #Variable defined in the main pipeline script! 
    export output_sim_files_basename="sim_${counter}_neutral_model_${chr_simulated}"
    export output_dir_neutral_simulation="$output_dir_neutral_simulation" 
    export selected_chr_snp_density_mb="$selected_chr_snp_density_mb" #Variable defined in the main pipeline script!
    export mutation_rate="$mutation_rate" # Variable defined in the main pipeline script!
    export Introduce_mutations="$Introduce_mutations" # Variable defined in the main pipeline script!

    export chr_specific_recombination_rate="$chr_specific_recombination_rate" # Variable defined in the main pipeline script! 
    export model_chromosome_recombination_rate="$model_chromosome_recombination_rate" # Variable defined in the main pipeline script!
    export average_recombination_rate="$average_recombination_rate" # Variable defined in the main pipeline script!

    if [ "$knit_document_check" -eq 1 ]; then
        Rscript -e "rmarkdown::render('$rmd_script_full_path')"
    else
        Rscript -e "rmarkdown::render('$rmd_script_full_path', run_pandoc=FALSE)" # Run the .rmd script without knitting!
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

# Removing the generated .knit.md file
knit_output_file="${rmd_script_full_path%.Rmd}.knit.md"
rm $knit_output_file

# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo "Neutral model simulations of dogs completed"
echo "The outputfiles are stored in: $output_dir_neutral_simulation"
echo "Runtime: $script_runtime seconds"