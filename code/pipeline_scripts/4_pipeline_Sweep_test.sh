
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
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Extract unique simulation prefixes
# simulation_scenarios_neutral_model=$(find $neutral_model_allele_freq_dir -maxdepth 1 -type f -name "*.bed" | sed -E 's/.*sim_[0-9]+_(.*)_allele_freq\.bed/\1/' | sort -u)
readarray -t simulation_scenarios_neutral_model < <(find "$neutral_model_allele_freq_dir" -maxdepth 1 -type f -name "*.bed" | sed -E 's/.*sim_[0-9]+_(.*)_allele_freq\.bed/\1/' | sort -u)

# Loop over each input bed file
for simulation_scenario in "${simulation_scenarios_neutral_model[@]}"; do
    echo "$simulation_scenario"
    
    # Construct the params list
    export ROH_hotspots_dir="$empirical_roh_hotspots_dir"
    export empirical_roh_hotspots_allele_frequency_dir="$Empirical_breed_roh_hotspots_allele_frequency_dir"
    export empirical_allele_frequency_dir="$Empirical_breed_allele_freq_dir"
    export simulated_model_allele_frequency_dir="$neutral_model_allele_freq_dir"
    export sim_scenario_id="$simulation_scenario"
    export sweep_test_type="Selection_testing"
    export output_dir_sweep_test="$selection_testing_results_dir"
    export output_empirical_H_e_dir="$Empirical_breed_H_e_dir"
    export output_simulated_model_H_e_dir="$neutral_model_H_e_dir"

    echo "empirical_roh_hotspots_allele_frequency_dir: $empirical_roh_hotspots_allele_frequency_dir"
    echo "empirical_allele_frequency_dir: $empirical_allele_frequency_dir "
    echo "simulated_model_allele_frequency_dir: $simulated_model_allele_frequency_dir "
    echo "sim_scenario_id: $sim_scenario_id "
    echo "sweep_test_type: $sweep_test_type "
    echo "output_dir_sweep_test: $selection_testing_results_dir "
    echo "output_empirical_H_e_dir: $Empirical_breed_H_e_dir "
    echo "output_simulated_model_H_e_dir: $neutral_model_H_e_dir "
    
    # Render the R Markdown document with the current input bed file
    Rscript -e "rmarkdown::render('$script_directory/4-4_3_selective_sweep_test_expected_heterozygosity.Rmd')"
done

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
    for simulation_scenario in "${simulation_scenarios_selection_model[@]}"; do
        echo "$simulation_scenario"
    
        # Construct the params list
        export ROH_hotspots_dir="$empirical_roh_hotspots_dir"
        export empirical_roh_hotspots_allele_frequency_dir="$Empirical_breed_roh_hotspots_allele_frequency_dir"
        export empirical_allele_frequency_dir="$Empirical_breed_allele_freq_dir"
        export simulated_model_allele_frequency_dir="$selection_model_allele_freq_dir"
        export sim_scenario_id="$simulation_scenario"
        export sweep_test_type="Selection_Strength_testing"
        export output_dir_sweep_test="$selection_strength_testing_results_dir"
        export output_empirical_H_e_dir="$Empirical_breed_H_e_dir"
        export output_simulated_model_H_e_dir="$selection_model_H_e_dir"


        echo "empirical_roh_hotspots_allele_frequency_dir: $empirical_roh_hotspots_allele_frequency_dir"
        echo "empirical_allele_frequency_dir: $empirical_allele_frequency_dir "
        echo "simulated_model_allele_frequency_dir: $simulated_model_allele_frequency_dir "
        echo "sim_scenario_id: $sim_scenario_id "
        echo "sweep_test_type: $sweep_test_type "
        echo "output_dir_sweep_test: $selection_strength_testing_results_dir "

        # Render the R Markdown document with the current input bed file
        Rscript -e "rmarkdown::render('$script_directory/4-4_3_selective_sweep_test_expected_heterozygosity.Rmd')"
    done

    echo "Sweep test done for selection strength testing."
    echo "The results are stored in: $selection_strength_testing_results_dir"
    #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    #¤¤¤¤ Causative Variant Windows ¤¤¤¤ 
    #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    export output_causative_variant_H_e_dir="$causative_variant_H_e_dir"
    export selection_model_causative_variant_windows_dir="$selection_model_causative_variant_windows_dir"
    export causative_windows_allele_freq_dir="$causative_windows_allele_freq_dir"

    # Modify the pipeline_result_summary.sh script call to include the MAF status suffix in the output file name
    output_file="$script_directory/4-4_4_causative_windows_expected_heterozygosity_${MAF_status_suffix}.html"
    # Render the R Markdown document with the current input bed file
    Rscript -e "rmarkdown::render('$script_directory/4-4_4_causative_windows_expected_heterozygosity.Rmd', output_file = '$output_file')"
else
    echo "Selection simulation is set to FALSE. Skipping the selection model processing."
fi



# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo "Sweep test done for all the datasets"
echo "Runtime: $script_runtime seconds"

