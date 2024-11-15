#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME

######################################  
####### Defining parameter values #######
######################################
# Max number of parallel jobs to run at a time 
# max_parallel_jobs=$(printf "%.0f" $(( $(nproc) / 2 )))
max_parallel_jobs=1

# export use_MAF_pruning=TRUE
# export use_MAF_pruning=FALSE
# export <=0.01

# export empirical_dog_breed="german_shepherd"
# empirical_dog_breed="empirical_breed" # Defined in run_pipeline.sh

######################################  
####### Defining the INPUT files #######
######################################  
# results_dir=$HOME/results # Variable Defined in run_pipeline.sh
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
##### Selection Model #####
selection_model_allele_freq_dir=$simulated_allele_freq_plink_output_dir/selection_model
##### Causative Variant Window (Selection Model) ##### 
selection_model_causative_variant_windows_dir=$results_dir/causative_variant_windows
causative_windows_allele_freq_dir=$selection_model_causative_variant_windows_dir/allele_freq

######################################  
####### Defining the OUTPUT files #######
######################################  
# expected_heterozygosity_dir=$results_dir/expected_heterozygosity

export expected_heterozygosity_dir="$results_dir/expected_heterozygosity_$MAF_status_suffix"

mkdir -p $expected_heterozygosity_dir

#�������������
#� Empirical �
#�������������
Empirical_breed_H_e_dir=$expected_heterozygosity_dir/empirical/$empirical_dog_breed
mkdir -p $Empirical_breed_H_e_dir

##### Neutral Model #####
# selection_testing_results_dir=$roh_hotspots_results_dir/sweep_test
export selection_testing_results_dir="$roh_hotspots_results_dir/sweep_test_$MAF_status_suffix"
mkdir -p $selection_testing_results_dir 

neutral_model_H_e_dir=$expected_heterozygosity_dir/simulated/neutral_model
mkdir -p $neutral_model_H_e_dir


##### Selection Model ##### 
# selection_strength_testing_results_dir=$roh_hotspots_results_dir/selection_strength_test
export selection_strength_testing_results_dir="$roh_hotspots_results_dir/selection_strength_test_$MAF_status_suffix"

mkdir -p $selection_strength_testing_results_dir
selection_model_H_e_dir=$expected_heterozygosity_dir/simulated/selection_model
mkdir -p $selection_model_H_e_dir

#�������������
#� Simulated � 
#�������������
##### Selection Model ##### 
# causative_variant_H_e_dir=$selection_model_causative_variant_windows_dir/H_e
export causative_variant_H_e_dir="$selection_model_causative_variant_windows_dir/H_e_$MAF_status_suffix"
mkdir -p $causative_variant_H_e_dir

##############################################################################################  
############ RESULTS ###########################################################################
##############################################################################################
# Function to run the R Markdown script for a given simulation scenario
H_e_calculation() {
    local simulation_scenario=$1
    local simulation_model_allele_frequency_dir=$2
    local simulation_model_H_e_dir=$3
    local sweep_test_type=$4
    local output_dir_sweep_test=$5
    local knit_document_check=$6 # Variable that controls the knitting of the .rmd file   



    export ROH_hotspots_dir="$empirical_roh_hotspots_dir"
    export empirical_roh_hotspots_allele_frequency_dir="$Empirical_breed_roh_hotspots_allele_frequency_dir"
    export empirical_allele_frequency_dir="$Empirical_breed_allele_freq_dir"
    export output_empirical_H_e_dir="$Empirical_breed_H_e_dir"

    export sim_scenario_id="$simulation_scenario"
    export simulated_model_allele_frequency_dir="$simulation_model_allele_frequency_dir"
    export output_simulated_model_H_e_dir="$simulation_model_H_e_dir"
    export sweep_test_type="$sweep_test_type"
    export output_dir_sweep_test="$output_dir_sweep_test"


    # echo "Processing simulation scenario: $simulation_scenario"
    # echo "empirical_allele_frequency_dir: $empirical_allele_frequency_dir "
    # echo "simulated_model_allele_frequency_dir: $simulated_model_allele_frequency_dir "
    # echo "sim_scenario_id: $sim_scenario_id "
    # echo "output_empirical_H_e_dir: $output_empirical_H_e_dir "
    # echo "output_simulated_model_H_e_dir: $output_simulated_model_H_e_dir "
    
    # Render the R Markdown document with the current simulation scenario
    if [ "$knit_document_check" -eq 1 ]; then
        Rscript -e "rmarkdown::render('$pipeline_scripts_dir/4-4_3_selective_sweep_test_expected_heterozygosity.Rmd')"
    else
        Rscript -e "rmarkdown::render('$pipeline_scripts_dir/4-4_3_selective_sweep_test_expected_heterozygosity.Rmd', run_pandoc=FALSE)" # Run the .rmd script without knitting!
    fi         


}

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Extract unique simulation prefixes
# simulation_scenarios_neutral_model=$(find $neutral_model_allele_freq_dir -maxdepth 1 -type f -name "*.bed" | sed -E 's/.*sim_[0-9]+_(.*)_allele_freq\.bed/\1/' | sort -u)
readarray -t simulation_scenarios_neutral_model < <(find "$neutral_model_allele_freq_dir" -maxdepth 1 -type f -name "*.bed" | sed -E 's/.*sim_[0-9]+_(.*)_allele_freq\.bed/\1/' | sort -u)
counter=0
# Loop over each input simulation scenario
for simulation_scenario in "${simulation_scenarios_neutral_model[@]}"; do
    ((counter++)) 
    if [ "$counter" -eq 1 ]; then
        knit_document_check=1  # Only knit for the first simulation
    else
        knit_document_check=0  # Just run the script for all other cases
    fi 

    sweep_test_type="Selection_testing"

    H_e_calculation $simulation_scenario $neutral_model_allele_freq_dir $neutral_model_H_e_dir $sweep_test_type $selection_testing_results_dir $knit_document_check &

    # Control the number of parallel jobs
    while [ $(jobs -r | wc -l) -ge $max_parallel_jobs ]; do
        wait -n
    done
done

# Wait for all background jobs to finish
wait
# echo "All neutral model simulations processed."

echo "Sweep test done for selection testing."
echo "The results are stored in: $selection_testing_results_dir"

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
if [ "$selection_simulation" = TRUE ]; then
    # Extract unique simulation prefixes into an array
    readarray -t simulation_scenarios_selection_model < <(find "$selection_model_allele_freq_dir" -maxdepth 1 -type f -name "*.bed" | sed -E 's/.*sim_[0-9]+_(.*)_allele_freq\.bed/\1/' | sort -u)
    # echo "$simulation_scenarios"
    # Loop over each input bed file
    counter=0

    # Loop over each input simulation scenario
    for simulation_scenario in "${simulation_scenarios_selection_model[@]}"; do
        ((counter++)) 
        if [ "$counter" -eq 1 ]; then
            knit_document_check=1  # Only knit for the first simulation
        else
            knit_document_check=0  # Just run the script for all other cases
        fi 

        sweep_test_type="Selection_Strength_testing"

        H_e_calculation $simulation_scenario $selection_model_allele_freq_dir $selection_model_H_e_dir $sweep_test_type $selection_strength_testing_results_dir $knit_document_check &

        # Control the number of parallel jobs
        while [ $(jobs -r | wc -l) -ge $max_parallel_jobs ]; do
            wait -n
        done
    done

    # Wait for all background jobs to finish
    wait
    echo "Sweep test done for selection strength testing."
    echo "The results are stored in: $selection_strength_testing_results_dir"
    #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    #¤¤¤¤ Causative Variant Windows ¤¤¤¤ 
    #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    export output_causative_variant_H_e_dir="$causative_variant_H_e_dir"
    export selection_model_causative_variant_windows_dir="$selection_model_causative_variant_windows_dir"
    export causative_windows_allele_freq_dir="$causative_windows_allele_freq_dir"

    # Modify the pipeline_result_summary.sh script call to include the MAF status suffix in the output file name
    output_file="$pipeline_scripts_dir/4-4_4_causative_windows_expected_heterozygosity_${MAF_status_suffix}.html"
    # Render the R Markdown document with the current input bed file
    Rscript -e "rmarkdown::render('$pipeline_scripts_dir/4-4_4_causative_windows_expected_heterozygosity.Rmd', output_file = '$output_file')"
else
    echo "Selection simulation is set to FALSE. Skipping the selection model processing."
fi

# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo "Sweep test done for all the datasets"
echo "Runtime: $script_runtime seconds"

