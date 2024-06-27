#!/bin/bash -l

# script_start the timer 
script_start=$(date +%s)

# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate plink

####################################  
# Defining the working directory
#################################### 
HOME=/home/jonathan
cd $HOME

######################################  
####### Defining parameter values #######
######################################
header="#CHR\tPOS1\tPOS2\tSNP\tA1\tA2\tMAF\tNCHROBS"
# empirical_dog_breed="empirical_breed" # Defined in run_pipeline.sh

# # Boolean value to determine whether to run the selection simulation code
# selection_simulation=TRUE # Defined in run_pipeline.sh


####################################  
# Defining the input files
#################################### 
# Defining input directory
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
preprocessed_data_dir=$data_dir/preprocessed

#�������������
#� Empirical �
#�������������
preprocessed_empirical_breed_dir=$preprocessed_data_dir/empirical/$empirical_dog_breed

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
empirical_breed_allele_freq_plink_output_dir="$plink_results_dir/empirical/$empirical_dog_breed"
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
            --freq --dog --nonfounders --allow-no-sex \
            --out "${empirical_breed_allele_freq_plink_output_dir}/${population_name}_allele_freq"
            
        ##############################
        # Adding POS to the outputfile
        ##############################          
        
        # Sorting the input files based on the 2nd column (SNP identifier) using process substitution
        # Then performing a join operation (based on the 2nd column) to associate markers SNP-markers in the outputfile with their base-pair positions
        # tail -n +2 is used on the .frq file since it involves a header line.
        join -1 2 -2 2 \
        -o 1.1,2.4,1.2,1.3,1.4,1.5,1.6 \
        <(tail -n +2 "${empirical_breed_allele_freq_plink_output_dir}/${population_name}_allele_freq.frq" | sort -k2,2) \
        <(sort -k2,2 "${preprocessed_empirical_breed_dir}/${population_name}.bim") | \
        sort -k1,1n -k2,2n | \
        awk -v OFS='\t' '{print $1,$2,$2+1,$3,$4,$5,$6,$7}' | \
        sed 's/[[:space:]]\+$//' |  # Remove trailing whitespace, including tabs
        sed '1i'"$header" > "${empirical_breed_allele_freq_plink_output_dir}/${population_name}_allele_freq.bed"

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
          --freq --dog --nonfounders --allow-no-sex \
          --out "${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq"
          
    ##############################
    # Adding POS to the outputfile
    ##############################          
              
    # Sorting the input-files based on the 2nd column (SNP identifier) using process substitution
    # Then performing join-operation to associate markers SNP-markers in the outputfile with their base-pair positions
    join -1 2 -2 2 \
    -o 1.1,2.4,1.2,1.3,1.4,1.5,1.6 \
    <(tail -n +2 "${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.frq" | sort -k2,2) \
    <(sort -k2,2 "${preprocessed_neutral_model_dir}/${simulation_name}.bim") | \
    sort -k1,1n -k2,2n | \
    awk -v OFS='\t' '{print $1,$2,$2+1,$3,$4,$5,$6,$7}' | \
    sed 's/[[:space:]]\+$//' |  # Remove trailing whitespace, including tabs
    sed '1i'"$header" > "${simulated_neutral_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.bed"
    
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
            --freq --dog --nonfounders --allow-no-sex \
            --out "${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq"
            
        ##############################
        # Adding POS to the outputfile
        ##############################          
            
        # Sorting the input-files based on the 2nd column (SNP identifier) using process substitution
        # Then performing join-operation to associate markers SNP-markers in the outputfile with their base-pair positions
        join -1 2 -2 2 \
        -o 1.1,2.4,1.2,1.3,1.4,1.5,1.6 \
        <(tail -n +2 "${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.frq" | sort -k2,2) \
        <(sort -k2,2 "${preprocessed_selection_model_dir}/${simulation_name}.bim") | \
        sort -k1,1n -k2,2n | \
        awk -v OFS='\t' '{print $1,$2,$2+1,$3,$4,$5,$6,$7}' | \
        sed 's/[[:space:]]\+$//' |  # Remove trailing whitespace, including tabs
        sed '1i'"$header" > "${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.bed"
        
        echo "Added physical positions for the markers in ${simulation_name}_allele_freq.frq"
        echo "The output file is stored in: ${simulated_selection_model_allele_freq_plink_output_dir}/${simulation_name}_allele_freq.bed"
        
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
