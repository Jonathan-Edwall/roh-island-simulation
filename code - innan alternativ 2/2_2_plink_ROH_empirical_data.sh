#!/bin/bash -l

# Change working directory
HOME=/home/jonathan

cd $HOME


# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate plink

echo "conda activated?"


# Defining input directory
preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813


# Defining output directory
plink_output_dir=$HOME/results/PLINK
german_shepherd_plink_output_dir=$plink_output_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813


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
 
###### Window parameters (defining putative ROH-markers)######
# --homozyg-window-snp 50: Defines how many markers are included in a window
# --homozyg-window-threshold 0.05: Defines the minimum threshold of overlapping windows that are homozygote, for a marker to become a "Putative ROH-marker" (5%)
# --homozyg-window-het 1: Defines how many heterozygote positions are allowed within a SNP-window (default: 1 positon per window)
# --homozyg-window-missing 5: Defines how many missing positons ("gaps") are allowed within a SNP-window (default: 5 positon per window)


###### ROH-defintion ######
# --homozyg-snp 100: Lower limit of how many markers a segment needs to contain, to be classified as a ROH-segment (default: 100 markers)
# --homozyg-kb 1000: Lower limit of how long (in basepairs) a segment needs to be, to be classified as a ROH-segment (default: 1000 bp)

echo "ROH-computation completed"
echo "Outputfiles stored in: $german_shepherd_plink_output_dir"