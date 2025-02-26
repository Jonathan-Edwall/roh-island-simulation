#!/bin/bash -l

# Start the script execution timer 
script_start=$(date +%s)

# # Defining the path to the Conda initialization script
# conda_setup_script_path="/home/jonteehh/pipeline/anaconda3/etc/profile.d/conda.sh"
# # conda_setup_script_path=""
# source $conda_setup_script_path  # Source Conda initialization script
# # Activate the conda environment
# conda activate roh_island_sim_env

######################################  
####### Defining parameter values #######
######################################

# # Boolean value to determine whether to run the selection simulation code
# selection_simulation=TRUE # Defined in run_pipeline.sh

# Extract the start and end of the chromosome range (e.g., "1-19")
start_chromosome=$(echo $empirical_autosomal_chromosomes | cut -d'-' -f1)
end_chromosome=$(echo $empirical_autosomal_chromosomes | cut -d'-' -f2)

# Calculate the number of chromosomes in the range
num_chromosomes=$((end_chromosome - start_chromosome + 1))

# empirical_species="dog" # Variable Defined in run_pipeline.sh
# Define species-specific options
if [[ "$empirical_species" == "dog" ]]; then
    species_flag="--dog"
else
    species_flag="--chr-set $num_chromosomes"
fi




####################################  
# Defining the working directory
#################################### 
# HOME=/home/jonathan
cd $HOME

####################################  
# Defining the input files
#################################### 
# Defining input directory

# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
preprocessed_data_dir=$data_dir/preprocessed
# results_dir=$HOME/results # Variable Defined in run_pipeline.sh

#�������������
#� Empirical �
#�������������
# empirical_breed="german_shepherd" # Defined in run_pipeline.sh
preprocessed_empirical_breed_dir=$preprocessed_data_dir/empirical/$empirical_breed
# empirical_preprocessed_data_basename="${empirical_breed}_filtered" # Defined in 2_1_1_plink_preprocessing_empirical_data.sh
empirical_preprocessed_data_basename="${empirical_breed}_filtered" # Defined in 2_1_1_plink_preprocessing_empirical_data.sh

#�������������
#� Simulated � 
#�������������
preprocessed_simulated_data_dir=$preprocessed_data_dir/simulated
preprocessed_neutral_model_dir=$preprocessed_simulated_data_dir/neutral_model
preprocessed_selection_model_dir=$preprocessed_simulated_data_dir/selection_model

#################################### 
# Defining the output files
#################################### 
# Defining output directory
plink_output_dir=$results_dir/PLINK/ROH
simulated_plink_dir=$plink_output_dir/simulated

#�������������
#� Empirical �
#�������������
empirical_breed_plink_output_dir=$plink_output_dir/empirical/$empirical_breed
mkdir -p $empirical_breed_plink_output_dir

#�������������
#� Simulated � 
#�������������

simulated_neutral_model_plink_output_dir=$simulated_plink_dir/neutral_model
simulated_selection_model_plink_output_dir=$simulated_plink_dir/selection_model

mkdir -p $simulated_neutral_model_plink_output_dir
mkdir -p $simulated_selection_model_plink_output_dir


#######################################################  
# RESULTS
####################################################### 

############################################################################
# Function: plink --homozyg
###Input: .bim and .ped files
###Output: .frq-files

############ Window parameters (defining putative ROH-markers) 
# --homozyg-window-snp 50: Defines how many markers are included in a window
# --homozyg-window-threshold 0.05: Defines the minimum threshold of overlapping windows that are homozygote, for a marker to become a "Putative ROH-marker" (5%)
# --homozyg-window-het 1: Defines how many heterozygote positions are allowed within a SNP-window (default: 1 positon per window)
# --homozyg-window-missing 5: Defines how many missing positons ("gaps") are allowed within a SNP-window (default: 5 positon per window)

############ ROH-defintion 
# --homozyg-snp 100: Lower limit of how many markers a segment needs to contain, to be classified as a ROH-segment (default: 100 markers)
# --homozyg-kb 1000: Lower limit of how long (in basepairs) a segment needs to be, to be classified as a ROH-segment (default: 1000 bp)

#############################################################################

##������������������������������
##���� Empirical Data               ���� 
##������������������������������
if [ "$empirical_processing" = TRUE ]; then
    # Running --homozyg command for ROH computation
    plink \
    --bfile "$preprocessed_empirical_breed_dir/$empirical_preprocessed_data_basename" \
    --out "$empirical_breed_plink_output_dir/${empirical_breed}_ROH" \
    $species_flag \
    --homozyg \
    --homozyg-window-snp 50 \
    --homozyg-window-threshold 0.05 \
    --homozyg-window-het 1 \
    --homozyg-window-missing 5 \
    --homozyg-snp 100 \
    --homozyg-kb 1000

    echo "ROH-computation completed for the empirical data"
    echo "Outputfiles stored in: $empirical_breed_plink_output_dir"

else
    echo "Empirical data has been set to not be processed, since files have already been created."
fi



##�������������������������
##���� Neutral Model (Simulated) ���� 
##�������������������������
# Find any .bim file in preprocessed_neutral_model_dir and use its basename as the simulation name
for simulation_file in $preprocessed_neutral_model_dir/*.bim; do
    # Extract simulation name from the filename (minus the .bim extension)
    simulation_name=$(basename "${simulation_file%.*}")    
    echo "$simulation_name"     
          
    # Running --homozyg command for ROH computation
    plink \
     --bfile "${preprocessed_neutral_model_dir}/${simulation_name}" \
     --out "${simulated_neutral_model_plink_output_dir}/${simulation_name}_ROH" \
     $species_flag \
     --homozyg \
     --homozyg-window-snp 50 \
     --homozyg-window-threshold 0.05 \
     --homozyg-window-het 1 \
     --homozyg-window-missing 5 \
     --homozyg-snp 100 \
     --homozyg-kb 1000          
    
done

echo "ROH-computation completed for the neutral model"
echo "Outputfiles stored in: $simulated_neutral_model_plink_output_dir"

# ##��������������������������
# ##���� Selection Model (Simulated) ���� 
# ##��������������������������

if [ "$selection_simulation" = TRUE ]; then
    # Find any .bim file in preprocessed_selection_model_dir and use its basename as the simulation name
    for simulation_file in $preprocessed_selection_model_dir/*.bim; do
        # Extract simulation name from the filename (minus the .bim extension)
        simulation_name=$(basename "${simulation_file%.*}")    
        echo "$simulation_name"     
            
        # Running --homozyg command for ROH computation
        plink \
        --bfile "${preprocessed_selection_model_dir}/${simulation_name}" \
        --out "${simulated_selection_model_plink_output_dir}/${simulation_name}_ROH" \
        $species_flag \
        --homozyg \
        --homozyg-window-snp 50 \
        --homozyg-window-threshold 0.05 \
        --homozyg-window-het 1 \
        --homozyg-window-missing 5 \
        --homozyg-snp 100 \
        --homozyg-kb 1000
                    
    done

    echo "ROH-computation completed for the selection model"
    echo "Outputfiles stored in: $simulated_selection_model_plink_output_dir"
else
    echo "Selection simulation is set to FALSE. Skipping the selection model processing."
fi




# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo "ROH computed successfully."

echo "Total Runtime: $script_runtime seconds"

 

