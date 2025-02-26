#!/bin/bash

####################################  
# Setting up the pipeline script
#################################### 
export pipeline_scripts_dir="$script_dir/pipeline_scripts"
remove_files_scripts_dir="$script_dir/remove_files_scripts"



######################################  
####### Defining parameter values #######
######################################
# Boolean value to determine whether to perform selection model simulations 
export selection_simulation=TRUE # TRUE/FALSE
export empirical_processing=TRUE # TRUE/FALSE

export max_parallel_jobs_neutral_model_simulations=30
export max_parallel_jobs_selection_sim=7 # 8
export n_simulation_replicates=50 # 50

# Boolean value to determine whether to perform selection model simulations 
export selection_simulation=TRUE
export empirical_processing=TRUE

# export selection_coefficient_list=(0.075 0.1 0.125 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8)
export selection_coefficient_list=(0.4 0.5 0.6 0.7 0.8)
export fixation_threshold_causative_variant=0.99

export Inbred_ancestral_population=FALSE # TRUE or FALSE
export nInd_founder_population=$N_bottleneck # 50 or 100
export reference_population_for_snp_chip="last_breed_formation_generation" # Creating the SNP chip based out of the final breed formation scenario gen
export Introduce_mutations=TRUE

####################################  
# Defining the input files
#################################### 
# Function to handle user interruption
handle_interrupt() {
    echo "Pipeline interrupted. Exiting."
    # Could potentially clean up the files created up until the script termination here
    exit 1
}
# Trap the SIGINT signal (Ctrl+C) and call the handle_interrupt function
trap 'handle_interrupt' SIGINT

# Remove the existing runtime logfile if it exists
if [ -e "$runtime_log" ]; then
    rm "$runtime_log"
fi
# Start the timer 
pipeline_start=$(date +%s)
echo "Pipeline Runtimes:" > $runtime_log
# Changing the working directory
cd $HOME

#���������������������
#� Pipeline Run �
#���������������������

# Step 1 - Preprocessing the Emprical Dataset with PLINK
# Note: 
# To run Step 2 - Perform Neutral Model Simulations in AlphaSimR (2_1_1_plink_preprocessing_empirical_data.sh)
# And Step 3 - Perform Selection Model Simulations in AlphaSimR (2_pipeline_selection_model_simulation_sequentially.sh)
# This script will have to remain uncommented and be executed (2_1_1_plink_preprocessing_empirical_data.sh) to provide these AlphaSimR script with the SNP density ($selected_chr_snp_density_mb) to use
# for simulating the selected chromosome ($chr_simulated)
step=1
script_name="2_1_1_plink_preprocessing_empirical_data.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step1=$(date +%s)
runtime_step1=$((end_step1-pipeline_start))
echo "Step $step: $script_name Runtime: $runtime_step1 seconds" >> $runtime_log
((step++))
num_markers_raw_empirical_dataset_scaling_factor=1 # Works good if minSnpFreq is used for the SNP chip in alphasimr
# echo "num_markers_raw_empirical_dataset_scaling_factor: $num_markers_raw_empirical_dataset_scaling_factor"
export selected_chr_snp_density_mb=$(echo "$selected_chr_preprocessed_snp_density_mb * $num_markers_raw_empirical_dataset_scaling_factor" | bc)
echo "selected_chr_snp_density_mb: $selected_chr_snp_density_mb"

# Step 2 - Perform Neutral Model Simulations in AlphaSimR
script_name="1_pipeline_neutral_model_simulation.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step2=$(date +%s)
runtime_step2=$((end_step2-end_step1))
echo "Step $step: $script_name Runtime: $runtime_step2 seconds" >> $runtime_log
((step++))

# Step 3 - Perform Selection Model Simulations in AlphaSimR
script_name="2_pipeline_selection_model_simulation_sequentially.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step3=$(date +%s)
runtime_step3=$((end_step3-end_step2))
echo "Step $step: $script_name Runtime: $runtime_step3 seconds" >> $runtime_log
((step++))        

# Step 4 - Preprocessing the Simulated Datasets with PLINK
script_name="2_1_1_plink_preprocessing_simulated_data.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step4=$(date +%s)
runtime_step4=$((end_step4-end_step3))
echo "Step $step: $script_name Runtime: $runtime_step4 seconds" >> $runtime_log
((step++))

# Step 5 - Compute ROH for all Datasets with PLINK
script_name="2_2_1_plink_ROH_computation.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step5=$(date +%s)
runtime_step5=$((end_step5-end_step4))
echo "Step $step: $script_name Runtime: $runtime_step5 seconds" >> $runtime_log
((step++))

# Step 6 - Compute Inbreeding Coefficient for all Datasets 
script_name="2_2_2_F_ROH_computation.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step6=$(date +%s)
runtime_step6=$((end_step6-end_step5))
echo "Step $step: $script_name Runtime: $runtime_step6 seconds" >> $runtime_log
((step++))

# Step 7 - Create Individual ROH .bed-files for all Datasets  
script_name="2_2_3_optimized_create_indv_ROH_bed_file.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step7=$(date +%s)
runtime_step7=$((end_step7-end_step6))
echo "Step $step: $script_name Runtime: $runtime_step7 seconds" >> $runtime_log
((step++))

# Step 8 - Create Window Files to use in the ROH Frequency Computation
script_name="2_3_1_Window_file_creator_for_ROH_frequency_computation.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step8=$(date +%s)
runtime_step8=$((end_step8-end_step7))
echo "Step $step: $script_name Runtime: $runtime_step8 seconds" >> $runtime_log
((step++))

# Step 9 - Compute ROH Frequency using the Coverage Function of Bedtools
script_name="2_3_2_ROH_Coverage.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step9=$(date +%s)
runtime_step9=$((end_step9-end_step8))
echo "Step $step: $script_name Runtime: $runtime_step9 seconds" >> $runtime_log
((step++))


# Step 10 - Detect ROH hotspots for all datasets
script_name="3_pipeline_ROH_hotspot.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step10=$(date +%s)
runtime_step10=$((end_step10-end_step9))
echo "Step $step: $script_name Runtime: $runtime_step10 seconds" >> $runtime_log
((step++))

# Step 11 - Map Empirical ROH Hotspots to OMIA Phenotypes
script_name="3_1_map_roh_hotspots_to_phenotypes.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step11=$(date +%s)
runtime_step11=$((end_step11-end_step10))
echo "Step $step: $script_name Runtime: $runtime_step11 seconds" >> $runtime_log
((step++))

# Step 12 - Map Empirical ROH Hotspots to Gene Annotations
script_name="3_2_map_roh_hotspots_to_gene_annotations.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step12=$(date +%s)
runtime_step12=$((end_step12-end_step11))
echo "Step $step: $script_name Runtime: $runtime_step12 seconds" >> $runtime_log
((step++))

# Step 13 - Detect Causative Variant Windows for the Selection Models
script_name="3_pipeline_Selection_Causative_Variant_window_detection.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step13=$(date +%s)
runtime_step13=$((end_step13-end_step12))
echo "Step $step: $script_name Runtime: $runtime_step13 seconds" >> $runtime_log
((step++))

# Step 14 - Compute Allele Frequencies using PLINK
script_name="4_1_allele_frequencies_for_He_Computation.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step14=$(date +%s)
runtime_step14=$((end_step14-end_step13))
echo "Step $step: $script_name Runtime: $runtime_step14 seconds" >> $runtime_log
((step++))

# Step 15 - Map the Allele Frequencies to the different ROH Hotspots
script_name="4_2_map_roh_hotspots_to_allele_frequencies.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step15=$(date +%s)
runtime_step15=$((end_step15-end_step14))
echo "Step $step: $script_name Runtime: $runtime_step15 seconds" >> $runtime_log
((step++))

# Step 16 - Perform Sweep test & Run the Pipeline Summarize script to generate a summarizing HTML-file of the pipeline run.
# pipeline_results_for_different_maf.sh runs these scripts, with varying values of MAF:
# * 4_pipeline_Sweep_test.sh
# * pipeline_result_summary.sh
start_16=$(date +%s)
script_name="pipeline_results_for_different_maf.sh"
echo "Step $step: Running $script_name"
source "$pipeline_scripts_dir/$script_name"
end_step16=$(date +%s)
runtime_step16=$((end_step16-start_16))
echo "Step $step: $script_name Runtime: $runtime_step16 seconds" >> $runtime_log
((step++))



# # Step 17 (Optional estimation of N_e for the simulated datasets)
# script_name="simulated_models_n_e_estimation_with_GONE.sh"
# echo "Step $step: Running $script_name"
# start_step17=$(date +%s)
# source "$pipeline_scripts_dir/$script_name"
# end_step17=$(date +%s)
# runtime_step17=$((end_step17-start_step17))
# echo "Step $step: $script_name Runtime: $runtime_step17 seconds" >> $runtime_log
# ((step++))


# # Step 18 (Optional estimation of N_e for the empirical dataset)
# script_name="empirical_n_e_estimation_with_GONE.sh"
# echo "Step $step: Running $script_name"
# start_step18=$(date +%s)
# source "$pipeline_scripts_dir/$script_name"
# end_step18=$(date +%s)
# runtime_step18=$((end_step18-start_step18))
# echo "Step $step: $script_name Runtime: $runtime_step18 seconds" >> $runtime_log
# ((step++))


final_step=$(date +%s)
# Calculate total runtime
total_runtime=$((final_step-pipeline_start))
echo "Total Pipeline Runtime: $total_runtime seconds" >> $runtime_log
# Print runtimes
for ((i=1; i<step; i++)); do
    script_name=$(eval echo \$script_name$i)
    runtime=$(eval echo \$runtime_step$i)
    echo "Step $i: $script_name Runtime: $runtime seconds"
done
echo "Total Pipeline Runtime: $total_runtime seconds"

cd $HOME
source "$remove_files_scripts_dir/remove_individual_coverage_and_ROH_pipeline_files.sh"