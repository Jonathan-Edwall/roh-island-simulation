#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME
# pipeline_scripts_dir=$script_dir/pipeline_scripts
######################################  
####### Defining parameter values #######
######################################
min_MAF_list=("No_MAF" "0.05")
######################################  
####### Defining the INPUT files #######
######################################  

# Loop over each min_MAF threshold
for min_MAF_threshold in "${min_MAF_list[@]}"; do
    # Check if min_MAF is a number
    if [[ $min_MAF_threshold =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        export use_MAF_pruning=TRUE
        export MAF_status_suffix="MAF_$(echo $min_MAF_threshold | sed 's/\./_/')"
        export min_MAF="$min_MAF_threshold"
    else
        export use_MAF_pruning=FALSE
        export MAF_status_suffix=$min_MAF_threshold
        export min_MAF=0
    fi

    # Source the pipeline scripts in the background
    (source $pipeline_scripts_dir/Hyperoptimization_H_e_calculation.sh) &

done

# Wait for all background jobs to finish
wait

# Ending the timer 
script_end=$(date +%s)
# Calculating the runtime of the script
script_runtime=$((script_end-script_start))

echo "Pipeline results finished"
echo "Runtime: $script_runtime seconds"
