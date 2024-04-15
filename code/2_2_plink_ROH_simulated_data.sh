#!/bin/bash -l

# Change working directory
HOME=/home/jonathan

cd $HOME


# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate plink

echo "conda activated?"


# Defining input directory
raw_data_dir=$HOME/data/raw
raw_simulated_dir=$raw_data_dir/simulated


# Defining output directory
plink_output_dir=$HOME/results/PLINK
simulated_plink_output_dir=$plink_output_dir/simulated/ROH

mkdir -p $simulated_plink_output_dir

# Find any .map file in simulated_data_dir and use its basename as the simulation name
for simulation_file in $raw_simulated_dir/*.map; do
    # Extract simulation name from the filename (minus the .map extension)
    simulation_name=$(basename "${simulation_file%.*}")    
    echo "$simulation_name"     
          
    # Running --homozyg command for ROH computation
    plink \
     --file "${raw_simulated_dir}/${simulation_name}" \
     --out "${simulated_plink_output_dir}/${simulation_name}_ROH" \
     --dog \
     --homozyg \
     --homozyg-window-snp 50 \
     --homozyg-window-threshold 0.05 \
     --homozyg-window-het 1 \
     --homozyg-window-missing 5 \
     --homozyg-snp 100 \
     --homozyg-kb 1000
              
    
done








 
###### Window parameters (defining putative ROH-markers)######
# --homozyg-window-snp 50: Defines how many markers are included in a window
# --homozyg-window-threshold 0.05: Defines the minimum threshold of overlapping windows that are homozygote, for a marker to become a "Putative ROH-marker" (5%)
# --homozyg-window-het 1: Defines how many heterozygote positions are allowed within a SNP-window (default: 1 positon per window)
# --homozyg-window-missing 5: Defines how many missing positons ("gaps") are allowed within a SNP-window (default: 5 positon per window)


###### ROH-defintion ######
# --homozyg-snp 100: Lower limit of how many markers a segment needs to contain, to be classified as a ROH-segment (default: 100 markers)
# --homozyg-kb 1000: Lower limit of how long (in basepairs) a segment needs to be, to be classified as a ROH-segment (default: 1000 bp)

echo "ROH-computation completed"
echo "Outputfiles stored in: $simulated_plink_output_dir"