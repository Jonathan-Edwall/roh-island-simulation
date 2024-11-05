
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)


# Function to handle user interruption
handle_interrupt() {
    echo "Pipeline interrupted. Exiting."
    # Could potentially clean up the files created up until the script termination here
    exit 1
}

# Trap the SIGINT signal (Ctrl+C) and call the handle_interrupt function
trap 'handle_interrupt' SIGINT


######################################  
####### Defining parameter values #######
######################################

# # Boolean value to determine whether to run the selection simulation code
# selection_simulation=TRUE # Defined in run_pipeline.sh


####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan


# pipeline_scripts_dir=$HOME/code/pipeline_scripts
# pipeline_scripts_dir=$script_dir/pipeline_scripts


cd $pipeline_scripts_dir


######################################  
####### Defining the INPUT files #######
######################################  
# results_dir=$HOME/results # Variable Defined in run_pipeline.sh

bedtools_results_dir=$results_dir/Bedtools/coverage
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
raw_data_dir=$data_dir/raw
#�������������
#� Selection Model (Simulated) � 
#�������������
raw_selection_data_dir=$raw_data_dir/simulated/selection_model

variant_position_dir=$raw_selection_data_dir/variant_position
variant_freq_plots_dir=$raw_selection_data_dir/variant_freq_plots

selection_pop_roh_freq_dir=$bedtools_results_dir/simulated/selection_model/pop_roh_freq

######################################  
####### Defining the OUTPUT files #######
######################################  

output_dir=$results_dir/causative_variant_windows

mkdir -p $output_dir # Creating subdirectory if it doesn't already exist

##############################################################################################  
############ RESULTS ###########################################################################
############################################################################################## 

max_parallel_jobs=4
find_causative_variant_windows() {
    local bed_file=$1
    local input_selection_coefficient_variant_positions_file=$2
    local output_variant_window_lengths_file=$3
    local knit_document_check=$4 # Variable that controls the knitting of the .rmd file   


    export pop_roh_freq_bed_file="$bed_file"
    export input_bed_file="$pop_roh_freq_bed_file"

    echo "Processing: $pop_roh_freq_bed_file"
    
    # Construct the params list
    export input_pop_roh_freq_file="$bed_file"
    export chr_simulated="$chr_simulated" #Variable defined in run_pipeline.sh
    export input_selection_coefficient_variant_positions_file=$input_selection_coefficient_variant_positions_file
    export output_dir=$output_dir
    export output_variant_window_lengths_file=$output_variant_window_lengths_file

    if [ "$knit_document_check" -eq 1 ]; then
        Rscript -e "rmarkdown::render('$pipeline_scripts_dir/3_Selection_Causative_Variant_window_detection.Rmd')"
    else
        Rscript -e "rmarkdown::render('$pipeline_scripts_dir/3_Selection_Causative_Variant_window_detection.Rmd', run_pandoc=FALSE)" # Run the .rmd script without knitting!
    fi         
    echo "Simulation $counter of $n_simulation_replicates completed"    
}

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

if [ "$selection_simulation" = TRUE ]; then
    # Generate the list of .bed files in the directory
    selection_models_pop_roh_files=("$selection_pop_roh_freq_dir"/*_ROH_freq.bed)
    counter=0
    # Loop over each input bed file
    for bed_file in "${selection_models_pop_roh_files[@]}"; do
        # Extract the selection coefficient by finding "s" followed by any number of digits, from the filename of the current bed_file
        # then extract everything to the right, excluding "_ROH_freq.bed
        selection_scenario_type=$(basename "$bed_file" | grep -oP 's\d+.*(?=_ROH_freq.bed)')
        echo "$bed_file"
        echo "$selection_scenario_type"
        input_selection_coefficient_variant_positions_file="$variant_position_dir/variant_position_${selection_scenario_type}.tsv"
        output_variant_window_lengths_file="$output_dir/causative_variant_window_lengths_${selection_scenario_type}.tsv"
        ((counter++)) 
        if [ "$counter" -eq 1 ]; then
            knit_document_check=1  # Only knit for the first simulation
        else
            knit_document_check=0  # Just run the script for all other cases
        fi 

        find_causative_variant_windows $bed_file $input_selection_coefficient_variant_positions_file $output_variant_window_lengths_file $knit_document_check &
        # Control the number of parallel jobs
        while [ $(jobs -r | wc -l) -ge $max_parallel_jobs ]; do
            wait -n
        done

    done
    # Wait for all background jobs to finish
    wait
    echo "Causative variant windows defined for the Selection Model Simulations"
    echo "The results are stored in: $output_dir"
else
    echo "Selection simulation is set to FALSE. Skipping Causative Window creation"
fi

# Ending the timer 
script_end=$(date +%s)
# Calculating the runtime of the script
script_runtime=$((script_end-script_start))

echo "Runtime: $script_runtime seconds"

