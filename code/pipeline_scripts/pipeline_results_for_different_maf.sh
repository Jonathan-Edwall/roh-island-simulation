#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME

# pipeline_scripts_dir=$HOME/code/pipeline_scripts

######################################  
####### Defining parameter values #######
######################################

min_MAF_list=("No_MAF" "0.01" "0.05")
# min_MAF_list=("No_MAF")
# min_MAF_list=("0.01")

N_e=$n_individuals_breed_formation # Imported from run_pipeline.sh 
######################################  
####### Defining the INPUT files #######
######################################  

# Loop over each min_MAF threshold
for min_MAF_threshold in "${min_MAF_list[@]}"; do
    # Check if min_MAF is a number
    if [[ $min_MAF_threshold =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        export use_MAF_pruning=TRUE
        export MAF_status_suffix="MAF_$(echo $min_MAF_threshold | sed 's/\./_/')"
        export result_file_sub_title="N_e=$N_e, MAF $min_MAF_threshold used, but only for H_E-computation"
        export min_MAF="$min_MAF_threshold"
    else
        export use_MAF_pruning=FALSE
        export MAF_status_suffix=$min_MAF_threshold
        export result_file_sub_title="N_e=$N_e, No MAF-based pruning used"
        export min_MAF=0
    fi

    (
        # Performing Sweep test with markers below the current MAF threshold pruned prior to the sweep test
        source $pipeline_scripts_dir/4_3_pipeline_Sweep_test.sh

        if [ "$selection_simulation" = TRUE ]; then
            # Running the Pipeline Summarize script to generate a summarizing HTML-file of the pipeline run
            source $pipeline_scripts_dir/pipeline_result_summary.sh

        else
            echo "Skipping running the summary script since selection model was not simulated"
        fi

    ) &

done

# Wait for all background jobs to finish
wait

# Ending the timer 
script_end=$(date +%s)
# Calculating the runtime of the script
script_runtime=$((script_end-script_start))

echo "Pipeline results finished"
echo "Runtime: $script_runtime seconds"
