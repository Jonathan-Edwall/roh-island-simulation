
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

######################################  
####### Defining parameter values #######
######################################
# Get the number of logical cores available
cores=$(nproc)
# Set the maximum number of parallel jobs to run at a time 
max_parallel_jobs=$((cores / 2))

# # Boolean value to determine whether to run the selection simulation code
# selection_simulation=TRUE # Defined in run_pipeline.sh

####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
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
find_causative_variant_windows() {
    local bed_file=$1
    local input_selection_coefficient_variant_positions_file=$2
    local technical_replicate_variant_window_length_file=$3
    local knit_document_check=$4 # Variable that controls the knitting of the .rmd file  
    export pop_roh_freq_bed_file="$bed_file"
    export input_bed_file="$pop_roh_freq_bed_file"
    echo "Processing: $pop_roh_freq_bed_file"
    # Construct the params list
    export input_pop_roh_freq_file="$bed_file"
    export chr_simulated="$chr_simulated" #Variable defined in run_pipeline.sh
    export input_selection_coefficient_variant_positions_file=$input_selection_coefficient_variant_positions_file
    export output_dir=$output_dir
    export technical_replicate_variant_window_length_file=$technical_replicate_variant_window_length_file
    if [ "$knit_document_check" -eq 1 ]; then
        Rscript -e "rmarkdown::render('$rmd_script_full_path')"
    else
        Rscript -e "rmarkdown::render('$rmd_script_full_path', run_pandoc=FALSE)" # Run the .rmd script without knitting!
    fi         
    echo "Simulation $counter of $n_simulation_replicates completed"    
}

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
rmd_script_full_path="${pipeline_scripts_dir}/3_Selection_Causative_Variant_window_detection.Rmd"

if [ "$selection_simulation" = TRUE ]; then
    # Get all unique selection scenario types
    # Extract the selection coefficient by finding "s" followed by any number of digits, from the filename of the current bed_file
    # then extract everything to the right, excluding "_ROH_freq.bed
    mapfile -t unique_scenarios < <(find "$selection_pop_roh_freq_dir" -name "*_ROH_freq.bed" | \
        sed -E 's/.*(s[0-9]+.*)_ROH_freq.bed/\1/' | sort -u)
    counter=0
    for selection_scenario_type in "${unique_scenarios[@]}"; do
        echo "Processing selection scenario: $selection_scenario_type"
        # Name the final output file containing the causative variant window lengths of the current selection scenario across the replicates.
        output_variant_window_lengths_file="$output_dir/causative_variant_window_lengths_${selection_scenario_type}.tsv"

        # Creating a temporary folder to store the causative variant window lengths of each technical replicate
        temp_dir="$output_dir/tmp_${selection_scenario_type}"
        mkdir -p "$temp_dir"
        rm -f "$temp_dir"/*.tsv  # Ensure it's clean before starting

        # Get all technical replicates for this scenario
        mapfile -t replicate_beds < <(find "$selection_pop_roh_freq_dir" -name "*${selection_scenario_type}_ROH_freq.bed")
        ((counter++))
        for bed_file in "${replicate_beds[@]}"; do
            input_selection_coefficient_variant_positions_file="$variant_position_dir/variant_position_${selection_scenario_type}.tsv"

            # Define the temp output file
            temp_file="$temp_dir/$(basename "${bed_file%.*}").tsv"

            export pop_roh_freq_bed_file="$bed_file"
            export input_bed_file="$pop_roh_freq_bed_file"
            export input_pop_roh_freq_file="$bed_file"
            export chr_simulated="$chr_simulated"
            export input_selection_coefficient_variant_positions_file="$input_selection_coefficient_variant_positions_file"
            export output_dir="$output_dir"
            export technical_replicate_variant_window_length_file="$temp_file"

             if [ "$counter" -eq 1 ]; then
                knit_document_check=1  # Only knit for the first technical replicate
            else
                knit_document_check=0  # Just run the script for all other cases
            fi 
            echo "  Running replicate: $(basename "$bed_file")"
            find_causative_variant_windows $bed_file $input_selection_coefficient_variant_positions_file $technical_replicate_variant_window_length_file $knit_document_check &

            # Control the number of parallel jobs
            while [ $(jobs -r | wc -l) -ge $max_parallel_jobs ]; do
                wait -n
            done

        done
        # Wait for all replicate jobs to finish for the current selection coefficient
        wait
        # Merge all replicate results into one output file
        echo -e "#Simulation name\tLength (bp)" > "$output_variant_window_lengths_file"
        # Append all files, skipping their header lines
        for file in "$temp_dir"/*.tsv; do
            tail -n +2 "$file" >> "$output_variant_window_lengths_file"
        done

        # Optionally clean up temp dir
        rm -r "$temp_dir"

        echo "Completed scenario: $selection_scenario_type → $(basename "$output_variant_window_lengths_file")"
    done
else
    echo "Selection simulation is set to FALSE. Skipping Causative Window creation"
fi

# Removing the generated .knit.md file
knit_output_file="${rmd_script_full_path%.Rmd}.knit.md"
rm $knit_output_file

# Ending the timer 
script_end=$(date +%s)
# Calculating the runtime of the script
script_runtime=$((script_end-script_start))
echo "Runtime: $script_runtime seconds"