
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)


####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME

# pipeline_scripts_dir=$HOME/code/pipeline_scripts
# pipeline_scripts_dir=$script_dir/pipeline_scripts
######################################  
####### Defining parameter values #######
######################################
# export use_MAF_pruning=TRUE # Imported from H_e_calc_for_multiple_MAF_HO.sh
# export min_MAF=0.01 # Imported from H_e_calc_for_multiple_MAF_HO.sh

# empirical_dog_breed="empirical_breed" # Variable Defined in run_pipeline_hyperoptimize_neutral_model.sh

# MAF_status_suffix="No_MAF" # Imported from H_e_calc_for_multiple_MAF_HO.sh
# MAF_status_suffix="MAF_0_01" # Imported from H_e_calc_for_multiple_MAF_HO.sh

# $results_dir/expected_heterozygosity_$MAF_status_suffix
######################################  
####### Defining the INPUT files #######
######################################  
# results_dir=$HOME/results_HO # Variable Defined in run_pipeline_hyperoptimize_neutral_model.sh
PLINK_allele_freq_dir=$results_dir/PLINK/allele_freq

#�������������
#� Empirical �
#�������������
##### Genomewide Allele frequencies #####
Empirical_breed_allele_freq_dir=$PLINK_allele_freq_dir/empirical/$empirical_dog_breed
##### ROH-hotspot Allele frequencies #####
roh_hotspots_results_dir=$results_dir/ROH-Hotspots
empirical_roh_hotspots_dir=$roh_hotspots_results_dir/empirical/$empirical_dog_breed
Empirical_breed_roh_hotspots_allele_frequency_dir=$empirical_roh_hotspots_dir/hotspots_allele_freq

#�������������
#� Simulated � 
#�������������
simulated_allele_freq_plink_output_dir=$PLINK_allele_freq_dir/simulated
##### Neutral Model #####
neutral_model_allele_freq_dir=$simulated_allele_freq_plink_output_dir/neutral_model

######################################  
####### Defining the OUTPUT files #######
######################################  
export expected_heterozygosity_dir="$results_dir/expected_heterozygosity_$MAF_status_suffix"
mkdir -p $expected_heterozygosity_dir

#�������������
#� Empirical �
#�������������
export Empirical_breed_H_e_dir="$expected_heterozygosity_dir/empirical/$empirical_dog_breed"
mkdir -p $Empirical_breed_H_e_dir
##### Neutral Model #####
neutral_model_H_e_dir="$expected_heterozygosity_dir/simulated/neutral_model"
mkdir -p $neutral_model_H_e_dir

##############################################################################################  
############ RESULTS ###########################################################################
############################################################################################## 
max_parallel_jobs=32

# Function to run the R Markdown script for a given simulation scenario
H_e_calculation() {
    local simulation_scenario=$1
    local simulation_model_allele_frequency_dir=$2
    local simulation_model_H_e_dir=$3

    export empirical_allele_frequency_dir="$Empirical_breed_allele_freq_dir"
    export output_empirical_H_e_dir="$Empirical_breed_H_e_dir"

    export simulated_model_allele_frequency_dir="$simulation_model_allele_frequency_dir"
    export sim_scenario_id="$simulation_scenario"
    export output_simulated_model_H_e_dir="$simulation_model_H_e_dir"    
    # Render the R Markdown document with the current simulation scenario
    Rscript -e "rmarkdown::render('$pipeline_scripts_dir/Hyperoptimization_H_e_calculation.Rmd')"
}

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Extract unique simulation prefixes
# simulation_scenarios_neutral_model=$(find $neutral_model_allele_freq_dir -maxdepth 1 -type f -name "*.bed" | sed -E 's/.*sim_[0-9]+_(.*)_allele_freq\.bed/\1/' | sort -u)
readarray -t simulation_scenarios_neutral_model < <(find "$neutral_model_allele_freq_dir" -maxdepth 1 -type f -name "*.bed" | sed -E 's/.*sim_[0-9]+_(.*)_allele_freq\.bed/\1/' | sort -u)

# Loop over each input simulation scenario
for simulation_scenario in "${simulation_scenarios_neutral_model[@]}"; do
    H_e_calculation $simulation_scenario $neutral_model_allele_freq_dir $neutral_model_H_e_dir &

    # Control the number of parallel jobs
    while [ $(jobs -r | wc -l) -ge $max_parallel_jobs ]; do
        wait -n
    done
done

# Wait for all background jobs to finish
wait
echo "All simulation scenarios processed."

echo "The results are stored in: $expected_heterozygosity_dir"



# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo "Sweep test done for all the datasets"
echo "Runtime: $script_runtime seconds"

