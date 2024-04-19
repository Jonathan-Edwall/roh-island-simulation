#!/bin/bash -l

# Start the timer 
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
#�������������
#� Empirical �
#�������������
# .bim file
preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
#�������������
#� Simulated � 
#�������������
simulated_data_dir=$raw_data_dir/simulated
#################################### 
# Defining the output files
#################################### 
plink_output_dir=$HOME/results/PLINK
#�������������
#� Empirical � 
#�������������
german_shepherd_plink_output_dir=$plink_output_dir/empirical/german_shepherd/allele_freq
mkdir -p $german_shepherd_plink_output_dir
empirical_allele_freq_output=$german_shepherd_plink_output_dir/german_shepherd_allele_freq

#�������������
#� Simulated �
#�������������
simulated_data_plink_output_dir=$plink_output_dir/simulated/allele_freq
mkdir -p $simulated_data_plink_output_dir


#######################################################  
# RESULTS
####################################################### 


#?###########################################################################
# Function: bedtools freq
###Input: .map and .ped files
###Output: .frq-files
#############################################################################



# Calculating the allele frequencies
plink --bfile $preprocessed_german_shepherd_dir/german_shepherd_filtered \
      --freq --dog --nonfounders --allow-no-sex \
      --out $empirical_allele_freq_output

#############################################################################
# Function: join
#
#
###Input: .frq-file with allele frequencies at the different marker positions & .bim-file containing the physical positions of these markers
# 
###Output: A tsv-file with the contents of the .frq-file, combined with information about the physical positons of the markers from the .bim-file.
#############################################################################
allele_freq_w_positions_file="${empirical_allele_freq_output}_with_marker_pos.bed"

#Joins the .frq-file (File 1) and .bim-file (File 2) based on their 2nd column (SNP identifier)
# The input files gets sorted temporarily based on the 2nd column (SNP identifier) using process substitution
# The output file contains:
#   * Column 1-6 from the .frq-file (all columns)
#   * Column 4 from the .bim-file (Physical position of the marker)


# Define the header of the outputfile
header="#CHR\tPOS1\tPOS2\tSNP\tA1\tA2\tMAF\tNCHROBS"

# Sorting the input-files based on the 2nd column (SNP identifier) using process substitution
join -1 2 -2 2 \
-o 1.1,1.2,1.3,1.4,1.5,1.6,2.4 \
<(sort -k2,2 "${empirical_allele_freq_output}.frq") \
<(sort -k2,2 "$preprocessed_german_shepherd_dir/german_shepherd_filtered.bim") | \
awk -v OFS='\t' '{print $1,$7,$7+1,$2,$3,$4,$5,$6}' | \
sort -k1,1n -k2,2n | \
awk -v OFS='\t' '{print "chr"$1,$2,$3,$4,$5,$6,$7,$8}' | \
sed '1i'"$header" > "$allele_freq_w_positions_file"

echo "Added physical positions for the markers in the empirical .frq-file"
echo "The outputfile is stored in: $allele_freq_w_positions_file"


##��������������������
##���� Simulated ���� 
##��������������������
#

# Find any .map file in simulated_data_dir and use its basename as the simulation name
for simulation_file in $simulated_data_dir/*.map; do
    # Extract simulation name from the filename (minus the .map extension)
    simulation_name=$(basename "${simulation_file%.*}")
    
    # Run plink command for the current simulation
    plink --file "${simulated_data_dir}/${simulation_name}" \
          --freq --dog --nonfounders --allow-no-sex \
          --out "${simulated_data_plink_output_dir}/${simulation_name}_allele_freq"
          
    ##############################
    # Adding POS to the outputfile
    ##############################          
    
    # Define the header of the outputfile
    header="#CHR\tPOS\tSNP\tA1\tA2\tMAF\tNCHROBS"
          
    # Sorting the input-files based on the 2nd column (SNP identifier) using process substitution
    # Then performing join-operation to associate markers SNP-markers in the outputfile with their base-pair positions
    join -1 2 -2 2 \
    -o 1.1,2.4,1.2,1.3,1.4,1.5,1.6 \
    <(sort -k2,2 "${simulated_data_plink_output_dir}/${simulation_name}_allele_freq.frq") \
    <(sort -k2,2 "${simulated_data_dir}/${simulation_name}.map") | \
    awk -v OFS='\t' '{print "chr"$1,$2,$3,$4,$5,$6,$7}' | \
    sort -k1,1n -k2,2n | \
    sed '1i'"$header" > "${simulated_data_plink_output_dir}/${simulation_name}_allele_freq_w_positions.tsv"
    
    echo "Added physical positions for the markers in ${simulation_name}_allele_freq.frq"
    echo "The output file is stored in: ${simulated_data_plink_output_dir}/${simulation_name}_allele_freq_w_positions.tsv"
    
done



# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Allele frequencies computed successfully."
echo "The output file are stored in: $german_shepherd_plink_output_dir & $simulated_data_plink_output_dir " 
echo "Runtime: $runtime seconds"
