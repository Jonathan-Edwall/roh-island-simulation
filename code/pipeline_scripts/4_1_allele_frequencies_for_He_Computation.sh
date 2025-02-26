#!/bin/bash -l

# script_start the timer 
script_start=$(date +%s)

####################################  
# Defining the working directory
#################################### 
# HOME=/home/jonathan
cd $HOME

######################################  
####### Defining parameter values #######
######################################
header="#CHR\tPOS1\tPOS2\tSNP\tA1\tA2\tMAF\tNCHROBS"
# empirical_breed="empirical_breed" # Defined in run_pipeline.sh

# # Boolean value to determine whether to run the selection simulation code
# selection_simulation=TRUE # Defined in run_pipeline.sh

# Extract the start and end of the chromosome range (e.g., "1-19")
start_chromosome=$(echo $empirical_autosomal_chromosomes | cut -d'-' -f1)
end_chromosome=$(echo $empirical_autosomal_chromosomes | cut -d'-' -f2)

# Calculate the number of chromosomes in the range
num_chromosomes=$((end_chromosome - start_chromosome + 1))

# empirical_species="dog" # Variable Defined in run_pipeline.sh
# Define species-specific options
if [[ "$empirical_species" == "dog" ]]; then
    species_flag="--dog" # Specifies dog chromosome set.
else
    species_flag="--chr-set $num_chromosomes" # Specifies a nonhuman chromosome set
fi


####################################  
# Defining the input files
#################################### 
# Defining input directory
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
preprocessed_data_dir=$data_dir/preprocessed

#�������������
#� Empirical �
#�������������
preprocessed_empirical_breed_dir=$preprocessed_data_dir/empirical/$empirical_breed

#�������������
#� Simulated � 
#�������������
preprocessed_simulated_data_dir=$preprocessed_data_dir/simulated
preprocessed_neutral_model_dir=$preprocessed_simulated_data_dir/neutral_model
preprocessed_selection_model_dir=$preprocessed_simulated_data_dir/selection_model

#################################### 
# Defining the output files
#################################### 
# results_dir=$HOME/results # Variable Defined in run_pipeline.sh
plink_results_dir=$results_dir/PLINK/allele_freq
simulated_plink_dir=$plink_results_dir/simulated
#�������������
#� Empirical � 
#�������������
empirical_breed_allele_freq_plink_output_dir="$plink_results_dir/empirical/$empirical_breed"
mkdir -p $empirical_breed_allele_freq_plink_output_dir

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
#¤¤¤¤ Empirical Data               ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
if [ "$empirical_processing" = TRUE ]; then
    # Find any .bim file in simulated_data_dir and use its basename as the population name
    for file in $preprocessed_empirical_breed_dir/*.bim; do
        # Extract population name from the filename (minus the .bim extension)
        population_name=$(basename "${file%.*}")
        echo "population_name"
        
        # Run plink command for the current population
        plink --bfile "${preprocessed_empirical_breed_dir}/${population_name}" \
            --freq $species_flag --nonfounders --allow-no-sex \
            --out "${empirical_breed_allele_freq_plink_output_dir}/${population_name}_allele_freq"
            
        ##############################
        # Adding POS to the outputfile
        ##############################  
        # .frq example - header row:
        # CHR                         SNP   A1   A2          MAF  NCHROBS
        # 1   chrUn_AAEX03019240_128183    0    C            0      442
        
        #.bim example - No header row:
        # 1       chrUn_AAEX03019240_128183       0       23974   0       C

        # Step 1: Creating temporary files to ensure that the .frq and .bim file are formatted the same way
        extracted_freq="${empirical_breed_allele_freq_plink_output_dir}/extracted_freq.txt"
        extracted_bim="${empirical_breed_allele_freq_plink_output_dir}/extracted_bim.txt"
        awk 'NR > 1 {print $1, $2, $3, $4, $5, $6}' "${empirical_breed_allele_freq_plink_output_dir}/${population_name}_allele_freq.frq" > "$extracted_freq"
        awk '{print $1, $2, $3, $4, $5, $6}' "${preprocessed_empirical_breed_dir}/${population_name}.bim" > "$extracted_bim"
        # Step 2: Perform the join, sort, and clean the output
        join -1 2 -2 2 \
        -o 1.1,2.4,1.2,1.3,1.4,1.5,1.6 \
        <(sort -k2,2 "$extracted_freq") \
        <(sort -k2,2 "$extracted_bim") | \
        sort -k1,1n -k2,2n | \
        awk -v OFS='\t' '{print $1, $2, $2+1, $3, $4, $5, $6, $7}' | \
        sed 's/[[:space:]]\+$//' |  # Remove trailing whitespace, including tabs
        sed "1i$header" > "${empirical_breed_allele_freq_plink_output_dir}/${population_name}_allele_freq.bed"
        # Step 3: Clean up temporary files
        rm "$extracted_freq"
        rm "$extracted_bim"

    echo "Added physical positions for the markers in ${population_name}_allele_freq.frq"
    echo "The output file is stored in: ${empirical_breed_allele_freq_plink_output_dir}/${population_name}_allele_freq.bed"
        
    done
else
    echo "Empirical data has been set to not be processed, since files have already been created."
fi


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Find any .bim file in simulated_data_dir and use its basename as the simulation name
for simulation_file in $preprocessed_neutral_model_dir/*.bim; do
    # Extract simulation name from the filename (minus the .bim extension)
    simulation_name=$(basename "${simulation_file%.*}")
    
    # Run plink command for the current simulation
    plink --bfile "${preprocessed_neutral_model_dir}/${simulation_name}" \
          --freq $species_flag --nonfounders --allow-no-sex \
          --out "${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq"
          
    ##############################
    # Adding POS to the outputfile
    ##############################    
    # Step 1: Creating temporary files to ensure that the .frq and .bim file are formatted the same way
    extracted_freq="${simulated_neutral_model_allele_freq_plink_output_dir}/extracted_freq.txt"
    extracted_bim="${simulated_neutral_model_allele_freq_plink_output_dir}/extracted_bim.txt"
    awk 'NR > 1 {print $1, $2, $3, $4, $5, $6}' "${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.frq" > "$extracted_freq"
    awk '{print $1, $2, $3, $4, $5, $6}' "${preprocessed_neutral_model_dir}/${simulation_name}.bim" > "$extracted_bim"
    # Step 2: Perform the join, sort, and clean the output
    join -1 2 -2 2 \
    -o 1.1,2.4,1.2,1.3,1.4,1.5,1.6 \
    <(sort -k2,2 "$extracted_freq") \
    <(sort -k2,2 "$extracted_bim") | \
    sort -k1,1n -k2,2n | \
    awk -v OFS='\t' '{print $1, $2, $2+1, $3, $4, $5, $6, $7}' | \
    sed 's/[[:space:]]\+$//' |  # Remove trailing whitespace, including tabs
    sed "1i$header" > "${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.bed"
    # Step 3: Clean up temporary files
    rm "$extracted_freq"
    rm "$extracted_bim"         
    echo "Added physical positions for the markers in ${simulation_name}_allele_freq.frq"
    echo "The output file is stored in: ${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.bed"
    
done

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

if [ "$selection_simulation" = TRUE ]; then
    # Find any .bim file in simulated_data_dir and use its basename as the simulation name
    for simulation_file in $preprocessed_selection_model_dir/*.bim; do
        # Extract simulation name from the filename (minus the .bim extension)
        simulation_name=$(basename "${simulation_file%.*}")
        
        # Run plink command for the current simulation
        plink --bfile "${preprocessed_selection_model_dir}/${simulation_name}" \
            --freq $species_flag --nonfounders --allow-no-sex \
            --out "${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq"
            
        ##############################
        # Adding POS to the outputfile
        ##############################    
        # Step 1: Creating temporary files to ensure that the .frq and .bim file are formatted the same way
        extracted_freq="${simulated_selection_model_allele_freq_plink_output_dir}/extracted_freq.txt"
        extracted_bim="${simulated_selection_model_allele_freq_plink_output_dir}/extracted_bim.txt"
        awk 'NR > 1 {print $1, $2, $3, $4, $5, $6}' "${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.frq" > "$extracted_freq"
        awk '{print $1, $2, $3, $4, $5, $6}' "${preprocessed_selection_model_dir}/${simulation_name}.bim" > "$extracted_bim"
        # Step 2: Perform the join, sort, and clean the output
        join -1 2 -2 2 \
        -o 1.1,2.4,1.2,1.3,1.4,1.5,1.6 \
        <(sort -k2,2 "$extracted_freq") \
        <(sort -k2,2 "$extracted_bim") | \
        sort -k1,1n -k2,2n | \
        awk -v OFS='\t' '{print $1, $2, $2+1, $3, $4, $5, $6, $7}' | \
        sed 's/[[:space:]]\+$//' |  # Remove trailing whitespace, including tabs
        sed "1i$header" > "${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.bed"
        # Step 3: Clean up temporary files
        rm "$extracted_freq"
        rm "$extracted_bim"     
    done

else
    echo "Selection simulation is set to FALSE. Skipping the selection model processing."
fi

# script_ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo "Allele frequencies computed successfully."
echo "Runtime: $script_runtime seconds"
