
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

#����������������������
# Allele frequency file
#����������������������
plink_output_dir=$HOME/results/PLINK
german_shepherd_allele_freq_dir=$plink_output_dir/empirical/german_shepherd/allele_freq

allele_freq_w_positions_file="$german_shepherd_allele_freq_dir/german_shepherd_allele_freq_with_marker_pos.bed"

#�������������������������
# ROH-hotspot window-files
#�������������������������
ROH_hotspots_results_dir=$HOME/results/ROH-Hotspots
german_shepherd_roh_hotspots_dir=$ROH_hotspots_results_dir/empirical/german_shepherd/gosling_plots


#################################### 
# Defining the output dirs
#################################### 

hotspots_allele_freq_output_dir=$german_shepherd_roh_hotspots_dir/hotspots_allele_freq
# Creating a directory to store the .BED-files in, if it does not already exist.
mkdir -p $hotspots_allele_freq_output_dir

#����������������������������������������������������������������������������
# Function: bedtools intersect
#
###Input:
# 
###Output:
#����������������������������������������������������������������������������



# Running intersect command for every chromosome ROH-hotspot file.
for roh_hotspot_file in $german_shepherd_roh_hotspots_dir/*.bed; do
    echo "Processing file: $roh_hotspot_file"
    chromosome=$(basename "$roh_hotspot_file" .bed | cut -d'_' -f1) # Extracting chromosome from the file name
    
    # Counter for ROH hotspot windows
    counter=1
    
    # Loop through each ROH hotspot window for the current chromosome
    while IFS=$'\t' read -r chrom start end; do
        output_file="$hotspots_allele_freq_output_dir/${chromosome}_ROH_hotspot_window_${counter}_allele_freq.bed"
        
        # Run bedtools intersect-function        
        bedtools intersect \
        -wa -header \
        -a "$allele_freq_w_positions_file" \
        -b <(echo -e "$chrom\t$start\t$end") \
        > "$output_file"
        
        ((counter++))
    done < "$roh_hotspot_file"
done




# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Mapping of ROH-hotspots to markers completed"
echo "The outputfiles are stored in: $output_file"
echo "Runtime: $runtime seconds"