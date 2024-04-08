
#!/bin/bash -l

# Start the timer 
start=$(date +%s)


# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate bedtools
# /home/martin/anaconda3/envs/bedtools/bin/bedtools --version: bedtools v2.30.0  

# bedtools intersect -h  # Documentation about the merge function

echo "conda activated?"

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
german_shepherd_roh_hotspots_dir=$ROH_hotspots_results_dir/empirical/german_shepherd/gosling_plots

echo "ROH hotspot directory: $german_shepherd_roh_hotspots_dir"

#$german_shepherd_roh_hotspots_dir/chr17_ROH_Hotspot_windows.bed

#################################### 
# Defining the output dirs
#################################### 

phenotype_mapping_output_dir=$german_shepherd_roh_hotspots_dir/hotspot_phenotype_mapping
# Creating a directory to store the .BED-files in, if it does not already exist.
mkdir -p $phenotype_mapping_output_dir

#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
# Function: bedtools intersect
#
###Input:
# 
###Output:
#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい



# Running intersect command for every chromosome ROH-hotspot file.
for roh_hotspot_file in $german_shepherd_roh_hotspots_dir/*.bed; do
    echo "Processing file: $roh_hotspot_file"
    chromosome=$(basename "$roh_hotspot_file" .bed | cut -d'_' -f1) # Extracting chromosome from the file name
    output_file="$phenotype_mapping_output_dir/${chromosome}_ROH_hotspot_phenotypes.bed"   
    #awk 'BEGIN{FS="\t"; OFS="\t"} NF >= 3 {print $1,$2,$3}' "$preprocessed_phenotype_file_dir/all_dog_phenotypes.bed" > temp.bed 
    awk 'BEGIN{FS="\t"; OFS="\t"} NF >= 3 {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' "$preprocessed_phenotype_file_dir/ALL_phenotypes.bed" > temp.bed     
      
    # Run bedtools intersect-function        
    bedtools intersect \
    -wa -header \
    -a "temp.bed" \
    -b "$roh_hotspot_file" \
    > "$output_file"    
#echo "Phenotype file: debug_all_dog_phenotypes.bed"
    
    
    
# # Extracting only the first three columns from debug_all_dog_phenotypes.bed
#    awk 'BEGIN{FS="\t"; OFS="\t"} NF >= 3 {print $1,$2,$3}' "$preprocessed_phenotype_file_dir/debug_all_dog_phenotypes.bed" > temp.bed
#
#    # Filter out empty lines and lines with fewer than 3 columns
#    sed -i '/^$/d' temp.bed
#    sed -i '/^#/d' temp.bed
#
#    # Create a temporary copy of temp.bed for chromosome renaming
#    cp temp.bed temp_renamed.bed
#
#    # Rename chromosome entries in temp_renamed.bed
#    sed -i 's/^/chr/' temp_renamed.bed
#
#    echo "Content of temp_renamed.bed:"
#    cat -A temp_renamed.bed
#    
#    echo "Content of /home/jonathan/results/ROH-Hotspots/empirical/german_shepherd/gosling_plots/chr17_ROH_Hotspot_windows.bed:"
#    cat -A $roh_hotspot_file
#
#    # Check the content of roh_hotspot_file
#    echo "Content of $roh_hotspot_file:"
#    cat "$roh_hotspot_file"
#    
#    
#     bedtools intersect -a "temp_renamed.bed" -b "$roh_hotspot_file" -wa > "$output_file"
#
##    # Run bedtools intersect-function
##    bedtools intersect \
##    -wa \
##    -a "temp_renamed.bed" \
##    -b "$roh_hotspot_file" \
##    > "$output_file"
#
#    # Remove temporary files
#    rm temp.bed temp_renamed.bed
done


# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo " Mapping of ROH-hotspots to phenotypes completed"
echo "The outputfiles are stored in: $output_file"
echo "Runtime: $runtime seconds"