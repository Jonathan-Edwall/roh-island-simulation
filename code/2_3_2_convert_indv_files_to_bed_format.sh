
#!/bin/bash -l

# Start the timer 
start=$(date +%s)

# Change working directory
HOME=/home/jonathan

cd $HOME


# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate bedtools
# /home/martin/anaconda3/envs/bedtools/bin/bedtools --version: bedtools v2.30.0  

# bedtools merge -h  # Documentation about the merge function

echo "conda activated?"

plink_results_dir=$HOME/results/PLINK
ROH_files_dir=$plink_results_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
# Creating bed-files from the .hom-files
#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

### 
population_hom_file=$ROH_files_dir/german_shepherd_ROH.hom
population_bed_file=$ROH_files_dir/population_german_shepherd_ROH.bed

#awk 'BEGIN {OFS="\t"} {print $4,$7,$8}' "$population_hom_file" > "$population_bed_file" # Convert .hom to .bed format





individual_ROH_files_dir=$ROH_files_dir/individual_roh

# Creating a directory to store the .BED-files in, if it does not already exist.
mkdir -p $individual_ROH_files_dir/bed_format



# Convert each individual .hom file into .bed-format
for hom_file in $individual_ROH_files_dir/*.hom; do    
    individual_id=$(basename "$hom_file" .hom) # Extracting individual ID from the file name (In other words: extracting everything that is not "hom_file" or the .hom-file extension, from the file name)
    #awk 'BEGIN {OFS="\t"} {print $4,$7,$8,$9,$10,$5,$6}' "$hom_file" > "$individual_ROH_files_dir/bed_format/${individual_id}.bed" # Convert .hom to .bed format
    awk 'BEGIN {OFS="\t"} {print $4,$7,$8}' "$hom_file" > "$individual_ROH_files_dir/bed_format/${individual_id}.bed" # Convert .hom to .bed format
done



# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Merging of overlapping ROH-segments in the population-wide roh-segment file completed"
echo "The outputfiles are stored in: $population_bed_file & $merged_overlapping_rohs_dir/merged_roh_regions.bed"
echo "Runtime: $runtime seconds"