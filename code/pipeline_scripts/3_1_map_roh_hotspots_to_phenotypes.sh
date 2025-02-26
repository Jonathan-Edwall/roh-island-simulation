
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

# empirical_breed="empirical_breed" # Defined in run_pipeline.sh

####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME

####################################  
# Defining the input files
#################################### 

# Defining the path to the phenotype file
# omia_phenotypes_filepath # Variable Defined in run_pipeline.sh
omia_phenotypes_dir=$(dirname "$omia_phenotypes_filepath")

# results_dir=$HOME/results # Variable Defined in run_pipeline.sh
ROH_hotspots_results_dir=$results_dir/ROH-Hotspots
empirical_breed_roh_hotspots_dir=$ROH_hotspots_results_dir/empirical/$empirical_breed

echo "ROH hotspot directory: $empirical_breed_roh_hotspots_dir"

#$empirical_breed_roh_hotspots_dir/chr17_ROH_Hotspot_windows.bed

#################################### 
# Defining the output dirs
#################################### 

phenotype_mapping_output_dir=$empirical_breed_roh_hotspots_dir/hotspot_phenotype_mapping
# Creating a directory to store the .BED-files in, if it does not already exist.
mkdir -p $phenotype_mapping_output_dir

#����������������������������������������������������������������������������
# Function: bedtools intersect
#
###Input:
# 
###Output:
#����������������������������������������������������������������������������

# Running intersect command for every chromosome ROH-hotspot file.
for roh_hotspot_file in $empirical_breed_roh_hotspots_dir/*.bed; do
    echo "Processing file: $roh_hotspot_file"
    prefix=$(basename "$roh_hotspot_file" .bed) # Extracting basename without the .bed extension
    output_file="${phenotype_mapping_output_dir}/${prefix}_phenotypes.bed"   
    # Run bedtools intersect-function        
    bedtools intersect \
    -wa -header \
    -a "$omia_phenotypes_filepath" \
    -b "$roh_hotspot_file" \
    > "$output_file"    
done
# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo " Mapping of ROH-hotspots to phenotypes completed"
echo "The outputfiles are stored in: $output_file"
echo "Runtime: $script_runtime seconds"