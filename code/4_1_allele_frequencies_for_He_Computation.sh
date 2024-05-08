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
preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

#�������������
#� Simulated � 
#�������������
raw_simulated_dir=$raw_data_dir/simulated

raw_simulated_neutral_model_dir=$raw_simulated_dir/neutral_model
raw_simulated_selection_model_dir=$raw_simulated_dir/selection_model

#################################### 
# Defining the output files
#################################### 
plink_results_dir=$HOME/results/PLINK/allele_freq
simulated_plink_dir=$plink_results_dir/simulated
#�������������
#� Empirical � 
#�������������
german_shepherd_allele_freq_plink_output_dir=$plink_results_dir/empirical/german_shepherd
mkdir -p $german_shepherd_allele_freq_plink_output_dir

#�������������
#� Simulated �
#�������������
##### Neutral Model #####
simulated_neutral_model_allele_freq_plink_output_dir=$simulated_plink_dir/neutral_model
mkdir -p $simulated_neutral_model_allele_freq_plink_output_dir
##### Selection Model ##### 
simulated_selection_model_allele_freq_plink_output_dir=$simulated_plink_dir/selection_model
mkdir -p $simulated_selection_model_allele_freq_plink_output_dir
#######################################################  
# RESULTS
####################################################### 

#############################################################################
# Function: join
#
#
###Input: .frq-file with allele frequencies at the different marker positions & .bim-file containing the physical positions of these markers
# 
###Output: A tsv-file with the contents of the .frq-file, combined with information about the physical positons of the markers from the .bim-file.
#############################################################################


#Joins the .frq-file (File 1) and .bim-file (File 2) based on their 2nd column (SNP identifier)
# The input files gets sorted temporarily based on the 2nd column (SNP identifier) using process substitution
# The output file contains:
#   * Column 1-6 from the .frq-file (all columns)
#   * Column 4 from the .bim-file (Physical position of the marker)

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Empirical Data (German Shepherd) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Find any .map file in simulated_data_dir and use its basename as the population name
for file in $preprocessed_german_shepherd_dir/*.bim; do
    # Extract population name from the filename (minus the .map extension)
    population_name=$(basename "${file%.*}")
    echo "population_name"
    
    # Run plink command for the current population
    plink --bfile "${preprocessed_german_shepherd_dir}/${population_name}" \
          --freq --dog --nonfounders --allow-no-sex \
          --out "${german_shepherd_allele_freq_plink_output_dir}/${population_name}_allele_freq"
          
    ##############################
    # Adding POS to the outputfile
    ##############################          
    
    # Define the header of the outputfile
    header="#CHR\tPOS\tSNP\tA1\tA2\tMAF\tNCHROBS"
          
    # Sorting the input-files based on the 2nd column (SNP identifier) using process substitution
    # Then performing join-operation to associate markers SNP-markers in the outputfile with their base-pair positions
    join -1 2 -2 2 \
    -o 1.1,2.4,1.2,1.3,1.4,1.5,1.6 \
    <(sort -k2,2 "${german_shepherd_allele_freq_plink_output_dir}/${population_name}_allele_freq.frq") \
    <(sort -k2,2 "${preprocessed_german_shepherd_dir}/${population_name}.bim") | \
    awk -v OFS='\t' '{print $1,$7,$7+1,$2,$3,$4,$5,$6}' | \
    sort -k1,1n -k2,2n | \
    awk -v OFS='\t' '{print "chr"$1,$2,$3,$4,$5,$6,$7,$8}' | \
    sed '1i'"$header" > "${german_shepherd_allele_freq_plink_output_dir}/${population_name}_allele_freq_w_positions.tsv"
    
    echo "Added physical positions for the markers in ${population_name}_allele_freq.frq"
    echo "The output file is stored in: ${german_shepherd_allele_freq_plink_output_dir}/${population_name}_allele_freq_w_positions.tsv"
    
done


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Find any .map file in simulated_data_dir and use its basename as the simulation name
for simulation_file in $raw_simulated_neutral_model_dir/*.map; do
    # Extract simulation name from the filename (minus the .map extension)
    simulation_name=$(basename "${simulation_file%.*}")
    
    # Run plink command for the current simulation
    plink --file "${raw_simulated_neutral_model_dir}/${simulation_name}" \
          --freq --dog --nonfounders --allow-no-sex \
          --out "${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq"
          
    ##############################
    # Adding POS to the outputfile
    ##############################          
    
    # Define the header of the outputfile
    header="#CHR\tPOS\tSNP\tA1\tA2\tMAF\tNCHROBS"
          
    # Sorting the input-files based on the 2nd column (SNP identifier) using process substitution
    # Then performing join-operation to associate markers SNP-markers in the outputfile with their base-pair positions
    join -1 2 -2 2 \
    -o 1.1,2.4,1.2,1.3,1.4,1.5,1.6 \
    <(sort -k2,2 "${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.frq") \
    <(sort -k2,2 "${raw_simulated_neutral_model_dir}/${simulation_name}.map") | \
    awk -v OFS='\t' '{print "chr"$1,$2,$3,$4,$5,$6,$7}' | \
    sort -k1,1n -k2,2n | \
    sed '1i'"$header" > "${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq_w_positions.tsv"
    
    echo "Added physical positions for the markers in ${simulation_name}_allele_freq.frq"
    echo "The output file is stored in: ${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq_w_positions.tsv"
    
done

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Find any .map file in simulated_data_dir and use its basename as the simulation name
for simulation_file in $raw_simulated_selection_model_dir/*.map; do
    # Extract simulation name from the filename (minus the .map extension)
    simulation_name=$(basename "${simulation_file%.*}")
    
    # Run plink command for the current simulation
    plink --file "${raw_simulated_selection_model_dir}/${simulation_name}" \
          --freq --dog --nonfounders --allow-no-sex \
          --out "${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq"
          
    ##############################
    # Adding POS to the outputfile
    ##############################          
    
    # Define the header of the outputfile
    header="#CHR\tPOS\tSNP\tA1\tA2\tMAF\tNCHROBS"
          
    # Sorting the input-files based on the 2nd column (SNP identifier) using process substitution
    # Then performing join-operation to associate markers SNP-markers in the outputfile with their base-pair positions
    join -1 2 -2 2 \
    -o 1.1,2.4,1.2,1.3,1.4,1.5,1.6 \
    <(sort -k2,2 "${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.frq") \
    <(sort -k2,2 "${raw_simulated_selection_model_dir}/${simulation_name}.map") | \
    awk -v OFS='\t' '{print "chr"$1,$2,$3,$4,$5,$6,$7}' | \
    sort -k1,1n -k2,2n | \
    sed '1i'"$header" > "${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq_w_positions.tsv"
    
    echo "Added physical positions for the markers in ${simulation_name}_allele_freq.frq"
    echo "The output file is stored in: ${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq_w_positions.tsv"
    
done





# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Allele frequencies computed successfully."
echo "The output file are stored in: $german_shepherd_plink_output_dir & $simulated_neutral_model_plink_output_dir " 
echo "Runtime: $runtime seconds"
