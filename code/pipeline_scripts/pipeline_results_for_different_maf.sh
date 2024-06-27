#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

####################################  
# Defining the working directory
#################################### 

HOME=/home/jonathan
#cd $HOME

script_directory=$HOME/code/pipeline_scripts

######################################  
####### Defining parameter values #######
######################################

min_MAF_list=("No_MAF" "0.01" "0.05")
# min_MAF_list=("No_MAF")

# N_e=340 
N_e=$n_individuals_breed_formation # Imported from run_pipeline.sh 
######################################  
####### Defining the INPUT files #######
######################################  

# Loop over each selection coefficient
for min_MAF_threshold in "${min_MAF_list[@]}"
do
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


    # Source the pipeline scripts
    source $script_directory/4_pipeline_Sweep_test.sh

    # Source the pipeline scripts
    source $script_directory/pipeline_result_summary.sh


done

# Ending the timer 
script_end=$(date +%s)
# Calculating the runtime of the script
script_runtime=$((script_end-script_start))

echo "Pipeline results finished"
echo "Runtime: $script_runtime seconds"
