
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

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Allele frequency file
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
plink_output_dir=$HOME/results/PLINK
german_shepherd_allele_freq_dir=$plink_output_dir/empirical/german_shepherd/allele_freq
#¤¤¤¤¤¤¤¤¤¤¤
# .bim file
#¤¤¤¤¤¤¤¤¤¤¤
preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# ROH-hotspot window-files
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
ROH_hotspots_results_dir=$HOME/results/ROH-Hotspots
german_shepherd_roh_hotspots_dir=$ROH_hotspots_results_dir/empirical/german_shepherd/gosling_plots


#ROH_hotspots_results_dir=$HOME/results/ROH-Hotspots
#german_shepherd_roh_hotspots_dir=$ROH_hotspots_results_dir/empirical/german_shepherd/gosling_plots
#
#echo "ROH hotspot directory: $german_shepherd_roh_hotspots_dir"
#
##$german_shepherd_roh_hotspots_dir/chr17_ROH_Hotspot_windows.bed

#################################### 
# Defining the output dirs
#################################### 

hotspots_allele_freq_output_dir=$german_shepherd_roh_hotspots_dir/hotspots_allele_freq
# Creating a directory to store the .BED-files in, if it does not already exist.
mkdir -p $hotspots_allele_freq_output_dir

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Function: join
#
#
###Input: .frq-file with allele frequencies at the different marker positions & .bim-file containing the physical positions of these markers
# 
###Output: A tsv-file with the contents of the .frq-file, combined with information about the physical positons of the markers from the .bim-file.
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
allele_freq_w_positions_file="$german_shepherd_allele_freq_dir/german_shepherd_marker_pos_with_allele_freq.bed"

#Joins the .frq-file (File 1) and .bim-file (File 2) based on their 2nd column (SNP identifier)
# The input files gets sorted temporarily based on the 2nd column (SNP identifier) using process substitution
# The output file contains:
#   * Column 1-6 from the .frq-file (all columns)
#   * Column 4 from the .bim-file (Physical position of the marker)


## Define the header of the outputfile
#header="#CHR\tPOS1\tPOS2\tSNP\tA1\tA2\tMAF\tNCHROBS"
#
## Sorting the input-files based on the 2nd column (SNP identifier) using process substitution
#join -1 2 -2 2 \
#-o 1.1,1.2,1.3,1.4,1.5,1.6,2.4 \
#<(sort -k2,2 "$german_shepherd_allele_freq_dir/german_shepherd_allele_freq.frq") \
#<(sort -k2,2 "$preprocessed_german_shepherd_dir/german_shepherd_filtered.bim") | \
#awk -v OFS='\t' '{print $1,$7,$7+1,$2,$3,$4,$5,$6}' | \
#sort -k1,1n -k2,2n | \
#awk -v OFS='\t' '{print "chr"$1,$2,$3,$4,$5,$6,$7,$8}' | \
#sed '1i'"$header" > "$allele_freq_w_positions_file"
#
#echo "Added physical positions for the markers in the .frq-file"
#echo "The outputfile is stored in: $allele_freq_w_positions_file"


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Function: bedtools intersect
#
###Input:
# 
###Output:
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤



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