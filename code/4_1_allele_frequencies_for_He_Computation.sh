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
#¤¤¤¤¤¤¤¤¤¤
# Empirical
#¤¤¤¤¤¤¤¤¤¤
preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
#¤¤¤¤¤¤¤¤¤¤
# Simulated
#¤¤¤¤¤¤¤¤¤¤
simulated_data_dir=$raw_data_dir/simulated


#################################### 
# Defining the output dirs
#################################### 

plink_output_dir=$HOME/results/PLINK
#¤¤¤¤¤¤¤¤¤¤
# Empirical
#¤¤¤¤¤¤¤¤¤¤
german_shepherd_plink_output_dir=$plink_output_dir/empirical/german_shepherd/allele_freq
mkdir -p $german_shepherd_plink_output_dir
#¤¤¤¤¤¤¤¤¤¤¤
# Simulated
#¤¤¤¤¤¤¤¤¤¤¤
simulated_data_plink_output_dir=$plink_output_dir/simulated/allele_freq
mkdir -p $simulated_data_plink_output_dir

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Function: bedtools freq
#
###Input: .map and .ped files
# 
###Output:
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Calculating the allele frequencies
plink --bfile $preprocessed_german_shepherd_dir/german_shepherd_filtered --freq --dog --nonfounders --allow-no-sex --out $german_shepherd_plink_output_dir/german_shepherd_allele_freq


#plink --file $simulated_data_dir/Neutral_simulation_chr3 --freq --dog --nonfounders --allow-no-sex --out $simulated_data_plink_output_dir/neutral_model_chr_3_allele_freq
# Find any .map file in simulated_data_dir and use its basename as the simulation name
for simulation_file in $simulated_data_dir/*.map; do
    # Extract simulation name from the filename (minus the .map extension)
    simulation_name=$(basename "${simulation_file%.*}")
    
    # Run plink command for the current simulation
    plink --file "${simulated_data_dir}/${simulation_name}" \
          --freq --dog --nonfounders --allow-no-sex \
          --out "${simulated_data_plink_output_dir}/${simulation_name}_allele_freq"
          
    #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    # Adding POS to the outputfile
    #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤          
    
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
