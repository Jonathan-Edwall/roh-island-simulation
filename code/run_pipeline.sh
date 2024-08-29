#!/bin/bash


####################################  
# Setting up the pipeline script
#################################### 

# Function to handle user interruption
handle_interrupt() {
    echo "Pipeline interrupted. Exiting."
    # Could potentially clean up the files created up until the script termination here
    exit 1
}

# Trap the SIGINT signal (Ctrl+C) and call the handle_interrupt function
trap 'handle_interrupt' SIGINT

# Defining the working directory
HOME=/home/jonathan
cd $HOME

script_dir=$HOME/code

# Create a runtime log file
runtime_log="$script_dir/pipeline_runtime.txt"

# Remove the existing runtime logfile if it exists
if [ -e "$runtime_log" ]; then
    rm "$runtime_log"
fi


# Start the timer 
pipeline_start=$(date +%s)

echo "Pipeline Runtimes:" > $runtime_log

######################################  
####### Defining parameter values #######
######################################
parallelize_simulations=TRUE
# parallelize_simulations=FALSE
# export max_parallel_jobs_selection_sim=4 
export max_parallel_jobs_selection_sim=2 # If i do HO parallel
export n_simulation_replicates=20
export empirical_dog_breed="labrador_retriever"
# Boolean value to determine whether to perform selection model simulations 
# export empirical_processing=FALSE
export selection_simulation=TRUE
# export selection_simulation=FALSE
export empirical_processing=TRUE
export results_dir=$HOME/results
export data_dir=$HOME/data
# export selection_simulation=FALSE
# export empirical_dog_breed="german_shepherd"
# export selection_coefficient_list=(0.5 0.6 0.7 0.8)
# export selection_coefficient_list=(0.9)

# export selection_coefficient_list=(0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8)
export selection_coefficient_list=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8)
# export selection_coefficient_list=(0.2 0.3 0.4 0.5 0.6 0.7 0.8)
# export selection_coefficient_list=(0.3 0.4 0.5 0.6 0.7 0.8)
# export selection_coefficient_list=(0.3 0.4 0.5 0.6 0.7 0.8)
# export selection_coefficient_list=(0.4 0.6 0.8)
# export selection_coefficient_list=(0.4 0.6 0.8)
export fixation_threshold_causative_variant=0.99


# chr1	250	100	TRUE	85	14	60	650	last_bottleneck_generation	TRUE	0.16661	0.03818	0.216	0.5	1.29373

#���������������������
#� Hyperoptimization parameters �
#���������������������
export chr_simulated="chr3" # "chr28" or "chr1"
export Ne_burn_in=3700
export Inbred_ancestral_population=FALSE # TRUE or FALSE
export N_e_bottleneck=5 # [30,40,50,60,70]
export nInd_founder_population=$N_e_bottleneck # 50 or 100
export n_generations_bottleneck=2
export n_simulated_generations_breed_formation=94 # [40,45,50,55,60,65,70]
export n_individuals_breed_formation=370 # [40-70]
# Choose snp chip, either from "last_breed_formation_generation" or last_bottleneck_generation:
# export reference_population_for_snp_chip="last_bottleneck_generation" # Creating the SNP chip based out of the final bottleneck scenario gen
export reference_population_for_snp_chip="last_breed_formation_generation" # Creating the SNP chip based out of the final breed formation scenario gen
export Introduce_mutations=FALSE # TRUE or FALSE





# export chr_simulated="chr38" # "chr28" or "chr1"
# export Ne_burn_in=200
# # export Inbred_ancestral_population=TRUE # TRUE or FALSE
# export Inbred_ancestral_population=FALSE # TRUE or FALSE
# export N_e_bottleneck=20 # [30,40,50,60,70]
# export nInd_founder_population=$N_e_bottleneck # 50 or 100
# export n_generations_bottleneck=1
# export n_simulated_generations_breed_formation=30 # [40,45,50,55,60,65,70]
# export n_individuals_breed_formation=100 # [40-70]
# # Choose snp chip, either from "last_breed_formation_generation" or last_bottleneck_generation:
# export reference_population_for_snp_chip="last_bottleneck_generation" # Creating the SNP chip based out of the final bottleneck scenario gen
# # export reference_population_for_snp_chip="last_breed_formation_generation" # Creating the SNP chip based out of the final breed formation scenario gen
# export Introduce_mutations=FALSE
# # export Introduce_mutations=TRUE




####################################  
# Defining the input files
#################################### 
#�������������
#� Empirical �
#�������������

# Step 1
step=1
script_name="2_1_1_plink_preprocessing_empirical_data.sh"
echo "Step $step: Running $script_name"
source "$script_dir/$script_name"
end_step1=$(date +%s)
runtime_step1=$((end_step1-pipeline_start))
echo "Step $step: $script_name Runtime: $runtime_step1 seconds" >> $runtime_log
((step++))

# # Hardcoding the value number of markers for the raw empirical dataset, due to the dataset already have been preprocessed.
# # If uncommenting this assignement of value to num_markers_raw_empirical_dataset, 
# # the plink_preprocessing_empirical_data will automatically compute this value for you.
# num_markers_raw_empirical_dataset=172115 
# # Perform floating-point division using bc
#num_markers_raw_empirical_dataset_scaling_factor=$(echo "scale=5; $num_markers_raw_empirical_dataset / $num_markers_preprocessed_empirical_dataset" | bc)

# Hardcoding an approximate value of how much more SNP dense the raw simulated datasets have to be,
# So that the preprocessed simulated datasets will have a similar SNP density as the preprocessed empirical german shepherd dataset

#num_markers_raw_empirical_dataset_scaling_factor=3.5 # Works good if minSnpFreq is used for the SNP chip in alphasimr

num_markers_raw_empirical_dataset_scaling_factor=1 # Works good if minSnpFreq is used for the SNP chip in alphasimr

# num_markers_raw_empirical_dataset_scaling_factor=1.85 # Works good if minSnpFreq is used for the SNP chip in alphasimr 

# echo "num_markers_raw_empirical_dataset_scaling_factor: $num_markers_raw_empirical_dataset_scaling_factor"

export selected_chr_snp_density_mb=$(echo "$selected_chr_preprocessed_snp_density_mb * $num_markers_raw_empirical_dataset_scaling_factor" | bc)

echo "selected_chr_snp_density_mb: $selected_chr_snp_density_mb"


if [ "$parallelize_simulations" = TRUE ]; then
    echo "Parallelized simulations set to TRUE. Running the simulations in parallel."
    # Step 2
    script_name="1_pipeline_neutral_model_simulation.sh"
    echo "Step $step: Running $script_name"
    source "$script_dir/pipeline_scripts/$script_name"
    end_step2=$(date +%s)
    runtime_step2=$((end_step2-end_step1))
    echo "Step $step: $script_name Runtime: $runtime_step2 seconds" >> $runtime_log
    ((step++))

    # Step 3
    script_name="2_pipeline_selection_model_simulation.sh"
    echo "Step $step: Running $script_name"
    source "$script_dir/pipeline_scripts/$script_name"
    end_step3=$(date +%s)
    runtime_step3=$((end_step3-end_step2))
    echo "Step $step: $script_name Runtime: $runtime_step3 seconds" >> $runtime_log
    ((step++))
else
    echo "Parallelized simulations set to FALSE. Running the simulations sequentially."
    # Step 2
    script_name="non_parallelized_1_pipeline_neutral_model_simulation.sh"
    echo "Step $step: Running $script_name"
    source "$script_dir/pipeline_scripts/$script_name"
    end_step2=$(date +%s)
    runtime_step2=$((end_step2-end_step1))
    echo "Step $step: $script_name Runtime: $runtime_step2 seconds" >> $runtime_log
    ((step++))

    # Step 3
    script_name="non_parallelized_2_pipeline_selection_model_simulation.sh"
    echo "Step $step: Running $script_name"
    source "$script_dir/pipeline_scripts/$script_name"
    end_step3=$(date +%s)
    runtime_step3=$((end_step3-end_step2))
    echo "Step $step: $script_name Runtime: $runtime_step3 seconds" >> $runtime_log
    ((step++))

fi

# Step 4
script_name="2_1_1_plink_preprocessing_simulated_data.sh"
echo "Step $step: Running $script_name"
source "$script_dir/$script_name"
end_step4=$(date +%s)
runtime_step4=$((end_step4-end_step3))
echo "Step $step: $script_name Runtime: $runtime_step4 seconds" >> $runtime_log
((step++))

# Step 5
script_name="2_2_1_plink_ROH_computation.sh"
echo "Step $step: Running $script_name"
source "$script_dir/$script_name"
end_step5=$(date +%s)
runtime_step5=$((end_step5-end_step4))
echo "Step $step: $script_name Runtime: $runtime_step5 seconds" >> $runtime_log
((step++))

# Step 6
script_name="2_2_2_F_ROH_computation.sh"
echo "Step $step: Running $script_name"
source "$script_dir/$script_name"
end_step6=$(date +%s)
runtime_step6=$((end_step6-end_step5))
echo "Step $step: $script_name Runtime: $runtime_step6 seconds" >> $runtime_log
((step++))

# # Step 7
# script_name="2_2_3_create_indv_ROH_bed_file.sh"
# echo "Step $step: Running $script_name"
# source "$script_dir/$script_name"
# end_step7=$(date +%s)
# runtime_step7=$((end_step7-end_step6))
# echo "Step $step: $script_name Runtime: $runtime_step7 seconds" >> $runtime_log
# ((step++))

# Step 7
script_name="2_2_3_optimized_create_indv_ROH_bed_file.sh"
echo "Step $step: Running $script_name"
source "$script_dir/$script_name"
end_step7=$(date +%s)
runtime_step7=$((end_step7-end_step6))
echo "Step $step: $script_name Runtime: $runtime_step7 seconds" >> $runtime_log
((step++))



# Step 8
script_name="2_3_1_Window_file_creator_for_ROH_frequency_computation.sh"
echo "Step $step: Running $script_name"
source "$script_dir/$script_name"
end_step8=$(date +%s)
runtime_step8=$((end_step8-end_step7))
echo "Step $step: $script_name Runtime: $runtime_step8 seconds" >> $runtime_log
((step++))

# Step 9
script_name="2_3_2_ROH_Coverage.sh"
echo "Step $step: Running $script_name"
source "$script_dir/$script_name"
end_step9=$(date +%s)
runtime_step9=$((end_step9-end_step8))
echo "Step $step: $script_name Runtime: $runtime_step9 seconds" >> $runtime_log
((step++))


# Step 10
script_name="3_pipeline_ROH_hotspot.sh"
echo "Step $step: Running $script_name"
source "$script_dir/pipeline_scripts/$script_name"
end_step10=$(date +%s)
runtime_step10=$((end_step10-end_step9))
echo "Step $step: $script_name Runtime: $runtime_step10 seconds" >> $runtime_log
((step++))

# Step 11
script_name="3_1_map_roh_hotspots_to_phenotypes.sh"
echo "Step $step: Running $script_name"
source "$script_dir/$script_name"
end_step11=$(date +%s)
runtime_step11=$((end_step11-end_step10))
echo "Step $step: $script_name Runtime: $runtime_step11 seconds" >> $runtime_log
((step++))

# Step 12
script_name="3_pipeline_Selection_Causative_Variant_window_detection.sh"
echo "Step $step: Running $script_name"
source "$script_dir/pipeline_scripts/$script_name"
end_step12=$(date +%s)
runtime_step12=$((end_step12-end_step11))
echo "Step $step: $script_name Runtime: $runtime_step12 seconds" >> $runtime_log
((step++))

# Step 13
script_name="4_1_allele_frequencies_for_He_Computation.sh"
echo "Step $step: Running $script_name"
source "$script_dir/$script_name"
end_step13=$(date +%s)
runtime_step13=$((end_step13-end_step12))
echo "Step $step: $script_name Runtime: $runtime_step13 seconds" >> $runtime_log
((step++))

# Step 14
script_name="4_2_map_roh_hotspots_to_allele_frequencies.sh"
echo "Step $step: Running $script_name"
source "$script_dir/$script_name"
end_step14=$(date +%s)
runtime_step14=$((end_step14-end_step13))
echo "Step $step: $script_name Runtime: $runtime_step14 seconds" >> $runtime_log
((step++))

# Step 15
# pipeline_results_for_different_maf.sh runs these scripts, with varying values of MAF:
# * 4_pipeline_Sweep_test.sh
# * pipeline_result_summary.sh
script_name="pipeline_results_for_different_maf.sh"
echo "Step $step: Running $script_name"
source "$script_dir/pipeline_scripts/$script_name"
end_step15=$(date +%s)
runtime_step15=$((end_step15-end_step14))
echo "Step $step: $script_name Runtime: $runtime_step15 seconds" >> $runtime_log
((step++))

# Step 16 (Optional estimation of N_e for the simulated datasets)
script_name="simulated_models_n_e_estimation_with_GONE.sh"
echo "Step $step: Running $script_name"
start_step16=$(date +%s)
source "$script_dir/$script_name"
end_step16=$(date +%s)
runtime_step16=$((end_step16-start_step16))
echo "Step $step: $script_name Runtime: $runtime_step16 seconds" >> $runtime_log
((step++))




# # # Step 15
# # script_name="4_pipeline_Sweep_test.sh"
# # echo "Step $step: Running $script_name"
# # bash "$script_dir/pipeline_scripts/$script_name"
# # end_step15=$(date +%s)
# # runtime_step15=$((end_step15-end_step14))
# # echo "Step $step: $script_name Runtime: $runtime_step15 seconds" >> $runtime_log
# # ((step++))

# # # Step 16
# # script_name="pipeline_result_summary.sh"
# # echo "Step $step: Running $script_name"
# # bash "$script_dir/pipeline_scripts/$script_name"
# # end_step16=$(date +%s)
# # runtime_step16=$((end_step16-end_step15))
# # echo "Step $step: $script_name Runtime: $runtime_step16 seconds" >> $runtime_log
# # ((step++))



# Calculate total runtime
total_runtime=$((end_step16-pipeline_start))
echo "Total Pipeline Runtime: $total_runtime seconds" >> $runtime_log
# Print runtimes
for ((i=1; i<step; i++)); do
    script_name=$(eval echo \$script_name$i)
    runtime=$(eval echo \$runtime_step$i)
    echo "Step $i: $script_name Runtime: $runtime seconds"
done
echo "Total Pipeline Runtime: $total_runtime seconds"

cd $HOME
source "$HOME/remove_individual_coverage_and_ROH_pipeline_files.sh"