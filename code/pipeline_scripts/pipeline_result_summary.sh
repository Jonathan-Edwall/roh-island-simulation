
#!/bin/bash -l

# Start the timer 
start=$(date +%s)


####################################  
# Defining the working directory
#################################### 

HOME=/home/jonathan
#cd $HOME

script_directory=$HOME/code/pipeline_scripts

######################################  
####### Defining parameter values #######
######################################
# empirical_dog_breed="german_shepherd" # Defined in run_pipeline.sh

######################################  
####### Defining the INPUT files #######
######################################  
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
# results_dir=$HOME/results # Variable Defined in run_pipeline.sh

### ROH Hotspots
ROH_hotspots_dir=$results_dir/ROH-Hotspots
# selection_strength_testing_results_dir=$ROH_hotspots_dir/selection_strength_test # Imported from 4_pipeline_Sweep_test.sh
# Sweep_test_dir=$ROH_hotspots_dir/sweep_test # Imported from 4_pipeline_Sweep_test.sh
plink_ROH_dir=$results_dir/PLINK/ROH
# expected_heterozygosity_dir=$results_dir/expected_heterozygosity # Imported from 4_pipeline_Sweep_test.sh
### Raw data
raw_data_dir=$data_dir/raw
raw_simulated_data_dir=$raw_data_dir/simulated
#�������������
#� Empirical �
#�������������

Empirical_breed_ROH_hotspots_dir=$ROH_hotspots_dir/empirical/$empirical_dog_breed
Empirical_breed_autosome_ROH_freq_dir=$Empirical_breed_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq
### Inbreeding coefficient ###
Empirical_breed_F_ROH_dir=$plink_ROH_dir/empirical/$empirical_dog_breed/F_ROH
### Expected Heterozygosity distribution ###
Empirical_breed_H_e_dir=$expected_heterozygosity_dir/empirical/$empirical_dog_breed


#�������������
#� Simulated � 
#�������������
simulated_roh_hotspots_dir=$ROH_hotspots_dir/simulated

### ROH hotspots ###
Neutral_model_ROH_hotspots_dir=$ROH_hotspots_dir/simulated/neutral
Neutral_model_autosome_ROH_freq_dir=$Neutral_model_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq

Selection_model_ROH_hotspots_dir=$ROH_hotspots_dir/simulated/selection
Selection_model_autosome_ROH_freq_dir=$Selection_model_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq

### Inbreeding coefficient ###
Neutral_model_F_ROH_dir=$plink_ROH_dir/simulated/neutral_model/F_ROH
Selection_model_F_ROH_dir=$plink_ROH_dir/simulated/selection_model/F_ROH

### Expected Heterozygosity distribution ###
Neutral_model_H_e_dir="$expected_heterozygosity_dir/simulated/neutral_model"
Selection_model_H_e_dir="$expected_heterozygosity_dir/simulated/selection_model"

### Causative variant (Selection model) ###

raw_selection_dir=$raw_simulated_data_dir/selection_model
variant_freq_plots_dir=$raw_selection_dir/variant_freq_plots
variant_position_dir=$raw_selection_dir/variant_position
pruned_replicates_count_dir=$raw_selection_dir/pruned_counts

Selection_causative_variant_windows_dir=$results_dir/causative_variant_windows
# causative_variant_H_e_dir=$Selection_causative_variant_windows_dir/H_e # Imported from 4_pipeline_Sweep_test.sh


######################################  
####### Defining the OUTPUT files #######
######################################  
# Pipeline_results_output_dir=$results_dir/Pipeline_results

Pipeline_results_output_dir="$results_dir/Pipeline_results_$MAF_status_suffix"
mkdir -p $Pipeline_results_output_dir
##############################################################################################  
############ RESULTS ###########################################################################
############################################################################################## 

# Construct the params list
export Selection_strength_test_dir="$selection_strength_testing_results_dir"
export Sweep_test_dir="$selection_testing_results_dir"

############### 
## Empirical ###
###############

### ROH hotspots ###
export Empirical_data_ROH_hotspots_dir="$Empirical_breed_ROH_hotspots_dir"

export Empirical_data_autosome_ROH_freq_dir="$Empirical_breed_autosome_ROH_freq_dir"
### Inbreeding coefficient ###
export Empirical_data_F_ROH_dir="$Empirical_breed_F_ROH_dir"
### Expected Heterozygosity distribution ###
export Empirical_data_H_e_dir="$Empirical_breed_H_e_dir"

############### 
## Simulated ###
###############

### ROH hotspots ###
export Neutral_model_ROH_hotspots_dir="$Neutral_model_ROH_hotspots_dir"
export Neutral_model_autosome_ROH_freq_dir="$Neutral_model_autosome_ROH_freq_dir"
export Selection_model_ROH_hotspots_dir="$Selection_model_ROH_hotspots_dir"
export Selection_model_autosome_ROH_freq_dir="$Selection_model_autosome_ROH_freq_dir"

### Inbreeding coefficient ###
export Neutral_model_F_ROH_dir="$Neutral_model_F_ROH_dir"
export Selection_model_F_ROH_dir="$Selection_model_F_ROH_dir"

### Expected Heterozygosity distribution ###
export Neutral_model_H_e_dir="$Neutral_model_H_e_dir"
export Selection_model_H_e_dir="$Selection_model_H_e_dir"

### Causative Variant ###
export variant_freq_plots_dir="$variant_freq_plots_dir"
export variant_position_dir="$variant_position_dir"
export pruned_replicates_count_dir="$pruned_replicates_count_dir"

export Selection_causative_variant_windows_dir="$Selection_causative_variant_windows_dir"
export causative_variant_windows_H_e_dir="$causative_variant_H_e_dir"

# Output_dir
export Pipeline_results_output_dir="$Pipeline_results_output_dir"
export document_sub_title="$result_file_sub_title" # Imported from pipeline_results_for_different_maf.sh

# Modify the pipeline_result_summary.sh script call to include the MAF status suffix in the output file name
output_file="$Pipeline_results_output_dir/pipeline_results_${MAF_status_suffix}.html"
Rscript -e "rmarkdown::render('$script_directory/pipeline_results.Rmd', output_file = '$output_file')"


# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Pipeline results finished"
echo "Runtime: $runtime seconds"

