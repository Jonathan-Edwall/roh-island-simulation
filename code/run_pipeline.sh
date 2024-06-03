#!/bin/bash

# Start the timer 
start=$(date +%s)

####################################  
# Defining the working directory
#################################### 

HOME=/home/jonathan
#cd $HOME

script_dir=$HOME/code

# Create a runtime log file

runtime_log="$script_dir/pipeline_runtime.txt"

# Remove the existing runtime logfile if it exists
if [ -e "$runtime_log" ]; then
    rm "$runtime_log"
fi


echo "Pipeline Runtimes:" > $runtime_log


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
export chr_simulated="chr3"
export n_simulation_replicates=5
export n_simulated_generations_breed_formation=40
export n_individuals_breed_formation=50


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
runtime_step1=$((end_step1-start))
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

# Step 4
script_name="2_1_1_plink_preprocessing_simulated_data.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/$script_name"
end_step4=$(date +%s)
runtime_step4=$((end_step4-end_step3))
echo "Step $step: $script_name Runtime: $runtime_step4 seconds" >> $runtime_log
((step++))

# Step 5
script_name="2_2_1_plink_ROH_computation.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/$script_name"
end_step5=$(date +%s)
runtime_step5=$((end_step5-end_step4))
echo "Step $step: $script_name Runtime: $runtime_step5 seconds" >> $runtime_log
((step++))

# Step 6
script_name="2_2_2_F_ROH_computation.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/$script_name"
end_step6=$(date +%s)
runtime_step6=$((end_step6-end_step5))
echo "Step $step: $script_name Runtime: $runtime_step6 seconds" >> $runtime_log
((step++))

# Step 7
script_name="2_2_3_create_indv_ROH_bed_file.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/$script_name"
end_step7=$(date +%s)
runtime_step7=$((end_step7-end_step6))
echo "Step $step: $script_name Runtime: $runtime_step7 seconds" >> $runtime_log
((step++))


# Step 8
script_name="2_3_1_Window_file_creator_for_ROH_frequency_computation.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/$script_name"
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
bash "$script_dir/pipeline_scripts/$script_name"
end_step10=$(date +%s)
runtime_step10=$((end_step10-end_step9))
echo "Step $step: $script_name Runtime: $runtime_step10 seconds" >> $runtime_log
((step++))

# Step 11
script_name="3_1_map_roh_hotspots_to_phenotypes.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/$script_name"
end_step11=$(date +%s)
runtime_step11=$((end_step11-end_step10))
echo "Step $step: $script_name Runtime: $runtime_step11 seconds" >> $runtime_log
((step++))


# Step 12
script_name="3_pipeline_Selection_Causative_Variant_window_detection.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/pipeline_scripts/$script_name"
end_step12=$(date +%s)
runtime_step12=$((end_step12-end_step11))
echo "Step $step: $script_name Runtime: $runtime_step12 seconds" >> $runtime_log
((step++))


# Step 13
script_name="4_1_allele_frequencies_for_He_Computation.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/$script_name"
end_step13=$(date +%s)
runtime_step13=$((end_step13-end_step12))
echo "Step $step: $script_name Runtime: $runtime_step13 seconds" >> $runtime_log
((step++))


# Step 14
script_name="4_2_map_roh_hotspots_to_allele_frequencies.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/$script_name"
end_step14=$(date +%s)
runtime_step14=$((end_step14-end_step13))
echo "Step $step: $script_name Runtime: $runtime_step14 seconds" >> $runtime_log
((step++))

# Step 15
script_name="4_pipeline_Sweep_test.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/pipeline_scripts/$script_name"
end_step15=$(date +%s)
runtime_step15=$((end_step15-end_step14))
echo "Step $step: $script_name Runtime: $runtime_step15 seconds" >> $runtime_log
((step++))

# Step 16
script_name="pipeline_result_summary.sh"
echo "Step $step: Running $script_name"
bash "$script_dir/pipeline_scripts/$script_name"
end_step16=$(date +%s)
runtime_step16=$((end_step16-end_step15))
echo "Step $step: $script_name Runtime: $runtime_step16 seconds" >> $runtime_log
((step++))



# Calculate total runtime
total_runtime=$((end_step16-start))
echo "Total Pipeline Runtime: $total_runtime seconds" >> $runtime_log

# Print runtimes
for ((i=1; i<step; i++)); do
    script_name=$(eval echo \$script_name$i)
    runtime=$(eval echo \$runtime_step$i)
    echo "Step $i: $script_name Runtime: $runtime seconds"
done
echo "Total Pipeline Runtime: $total_runtime seconds"