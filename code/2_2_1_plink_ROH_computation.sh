#!/bin/bash -l

# Start the script execution timer 
start=$(date +%s)

# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate plink

####################################  
# Defining the working directory
#################################### 
HOME=/home/jonathan
cd $HOME

####################################  
# Defining the input files
#################################### 
# Defining input directory
raw_data_dir=$HOME/data/raw
raw_simulated_dir=$raw_data_dir/simulated
#�������������
#� Empirical �
#�������������
preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

#�������������
#� Simulated � 
#�������������
raw_simulated_neutral_model_dir=$raw_simulated_dir/neutral_model
raw_simulated_selection_model_dir=$raw_simulated_dir/selection_model

#################################### 
# Defining the output files
#################################### 
# Defining output directory
plink_output_dir=$HOME/results/PLINK/ROH
simulated_plink_dir=$plink_output_dir/simulated

#�������������
#� Empirical �
#�������������
german_shepherd_plink_output_dir=$plink_output_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
mkdir -p $german_shepherd_plink_output_dir

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
###Input: .map and .ped files
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
##���� Empirical Data (German Shepherd) ���� 
##������������������������������
# Running --homozyg command for ROH computation
plink \
 --bfile $preprocessed_german_shepherd_dir/german_shepherd_filtered \
 --out $german_shepherd_plink_output_dir/german_shepherd_ROH \
 --dog \
 --homozyg \
 --homozyg-window-snp 50 \
 --homozyg-window-threshold 0.05 \
 --homozyg-window-het 1 \
 --homozyg-window-missing 5 \
 --homozyg-snp 100 \
 --homozyg-kb 1000

echo "ROH-computation completed for the empirical data"
echo "Outputfiles stored in: $german_shepherd_plink_output_dir"

##�������������������������
##���� Neutral Model (Simulated) ���� 
##�������������������������
# Find any .map file in raw_simulated_neutral_model_dir and use its basename as the simulation name
for simulation_file in $raw_simulated_neutral_model_dir/*.map; do
    # Extract simulation name from the filename (minus the .map extension)
    simulation_name=$(basename "${simulation_file%.*}")    
    echo "$simulation_name"     
          
    # Running --homozyg command for ROH computation
    plink \
     --file "${raw_simulated_neutral_model_dir}/${simulation_name}" \
     --out "${simulated_neutral_model_plink_output_dir}/${simulation_name}_ROH" \
     --dog \
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

##��������������������������
##���� Selection Model (Simulated) ���� 
##��������������������������

# Find any .map file in raw_simulated_selection_model_dir and use its basename as the simulation name
for simulation_file in $raw_simulated_selection_model_dir/*.map; do
    # Extract simulation name from the filename (minus the .map extension)
    simulation_name=$(basename "${simulation_file%.*}")    
    echo "$simulation_name"     
          
    # Running --homozyg command for ROH computation
    plink \
     --file "${raw_simulated_selection_model_dir}/${simulation_name}" \
     --out "${simulated_selection_model_plink_output_dir}/${simulation_name}_ROH" \
     --dog \
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



# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "ROH computed successfully."

echo "Total Runtime: $runtime seconds"

 

