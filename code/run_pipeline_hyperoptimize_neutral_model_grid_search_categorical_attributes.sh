#!/bin/bash

####################################  
# Setting up the pipeline script
#################################### 
# Defining the path to the Conda initialization script
conda_setup_script_path=""
# conda_setup_script_path="/home/jonat/pipeline/anaconda3/etc/profile.d/conda.sh"
source $conda_setup_script_path  # Source Conda initialization script
# Activate the conda environment
conda activate roh_island_sim_env
# Defining the working directory
# export HOME="/home/jonathan/pipeline/Computational-modelling-of-genomic-inbreeding-and-roh-islands-in-extremely-small-populations"
export HOME="$(dirname "$(dirname "$(realpath "$0")")")"

export script_dir="$HOME/code"
export pipeline_scripts_dir="$script_dir/pipeline_scripts"
remove_files_scripts_dir="$script_dir/remove_files_scripts"

export data_dir="$HOME/data_HO"
export results_dir="$HOME/results_HO"
export hyperoptimizer_results_dir="$HOME/hyperoptimizer_results" 
######################################  
####### Defining parameter values #######
######################################
export max_parallel_jobs_neutral_model_simulations=20
export n_simulation_replicates=20
# export n_simulation_replicates=5

export empirical_breed="labrador_retriever"
export empirical_data_basename="LR_fs"
# Set the species for the empirical dataset to determine which species-specific options will be applied during the preprocessing.
export empirical_species="dog"
# Defines the range of autosomal chromosomes to be used in the analysis. This value should be set according to the species being analyzed.  
# The format follows PLINK's chromosome specification (e.g., "1-38" for dog). 
export empirical_autosomal_chromosomes="1-38"


#���������������������
#� Hyperoptimization parameters �
#���������������������
export selection_simulation=FALSE # Leave Unchanged for Hyperparameter Optimization
export empirical_processing=FALSE # Leave Unchanged for Hyperparameter Optimization

export Inbred_ancestral_population=FALSE
export reference_population_for_snp_chip="last_breed_formation_generation" 
export Introduce_mutations=TRUE

# # Get parameters from command line arguments for the hyperoptimization
export HO_results_file=$1
export chr_simulated=$2
export Ne_burn_in=$3
export nInd_founder_population=$4
export N_bottleneck=$4
export n_generations_bottleneck=$5
export n_simulated_generations_breed_formation=$6
export n_individuals_breed_formation=$7
export chr_specific_recombination_rate=$8
# # export reference_population_for_snp_chip=$7
# # export Introduce_mutations=${10}

# export HO_results_file="neutral_models_cost_function_results_HO_german_shepherd.tsv"
# export chr_simulated="chr38" # "chr28" or "chr1"
# export Ne_burn_in=250
# export nInd_founder_population=50 # 50 or 100
# export N_bottleneck=30 # [30,40,50,60,70]
# export n_generations_bottleneck=5
# export n_simulated_generations_breed_formation=5 # [40,45,50,55,60,65,70]
# export n_individuals_breed_formation=100 # [40-70]
# export chr_specific_recombination_rate=TRUE

# Function to handle user interruption
handle_interrupt() {
    echo "Pipeline interrupted. Exiting."
    # Could potentially clean up the files created up until the script termination here
    exit 1
}
# Trap the SIGINT signal (Ctrl+C) and call the handle_interrupt function
trap 'handle_interrupt' SIGINT

# Create a runtime log file
runtime_log="$script_dir/Hyperoptimization_pipeline_runtime_grid_search_categorical_attributes.txt"
# Remove the existing runtime logfile if it exists
if [ -e "$runtime_log" ]; then
    rm "$runtime_log"
fi

# Start the timer 
pipeline_start=$(date +%s)
echo "Pipeline Runtimes:" > $runtime_log
cd $HOME

#���������������������
#� Pipeline Run �
#���������������������
# Step 1 - Extracting the corresponding SNP density for the chromosome to be simulated, from the empirical dataset
step=1
script_name="2_1_1_plink_preprocessing_empirical_data.sh"
preprocessed_data_dir=$data_dir/preprocessed
preprocessed_empirical_breed_dir=$preprocessed_data_dir/empirical/$empirical_breed
output_file="${preprocessed_empirical_breed_dir}/${empirical_breed}_filtered_autosome_lengths_and_marker_density.tsv"
echo "$output_file"
# Check if the output file exists
if [ -f "$output_file" ]; then
    # Remove "chr" prefix from the simulated chromosome (i.e chr3 becomes 3)
    chr_num=$(echo "$chr_simulated" | sed 's/chr//')
    ### Extracting the SNP Density of the selected chromosome that will be simulated ###
    # Step 1: Find the row where column 1 is equal to the chromosome number in $chr_number
    selected_row=$(awk -v chr="$chr_num" '$1 == chr' "$output_file")
    # Step 2: Extract the SNP density value from the selected row
    selected_chr_preprocessed_snp_density_mb=$(echo "$selected_row" | awk '{print $5}')
fi
num_markers_raw_empirical_dataset_scaling_factor=1 # Works good if minSnpFreq is used for the SNP chip in alphasimr
export selected_chr_snp_density_mb=$(echo "$selected_chr_preprocessed_snp_density_mb * $num_markers_raw_empirical_dataset_scaling_factor" | bc)
echo "selected_chr_snp_density_mb: $selected_chr_snp_density_mb"
end_step1=$(date +%s)
runtime_step1=$((end_step1-pipeline_start))
echo "Step $step: Empirical data preprocessing Runtime: $runtime_step1 seconds" >> $runtime_log
((step++))

# Step 2 - Perform Neutral Model Simulations in AlphaSimR
script_name="1_pipeline_neutral_model_simulation.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step2=$(date +%s)
runtime_step2=$((end_step2-end_step1))
echo "Step $step: $script_name Runtime: $runtime_step2 seconds" >> $runtime_log
((step++))

# Step 3 - Preprocessing the Simulated Datasets with PLINK
script_name="2_1_1_plink_preprocessing_simulated_data.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step3=$(date +%s)
runtime_step3=$((end_step3-end_step2))
echo "Step $step: $script_name Runtime: $runtime_step3 seconds" >> $runtime_log
((step++))

# Step 4 - Compute ROH for the simulated Datasets with PLINK
script_name="2_2_1_plink_ROH_computation.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step4=$(date +%s)
runtime_step4=$((end_step4-end_step3))
echo "Step $step: $script_name Runtime: $runtime_step4 seconds" >> $runtime_log
((step++))

# Step 5 - Compute Inbreeding Coefficient for all Datasets 
script_name="2_2_2_F_ROH_computation.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step5=$(date +%s)
runtime_step5=$((end_step5-end_step4))
echo "Step $step: $script_name Runtime: $runtime_step5 seconds" >> $runtime_log
((step++))

# Step 6 - Create Individual ROH .bed-files for all Datasets  
script_name="2_2_3_optimized_create_indv_ROH_bed_file.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step6=$(date +%s)
runtime_step6=$((end_step6-end_step5))
echo "Step $step: $script_name Runtime: $runtime_step6 seconds" >> $runtime_log
((step++))


# Step 7 - Create Window Files to use in the ROH Frequency Computation
script_name="2_3_1_Window_file_creator_for_ROH_frequency_computation.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step7=$(date +%s)
runtime_step7=$((end_step7-end_step6))
echo "Step $step: $script_name Runtime: $runtime_step7 seconds" >> $runtime_log
((step++))

# Step 8 - Compute ROH Frequency using the Coverage Function of Bedtools
script_name="2_3_2_ROH_Coverage.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step8=$(date +%s)
runtime_step8=$((end_step8-end_step7))
echo "Step $step: $script_name Runtime: $runtime_step8 seconds" >> $runtime_log
((step++))

# Step 9 - Detect ROH hotspots for all datasets
script_name="3_pipeline_ROH_hotspot.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step9=$(date +%s)
runtime_step9=$((end_step9-end_step8))
echo "Step $step: $script_name Runtime: $runtime_step9 seconds" >> $runtime_log
((step++))

# Step 10 - Compute Allele Frequencies using PLINK
script_name="4_1_allele_frequencies_for_He_Computation.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step10=$(date +%s)
runtime_step10=$((end_step10-end_step9))
echo "Step $step: $script_name Runtime: $runtime_step10 seconds" >> $runtime_log
((step++))

# Step 11 - Compute Expected Heterozygosity with different MAF pruning thresholds
script_name="H_e_calc_for_multiple_MAF_HO.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step11=$(date +%s)
runtime_step11=$((end_step11-end_step10))
echo "Step $step: $script_name Runtime: $runtime_step11 seconds" >> $runtime_log
((step++))

# Step 12 - Script that computes the cost value for the simulated Neutral Model
script_name="Hyperoptimization_cost_function_results_neutral_model.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step12=$(date +%s)
runtime_step12=$((end_step12-end_step11))
echo "Step $step: $script_name Runtime: $runtime_step12 seconds" >> $runtime_log
((step++))

# Ensure all background processes are completed before proceeding
wait

# Calculate total runtime
total_runtime=$((end_step12-pipeline_start))
echo "Total Pipeline Runtime: $total_runtime seconds" >> $runtime_log

# Print runtimes
for ((i=1; i<step; i++)); do
    script_name=$(eval echo \$script_name$i)
    runtime=$(eval echo \$runtime_step$i)
    echo "Step $i: $script_name Runtime: $runtime seconds"
done

echo "Total Pipeline Runtime: $total_runtime seconds"

source "$remove_files_scripts_dir/pipeline_remove_all_simulation_files_HO.sh"
echo "Move on to next trial"