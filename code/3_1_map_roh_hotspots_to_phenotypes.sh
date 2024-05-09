
#!/bin/bash -l

# Start the timer 
start=$(date +%s)


# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate bedtools
# /home/martin/anaconda3/envs/bedtools/bin/bedtools --version: bedtools v2.30.0  

# bedtools intersect -h  # Documentation about the merge function


####################################  
# Defining the working directory
#################################### 

HOME=/home/jonathan
cd $HOME

####################################  
# Defining the input files
#################################### 

# Defining the path to the annotation file
preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_phenotype_file_dir=$preprocessed_data_dir/empirical/omia_dog_phenotype_data
#$preprocessed_phenotype_file_dir/all_dog_phenotypes.bed
#$preprocessed_phenotype_file_dir/all_non_defect_phenotypes_dog_phenotypes.bed


ROH_hotspots_results_dir=$HOME/results/ROH-Hotspots
german_shepherd_roh_hotspots_dir=$ROH_hotspots_results_dir/empirical/german_shepherd

echo "ROH hotspot directory: $german_shepherd_roh_hotspots_dir"

#$german_shepherd_roh_hotspots_dir/chr17_ROH_Hotspot_windows.bed

#################################### 
# Defining the output dirs
#################################### 

phenotype_mapping_output_dir=$german_shepherd_roh_hotspots_dir/hotspot_phenotype_mapping
# Creating a directory to store the .BED-files in, if it does not already exist.
mkdir -p $phenotype_mapping_output_dir

#����������������������������������������������������������������������������
# Function: bedtools intersect
#
###Input:
# 
###Output:
#����������������������������������������������������������������������������

#phenotype_file=$preprocessed_phenotype_file_dir/ALL_dog_phenotypes.bed
#phenotype_file=$preprocessed_phenotype_file_dir/ALL_phenotypes_german_shepherd.bed
phenotype_file=$preprocessed_phenotype_file_dir/all_non_defect_phenotypes_any_breed.bed
#phenotype_file=$preprocessed_phenotype_file_dir/all_non_defect_phenotypes_german_shepherd.bed

# Running intersect command for every chromosome ROH-hotspot file.
for roh_hotspot_file in $german_shepherd_roh_hotspots_dir/*.bed; do
    echo "Processing file: $roh_hotspot_file"
    prefix=$(basename "$roh_hotspot_file" .bed) # Extracting basename without the .bed extension
    output_file="$phenotype_mapping_output_dir/${prefix}_phenotypes.bed"   

    # Run bedtools intersect-function        
    bedtools intersect \
    -wa -header \
    -a "$phenotype_file" \
    -b "$roh_hotspot_file" \
    > "$output_file"    

done


# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo " Mapping of ROH-hotspots to phenotypes completed"
echo "The outputfiles are stored in: $output_file"
echo "Runtime: $runtime seconds"