
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
# export empirical_dog_breed="german_shepherd"
# empirical_dog_breed="empirical_breed" # Defined in run_pipeline_hyperoptimize_neutral_model.sh

# chr_simulated # Imported from run_pipeline_hyperoptimize_neutral_model.sh

# Ne_burn_in # Imported from run_pipeline_hyperoptimize_neutral_model.sh

# nInd_founder_population # Imported from run_pipeline_hyperoptimize_neutral_model.sh

# Inbred_ancestral_population # Imported from run_pipeline_hyperoptimize_neutral_model.sh

# N_e_bottleneck # Imported from run_pipeline_hyperoptimize_neutral_model.sh

# n_simulated_generations_breed_formation # Imported from run_pipeline_hyperoptimize_neutral_model.sh

# n_individuals_breed_formation # Imported from run_pipeline_hyperoptimize_neutral_model.sh

# reference_population_for_snp_chip # Imported from run_pipeline_hyperoptimize_neutral_model.sh


######################################  
####### Defining the INPUT files #######
######################################  
# results_dir=$HOME/results # Variable Defined in run_pipeline_hyperoptimize_neutral_model.sh

### ROH Hotspots
ROH_hotspots_dir=$results_dir/ROH-Hotspots

plink_ROH_dir=$results_dir/PLINK/ROH
# expected_heterozygosity_dir=$results_dir/expected_heterozygosity # Imported from Hyperoptimization_H_e_calculation.sh

### Raw data
# data_dir=$HOME/results # Variable Defined in run_pipeline_hyperoptimize_neutral_model.sh
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
# Empirical_breed_H_e_dir=$expected_heterozygosity_dir/empirical/$empirical_dog_breed # Imported from Hyperoptimization_H_e_calculation.sh

#�������������
#� Simulated � 
#�������������
simulated_roh_hotspots_dir=$ROH_hotspots_dir/simulated

### ROH hotspots ###
Neutral_model_ROH_hotspots_dir=$ROH_hotspots_dir/simulated/neutral
Neutral_model_autosome_ROH_freq_dir=$Neutral_model_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq

### Inbreeding coefficient ###
Neutral_model_F_ROH_dir=$plink_ROH_dir/simulated/neutral_model/F_ROH

### Expected Heterozygosity distribution ###
Neutral_model_H_e_dir="$expected_heterozygosity_dir/simulated/neutral_model"

######################################  
####### Defining the OUTPUT files #######
######################################  
hyperoptimizer_results_dir=$HOME/hyperoptimizer_results
mkdir -p $hyperoptimizer_results_dir

##############################################################################################  
############ RESULTS ###########################################################################
############################################################################################## 
export expected_heterozygosity_dir_NO_MAF="$results_dir/expected_heterozygosity_No_MAF"
export expected_heterozygosity_dir_MAF_0_05="$results_dir/expected_heterozygosity_MAF_0_05"

############### 
## Empirical ###
###############

### ROH hotspots ###
export Empirical_data_ROH_hotspots_dir="$Empirical_breed_ROH_hotspots_dir"

export Empirical_data_autosome_ROH_freq_dir="$Empirical_breed_autosome_ROH_freq_dir"
### Inbreeding coefficient ###
export Empirical_data_F_ROH_dir="$Empirical_breed_F_ROH_dir"
### Expected Heterozygosity distribution ###
# MAF_status_suffix="No_MAF"
# expected_heterozygosity_dir="$results_dir/expected_heterozygosity_$MAF_status_suffix"
# Empirical_breed_H_e_dir=$expected_heterozygosity_dir/empirical/$empirical_dog_breed

# export Empirical_data_H_e_dir="$Empirical_breed_H_e_dir"

############### 
## Simulated ###
###############

### ROH hotspots ###
export Neutral_model_ROH_hotspots_dir="$Neutral_model_ROH_hotspots_dir"
export Neutral_model_autosome_ROH_freq_dir="$Neutral_model_autosome_ROH_freq_dir"

### Inbreeding coefficient ###
export Neutral_model_F_ROH_dir="$Neutral_model_F_ROH_dir"

### Expected Heterozygosity distribution ###
# export Neutral_model_H_e_dir="$Neutral_model_H_e_dir"


# Output_dir
export hyperoptimizer_results_dir="$hyperoptimizer_results_dir"

# # Modify the pipeline_result_summary.sh script call to include the MAF status suffix in the output file name
# output_file="$Pipeline_results_output_dir/pipeline_results_${MAF_status_suffix}.html"

# Rscript -e "rmarkdown::render('$script_directory/Hyperoptimization_cost_function_results_neutral_model.Rmd', output_file = '$output_file')"
Rscript -e "rmarkdown::render('$script_directory/Hyperoptimization_cost_function_results_neutral_model.Rmd')"

# Ending the timer 
script_end=$(date +%s)
# Calculating the runtime of the script
script_runtime=$((script_end-script_start))

echo "Cost function value computed for the simulated Neutral Model"
echo "Results stored in $hyperoptimizer_results_dir"
echo "Runtime: $script_runtime seconds"

