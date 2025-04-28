
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

####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME

# pipeline_scripts_dir=$script_dir/pipeline_scripts

######################################  
####### Defining the INPUT files #######
######################################  
# results_dir=$HOME/results # Variable Defined in run_pipeline.sh
bedtools_results_dir=$results_dir/Bedtools/coverage

#�������������
#� Empirical �
#�������������
# empirical_breed="german_shepherd" # Defined in run_pipeline.sh
coverage_output_empirical_breed_dir=$bedtools_results_dir/empirical/$empirical_breed

roh_frequencies_empirical_breed_dir=$coverage_output_empirical_breed_dir/pop_roh_freq

#�������������
#� Simulated � 
#�������������
simulated_bedtools_dir=$bedtools_results_dir/simulated
##### Neutral Model #####
coverage_output_neutral_model_dir=$simulated_bedtools_dir/neutral_model
roh_frequencies_neutral_model_dir=$coverage_output_neutral_model_dir/pop_roh_freq
##### Selection Model ##### 
coverage_output_selection_model_dir=$simulated_bedtools_dir/selection_model
roh_frequencies_selection_model_dir=$coverage_output_selection_model_dir/pop_roh_freq

######################################  
####### Defining the OUTPUT files #######
######################################  
ROH_hotspots_dir=$results_dir/ROH-Hotspots

all_chr_roh_freq_dir_relative_path=Gosling_plots/all_chr_roh_freq

#�������������
#� Empirical �
#�������������
roh_hotspots_output_empirical_breed_dir=$ROH_hotspots_dir/empirical/$empirical_breed
mkdir -p $roh_hotspots_output_empirical_breed_dir # Creating subdirectory if it doesn't already exist

gapless_roh_hotspots_empirical_breed_dir=$roh_hotspots_output_empirical_breed_dir/gapless_roh_hotspots
mkdir -p $gapless_roh_hotspots_empirical_breed_dir # Creating subdirectory if it doesn't already exist

autosome_roh_freq_empirical_breed_dir=$roh_hotspots_output_empirical_breed_dir/Gosling_plots/autosome_roh_freq
mkdir -p $autosome_roh_freq_empirical_breed_dir # Creating subdirectory if it doesn't already exist

roh_hotspots_freq_empirical_breed_dir=$roh_hotspots_output_empirical_breed_dir/Gosling_plots/roh_hotspots_freq
mkdir -p $roh_hotspots_freq_empirical_breed_dir # Creating subdirectory if it doesn't already exist

#�������������
#� Simulated � 
#�������������
preprocessed_data_dir=$data_dir/preprocessed
preprocessed_simulated_data_dir=$preprocessed_data_dir/simulated
preprocessed_neutral_model_dir=$preprocessed_simulated_data_dir/neutral_model
preprocessed_selection_model_dir=$preprocessed_simulated_data_dir/selection_model


simulated_roh_hotspots_dir=$ROH_hotspots_dir/simulated
##### Neutral Model #####
Neutral_model_ROH_hotspots_dir=$simulated_roh_hotspots_dir/neutral
mkdir -p $Neutral_model_ROH_hotspots_dir # Creating subdirectory if it doesn't already exist


gapless_roh_hotspots_neutral_model_dir=$Neutral_model_ROH_hotspots_dir/gapless_roh_hotspots
mkdir -p $gapless_roh_hotspots_neutral_model_dir # Creating subdirectory if it doesn't already exist

autosome_roh_freq_neutral_model_dir=$Neutral_model_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq
mkdir -p $autosome_roh_freq_neutral_model_dir # Creating subdirectory if it doesn't already exist

roh_hotspots_freq_neutral_model_dir=$Neutral_model_ROH_hotspots_dir/Gosling_plots/roh_hotspots_freq
mkdir -p $roh_hotspots_freq_neutral_model_dir # Creating subdirectory if it doesn't already exist

##### Selection Model ##### 
Selection_model_ROH_hotspots_dir=$simulated_roh_hotspots_dir/selection
mkdir -p $Selection_model_ROH_hotspots_dir # Creating subdirectory if it doesn't already exist


gapless_roh_hotspots_selection_model_dir=$Selection_model_ROH_hotspots_dir/gapless_roh_hotspots
mkdir -p $gapless_roh_hotspots_selection_model_dir # Creating subdirectory if it doesn't already exist

autosome_roh_freq_selection_model_dir=$Selection_model_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq
mkdir -p $autosome_roh_freq_selection_model_dir # Creating subdirectory if it doesn't already exist

roh_hotspots_freq_selection_model_dir=$Selection_model_ROH_hotspots_dir/Gosling_plots/roh_hotspots_freq
mkdir -p $roh_hotspots_freq_selection_model_dir # Creating subdirectory if it doesn't already exist


##############################################################################################  
############ RESULTS ###########################################################################
############################################################################################## 
rmd_script_full_path="${pipeline_scripts_dir}/3_ROH_hotspots_identification.Rmd"

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Empirical Data  ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
if [ "$empirical_processing" = TRUE ]; then
    # Generate the list of .bed files in the directory
    bed_files_list=("$roh_frequencies_empirical_breed_dir"/*.bed)
    # Loop over each input bed file
    for bed_file in "${bed_files_list[@]}"; do
        export pop_roh_freq_bed_file="$bed_file"
        echo "$pop_roh_freq_bed_file"
        # Construct the params list
        export input_bed_file="$pop_roh_freq_bed_file"
        export output_directory="$roh_hotspots_output_empirical_breed_dir"
        export gapless_roh_hotspots_directory="$gapless_roh_hotspots_empirical_breed_dir"
        export autosome_roh_freq_directory="$autosome_roh_freq_empirical_breed_dir"
        export roh_hotspots_freq_directory="$roh_hotspots_freq_empirical_breed_dir"
        export simulation_processing=FALSE
        # Render the R Markdown document with the current input bed file
        Rscript -e "rmarkdown::render('$rmd_script_full_path')"
    done
    wait
    echo "ROH-Hotspots detected for $empirical_breed"
    echo "The results are stored in: $roh_hotspots_output_empirical_breed_dir"
else
    echo "Empirical data has been set to not be processed, since files have already been created."
fi

# Function to process ROH hotspots for a given set of bed files
process_roh_hotspots() {
    local bed_file=$1
    local output_directory=$2  # Output directory for the results
    local gapless_roh_hotspots_simulation_model_dir=$3
    local autosome_roh_freq_simulation_model_dir=$4
    local roh_hotspots_freq_simulation_model_dir=$5
    local knit_document_check=$6 # Variable that controls the knitting of the .rmd file   
    local max_length_chromosome=$7
    export pop_roh_freq_bed_file="$bed_file"
    export input_bed_file="$pop_roh_freq_bed_file"
    export max_length_chromosome="$max_length_chromosome"
    echo "Processing: $pop_roh_freq_bed_file"
    export simulation_processing=TRUE
    # Construct the params list
    export input_bed_file="$pop_roh_freq_bed_file"
    export output_directory="$output_directory"
    export gapless_roh_hotspots_directory="$gapless_roh_hotspots_simulation_model_dir"  # Adjust as needed
    export autosome_roh_freq_directory="$autosome_roh_freq_simulation_model_dir"  # Adjust as needed
    export roh_hotspots_freq_directory="$roh_hotspots_freq_simulation_model_dir"  # Adjust as needed
    if [ "$knit_document_check" -eq 1 ]; then
        Rscript -e "rmarkdown::render('$rmd_script_full_path')"
    else
        Rscript -e "rmarkdown::render('$rmd_script_full_path', run_pandoc=FALSE)"
    fi         

}
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Generate the list of .bed files in the directory
readarray -t Neutral_model_bed_files < <(ls "$roh_frequencies_neutral_model_dir"/*.bed | sort -Vu)
counter=0
# Loop over each input bed file
for bed_file in "${Neutral_model_bed_files[@]}"; do
    ((counter++)) 
    if [ "$counter" -eq 1 ]; then
        knit_document_check=1  # Only knit for the first simulation
    else
        knit_document_check=0  # Just run the script for all other cases
    fi
    filename=$(basename "$bed_file")
    # Extract the simulation name
    simulation_name="${filename%_ROH_freq.bed}"
    autosome_lengths_file="${preprocessed_neutral_model_dir}/${simulation_name}_autosome_lengths_and_marker_density.tsv"
    max_length_chromosome=$(awk 'NR==2 {print $2}' $autosome_lengths_file) 
    process_roh_hotspots $bed_file $Neutral_model_ROH_hotspots_dir $gapless_roh_hotspots_neutral_model_dir $autosome_roh_freq_neutral_model_dir $roh_hotspots_freq_neutral_model_dir $knit_document_check $max_length_chromosome &
    # Control the number of parallel jobs
    while [ $(jobs -r | wc -l) -ge $max_parallel_jobs ]; do
        wait -n
    done
done
# Wait for all background jobs to finish
wait
echo "ROH-Hotspots detected for the Neutral Model Simulations"
echo "The results are stored in: $Neutral_model_ROH_hotspots_dir"

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
if [ "$selection_simulation" = TRUE ]; then
    # Generate the list of .bed files in the directory
    readarray -t Selection_models_bed_files < <(ls "$roh_frequencies_selection_model_dir"/*.bed | sort -Vu)
    counter=0
    # Loop over each input bed file
    for bed_file in "${Selection_models_bed_files[@]}"; do
        ((counter++)) 
        if [ "$counter" -eq 1 ]; then
            knit_document_check=1  # Only knit for the first simulation
        else
            knit_document_check=0  # Just run the script for all other cases
        fi
        filename=$(basename "$bed_file")
        # Extract the simulation name
        simulation_name="${filename%_ROH_freq.bed}"
        autosome_lengths_file="${preprocessed_selection_model_dir}/${simulation_name}_autosome_lengths_and_marker_density.tsv"
        max_length_chromosome=$(awk 'NR==2 {print $2}' $autosome_lengths_file)
        process_roh_hotspots "$bed_file" "$Selection_model_ROH_hotspots_dir" "$gapless_roh_hotspots_selection_model_dir" "$autosome_roh_freq_selection_model_dir" "$roh_hotspots_freq_selection_model_dir" $knit_document_check $max_length_chromosome &
        # Control the number of parallel jobs
        while [ "$(jobs -r | wc -l)" -ge "$max_parallel_jobs" ]; do
            wait -n
        done
    done
    # Wait for all background jobs to finish
    wait
    echo "ROH-Hotspots detected for the Selection Model Simulations"
    echo "The results are stored in: $Selection_model_ROH_hotspots_dir"

else
    echo "Selection simulation is set to FALSE. Skipping the selection model processing."
fi

# Removing the generated .knit.md file
knit_output_file="${rmd_script_full_path%.Rmd}.knit.md"
rm $knit_output_file

# Ending the timer 
script_end=$(date +%s)
# Calculating the runtime of the script
script_runtime=$((script_end-script_start))

echo "ROH-Hotspots computed for all the datasets"
echo "Runtime: $script_runtime seconds"

