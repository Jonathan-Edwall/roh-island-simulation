 
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

# # Boolean value to determine whether to run the selection simulation code
# selection_simulation=TRUE # Defined in run_pipeline.sh



####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME

# pipeline_script_dir=$HOME/code/pipeline_scripts


# # Function to handle user interruption
# handle_interrupt() {
#     echo "Pipeline interrupted. Exiting."
#     # Could potentially clean up the files created up until the script termination here
#     exit 1
# }

# # Trap the SIGINT signal (Ctrl+C) and call the handle_interrupt function
# trap 'handle_interrupt' SIGINT

#################################### 
# Defining Simulation parameters
#################################### 
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
output_dir_selection_simulation=$data_dir/raw/simulated/selection_model
#mkdir -p $output_dir_selection_simulation
mkdir -p $output_dir_selection_simulation/variant_freq_plots # Also creating a subdirectory for storing the images of the simulation runs
mkdir -p $output_dir_selection_simulation/pruned_counts  # Creating a subdirectory for storing the disappearance counter values
mkdir -p $output_dir_selection_simulation/variant_position  # Creating a subdirectory for storing the position of the selected causative variant
mkdir -p $output_dir_selection_simulation/variant_freq_plots
# selection_coefficient_list=(0.8) # Defined in run_pipeline.sh

#¤¤¤¤¤¤¤¤¤¤¤ If running this script outside of run_pipeline.sh, then define these variables below: ¤¤¤¤¤¤¤¤¤¤¤ 
# n_simulation_replicates=1
# chr_simulated="chr3"
# selected_chr_snp_density_mb=56.21

#����������������������������������������������������������������������������
# Function: 
# Selection Scenario simulation for Dogs in AlphaSimR
#
###Input: 
# 
###Output: 
#����������������������������������������������������������������������������
# Number of parallel jobs to run at a time
# max_parallel_jobs_selection_sim=2 # Defined in run_pipeline.sh

# Function to run a single simulation for a specific selection coefficient
run_simulation() {
    disappearance_threshold_value_to_terminate_script=100   # After 20 failed tries, the script gets rerun
    local counter=$1
    local selection_coefficient=$2
    local knit_document_check=$3 # Variable that controls the knitting of the .rmd file   
    export chr_simulated="$chr_simulated"
    export Ne_burn_in="$Ne_burn_in"
    export nInd_founder_population="$nInd_founder_population"
    export Inbred_ancestral_population="$Inbred_ancestral_population"
    export N_e_bottleneck="$N_e_bottleneck"
    export n_simulated_generations_breed_formation="$n_simulated_generations_breed_formation"
    export n_individuals_breed_formation="$n_individuals_breed_formation"
    export reference_population_for_snp_chip="$reference_population_for_snp_chip"
    export output_sim_files_basename="sim_${counter}_selection_model_s$(echo "$selection_coefficient" | sed 's/\.//')_${chr_simulated}"
    export output_dir_selection_simulation="$output_dir_selection_simulation"
    export selected_chr_snp_density_mb="$selected_chr_snp_density_mb"
    export Introduce_mutations="$Introduce_mutations"
    export fixation_threshold_causative_variant="$fixation_threshold_causative_variant"
    export selection_coefficient="$selection_coefficient"
    export simulation_prune_count_file="$output_dir_selection_simulation/pruned_counts/pruned_replicates_count_s$(echo "$selection_coefficient" | sed 's/\.//')_${chr_simulated}.tsv"
    export variant_positions_file="$output_dir_selection_simulation/variant_position/variant_position_s$(echo "$selection_coefficient" | sed 's/\.//')_${chr_simulated}.tsv"
    export disappearance_threshold_value_to_terminate_script="$disappearance_threshold_value_to_terminate_script"

    while true
    do
        if [ "$knit_document_check" -eq 1 ]; then
            Rscript -e "rmarkdown::render('$pipeline_script_dir/2-5_1_dogs_founder_pop_sim_selection_model.Rmd')"
        else
            # Rscript -e "source('$pipeline_script_dir/2-5_1_dogs_founder_pop_sim_selection_model.Rmd')"
            Rscript -e "rmarkdown::render('$pipeline_script_dir/2-5_1_dogs_founder_pop_sim_selection_model.Rmd', run_pandoc=FALSE)" # Run the .rmd script without knitting!

        fi
        exit_status=$?

        if [ $exit_status -eq 0 ]; then
            echo "Simulation $counter with selection coefficient $selection_coefficient completed successfully"
            break
        else
            echo -e  "\n Simulation $counter with selection coefficient $selection_coefficient didn't fixate after $disappearance_threshold_value_to_terminate_script tries"
            echo -e "\n Rerunning the script.."
            # Update the prune count file
            if [ -f "$simulation_prune_count_file" ]; then
                temp_file=$(mktemp)
                updated=0
                while IFS=$'\t' read -r basename count; do
                    if [[ "$basename" == "$output_sim_files_basename" ]]; then
                        count=$((count + $disappearance_threshold_value_to_terminate_script))
                        updated=1
                    fi
                    echo -e "$basename\t$count" >> "$temp_file"
                done < "$simulation_prune_count_file"

                if [ $updated -eq 0 ]; then
                    echo -e "$output_sim_files_basename\t$disappearance_threshold_value_to_terminate_script" >> "$temp_file"
                fi

                mv "$temp_file" "$simulation_prune_count_file"
            else
                echo -e "$output_sim_files_basename\t$disappearance_threshold_value_to_terminate_script" > "$simulation_prune_count_file"
            fi
        fi

        echo "Exit status of R Markdown script: $exit_status"
        echo "Contents of prune count file after update:"
        cat "$simulation_prune_count_file"
    done
}
#############################################
###### Running selection coefficients sequentially     #####
###### (One selection coefficient at a time         #####
###### ,which should mitigate bottleneck of lower s)  #####
#############################################



#############################################
###### Running selection coefficients in parallel    ######
#############################################
cd $output_dir_selection_simulation
counter_start=1 # Default 1: Modify this value of you want to resume the simulations at a specific technical replicate.

if [ "$selection_simulation" = TRUE ]; then
    cd $output_dir_selection_simulation
    # Running the simulation n_simulation_replicates times to create 20 technical replicates
    for ((counter=1; counter<="$n_simulation_replicates"; counter++))
    do
        # Loop over each selection coefficient in parallel
        for selection_coefficient in "${selection_coefficient_list[@]}"
        do
            if [ "$counter" -eq 1 ] && [ "$selection_coefficient" == "${selection_coefficient_list[0]}" ]; then
                knit_document_check=1  # Only knit for the first simulation
            else
                knit_document_check=0  # Just run the script for all other cases
            fi
            run_simulation $counter $selection_coefficient $knit_document_check &
            # Control the number of parallel jobs
            while [ $(jobs -r | wc -l) -ge $max_parallel_jobs_selection_sim ]; do
                wait -n
            done
        done
        # Wait for all simulations for this replicate to finish
        wait
        echo "Simulation $counter completed for all selection coefficients"
    done

    # Ending the timer 
    script_end=$(date +%s)
    script_runtime=$((script_end-script_start))

    echo "Selection model simulations of dogs completed"
    echo "The output files are stored in: $output_dir_selection_simulation"
    echo "Runtime: $script_runtime seconds"
else
    echo "Selection simulation is set to FALSE. Exiting."
fi


