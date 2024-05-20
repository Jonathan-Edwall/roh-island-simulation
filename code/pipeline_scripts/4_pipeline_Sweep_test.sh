
#!/bin/bash -l

# Start the timer 
start=$(date +%s)


####################################  
# Defining the working directory
#################################### 

HOME=/home/jonathan
#cd $HOME

script_dir=$HOME/code/pipeline_scripts

######################################  
####### Defining parameter values #######
######################################



######################################  
####### Defining the INPUT files #######
######################################  
PLINK_allele_freq_dir=$HOME/results/PLINK/allele_freq

#�������������
#� Empirical �
#�������������
##### Genomewide Allele frequencies #####
german_shepherd_allele_freq_dir=$PLINK_allele_freq_dir/empirical/german_shepherd
##### ROH-hotspot Allele frequencies #####
roh_hotspots_results_dir=$HOME/results/ROH-Hotspots
german_shepherd_roh_hotspots_allele_frequency_dir=$roh_hotspots_results_dir/empirical/german_shepherd/hotspots_allele_freq

#�������������
#� Simulated � 
#�������������
simulated_PLINK_allele_freq_dir=$PLINK_allele_freq_dir/simulated


##### Neutral Model #####
neutral_model_allele_freq_dir=$simulated_PLINK_allele_freq_dir/neutral_model
##### Selection Model ##### 
selection_model_allele_freq_dir=$simulated_PLINK_allele_freq_dir/selection_model


######################################  
####### Defining the OUTPUT files #######
######################################  
expected_heterozygosity_results_dir=$HOME/results/expected_heterozygosity

#�������������
#� Empirical �
#�������������
german_shepherd_H_e_dir=$expected_heterozygosity_results_dir/empirical/german_shepherd
mkdir -p $german_shepherd_H_e_dir

##### Neutral Model #####
selection_testing_results_dir=$roh_hotspots_results_dir/sweep_test
mkdir -p $selection_testing_results_dir 

neutral_model_H_e_dir=$expected_heterozygosity_results_dir/simulated/neutral_model
mkdir -p $neutral_model_H_e_dir


##### Selection Model ##### 
selection_strength_testing_results_dir=$roh_hotspots_results_dir/selection_strength_test
mkdir -p $selection_strength_testing_results_dir
selection_model_H_e_dir=$expected_heterozygosity_results_dir/simulated/selection_model
mkdir -p $selection_model_H_e_dir

##############################################################################################  
############ RESULTS ###########################################################################
############################################################################################## 


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Extract unique simulation prefixes
simulation_scenarios=$(find $neutral_model_allele_freq_dir -maxdepth 1 -type f -name "*.bed" | sed -E 's/.*sim_[0-9]+_(.*)_allele_freq\.bed/\1/' | sort -u)

# Loop over each input bed file
for simulation_scenario in "${simulation_scenarios[@]}"; do
    echo "$simulation_scenario"
    
    # Construct the params list
    export empirical_roh_hotspots_allele_frequency_dir="$german_shepherd_roh_hotspots_allele_frequency_dir"
    export empirical_allele_frequency_dir="$german_shepherd_allele_freq_dir"
    export simulated_model_allele_frequency_dir="$neutral_model_allele_freq_dir"
    export sim_scenario_id="$simulation_scenario"
    export sweep_test_type="Selection_testing"
    export output_dir_sweep_test="$selection_testing_results_dir"
    export output_empirical_H_e_dir="$german_shepherd_H_e_dir"
    export output_simulated_model_H_e_dir="$neutral_model_H_e_dir"

    echo "empirical_roh_hotspots_allele_frequency_dir: $empirical_roh_hotspots_allele_frequency_dir"
    echo "empirical_allele_frequency_dir: $empirical_allele_frequency_dir "
    echo "simulated_model_allele_frequency_dir: $simulated_model_allele_frequency_dir "
    echo "sim_scenario_id: $sim_scenario_id "
    echo "sweep_test_type: $sweep_test_type "
    echo "output_dir_sweep_test: $selection_testing_results_dir "
    echo "output_empirical_H_e_dir: $german_shepherd_H_e_dir "
    echo "output_simulated_model_H_e_dir: $neutral_model_H_e_dir "
    
    # Render the R Markdown document with the current input bed file
    Rscript -e "rmarkdown::render('$script_dir/4-4_3_selective_sweep_test_expected_heterozygosity.Rmd')"
done

echo "Sweep test done for selection testing."
echo "The results are stored in: $selection_testing_results_dir"

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Extract unique simulation prefixes into an array
readarray -t simulation_scenarios < <(find "$selection_model_allele_freq_dir" -maxdepth 1 -type f -name "*.bed" | sed -E 's/.*sim_[0-9]+_(.*)_allele_freq\.bed/\1/' | sort -u)
# echo "$simulation_scenarios"
# Loop over each input bed file
for simulation_scenario in "${simulation_scenarios[@]}"; do
    echo "$simulation_scenario"
   
    # Construct the params list
    export empirical_roh_hotspots_allele_frequency_dir="$german_shepherd_roh_hotspots_allele_frequency_dir"
    export empirical_allele_frequency_dir="$german_shepherd_allele_freq_dir"
    export simulated_model_allele_frequency_dir="$selection_model_allele_freq_dir"
    export sim_scenario_id="$simulation_scenario"
    export sweep_test_type="Selection_Strength_testing"
    export output_dir_sweep_test="$selection_strength_testing_results_dir"
    export output_empirical_H_e_dir="$german_shepherd_H_e_dir"
    export output_simulated_model_H_e_dir="$selection_model_H_e_dir"


    echo "empirical_roh_hotspots_allele_frequency_dir: $empirical_roh_hotspots_allele_frequency_dir"
    echo "empirical_allele_frequency_dir: $empirical_allele_frequency_dir "
    echo "simulated_model_allele_frequency_dir: $simulated_model_allele_frequency_dir "
    echo "sim_scenario_id: $sim_scenario_id "
    echo "sweep_test_type: $sweep_test_type "
    echo "output_dir_sweep_test: $selection_strength_testing_results_dir "




    
    # Render the R Markdown document with the current input bed file
    Rscript -e "rmarkdown::render('$script_dir/4-4_3_selective_sweep_test_expected_heterozygosity.Rmd')"
done

echo "Sweep test done for selection strength testing."
echo "The results are stored in: $selection_strength_testing_results_dir"


# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Sweep test done for all the datasets"
echo "Runtime: $runtime seconds"

