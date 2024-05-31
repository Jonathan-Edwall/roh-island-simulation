#!/bin/bash -l

# Start the timer 
start=$(date +%s)

# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate plink

######################################  
####### Defining parameter values #######
######################################
# Defining the header of the output file
autosome_lengths_header="#Chromosome\tLength(bp)\tLength(KB)\tMarkers\tSNP_density(Mb)"


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

raw_simulated_dir=$raw_data_dir/simulated

#�������������
#� Simulated � 
#�������������
raw_simulated_neutral_model_dir=$raw_simulated_dir/neutral_model
raw_simulated_selection_model_dir=$raw_simulated_dir/selection_model

#################################### 
# Defining the output files
#################################### 
# Defining output directory
preprocessed_data_dir=$HOME/data/preprocessed

preprocessed_simulated_data_dir=$preprocessed_data_dir/simulated
preprocessed_neutral_model_dir=$preprocessed_simulated_data_dir/neutral_model
preprocessed_selection_model_dir=$preprocessed_simulated_data_dir/selection_model


mkdir -p $preprocessed_neutral_model_dir
mkdir -p $preprocessed_selection_model_dir


# Creating the PCA directory if it doesnt already exist
mkdir -p $raw_simulated_neutral_model_dir/PCA



###############################################################################################  
# RESULTS
############################################################################################### 


#########################################################
##### PLINK preprocessing #####
#########################################################
#--geno 0.05: maximum threshold for allowed missing genotype rate per marker (5%). If more than 5 % of the individuals in the sampled population has missing genotype at that marker, then the marker will be pruned away
#--mind 0.1: maximum threshold for allowed non-genotyped markers per individual (10%). Individuals with more non-genotyped markers than this threshold, will be pruned away.
# --pca 2: Performing PCA analysis to identify outliers in the dataset by calculating 2 principal components (PCA1,PCA2) that captures the major sources of variation in the dataset while reducing the dimensionality of the data.

##�������������������������
##���� Neutral Model (Simulated) ���� 
##�������������������������
# Find any .map file in raw_simulated_neutral_model_dir and use its basename as the simulation name
for map_file in $raw_simulated_neutral_model_dir/*.map; do
    simulation_name=$(basename "$map_file" .map) # Extract the basename without the .map extension

echo "$simulation_name"     
# # Running --homozyg command for ROH computation
# plink \
# --file $raw_simulated_neutral_model_dir/$simulation_name \
# --out $preprocessed_neutral_model_dir/$simulation_name \
# --make-bed \
# --nonfounders --allow-no-sex \
# --dog \
# --geno 0.05 --mind 0.1 \
# --maf 0.05 \
# --pca 2

# Running --homozyg command for ROH computation
plink \
--file $raw_simulated_neutral_model_dir/$simulation_name \
--out $preprocessed_neutral_model_dir/$simulation_name \
--make-bed \
--nonfounders --allow-no-sex \
--dog \
--geno 0.05 --mind 0.1 \
--pca 2


    
done

echo "Pre-processing of the Neutral Model completed"
echo "Outputfiles stored in: $preprocessed_neutral_model_dir"

# Find any .map file in raw_simulated_neutral_model_dir and use its basename as the simulation name
for map_file in $raw_simulated_neutral_model_dir/*.map; do
    # Extract simulation name from the filename (minus the .map extension)
    # simulation_name=$(basename "${simulation_file%.*}")  
    simulation_name=$(basename "$map_file" .map) # Extract the basename without the .map extension
  
    echo "$simulation_name"     
          
    # Performing PCA on the non-preprocessed dataset for comparison. 
    plink \
     --file $raw_simulated_neutral_model_dir/$simulation_name \
     --out $raw_simulated_neutral_model_dir/PCA/${simulation_name}_PCA \
     --nonfounders --allow-no-sex \
     --dog \
     --pca 2
    
done

##�������������������������
##���� Selection Model (Simulated) ���� 
##�������������������������
# Find any .map file in raw_simulated_selection_model_dir and use its basename as the simulation name
for map_file in $raw_simulated_selection_model_dir/*.map; do
    # Extract simulation name from the filename (minus the .map extension)
    # simulation_name=$(basename "${simulation_file%.*}")    
    # echo "$simulation_name"     
    simulation_name=$(basename "$map_file" .map) # Extract the basename without the .map extension

    # # Running --homozyg command for ROH computation
    # plink \
    #  --file $raw_simulated_selection_model_dir/$simulation_name \
    #  --out $preprocessed_selection_model_dir/$simulation_name \
    #  --make-bed \
    #  --nonfounders --allow-no-sex \
    #  --dog \
    #  --geno 0.05 --mind 0.1 \
    #  --maf 0.05 \
    #  --pca 2    

        # Running --homozyg command for ROH computation
    plink \
     --file $raw_simulated_selection_model_dir/$simulation_name \
     --out $preprocessed_selection_model_dir/$simulation_name \
     --make-bed \
     --nonfounders --allow-no-sex \
     --dog \
     --geno 0.05 --mind 0.1 \
     --pca 2  

done

echo "Pre-processing of the Selection Model completed"
echo "Outputfiles stored in: $preprocessed_selection_model_dir"

# Find any .map file in raw_simulated_selection_model_dir and use its basename as the simulation name
for map_file in $raw_simulated_selection_model_dir/*.map; do
    # Extract simulation name from the filename (minus the .map extension)
    # simulation_name=$(basename "${simulation_file%.*}")    
    # echo "$simulation_name"     
    simulation_name=$(basename "$map_file" .map) # Extract the basename without the .map extension

          
    # Performing PCA on the non-preprocessed dataset for comparison. 
    plink \
     --file $raw_simulated_selection_model_dir/$simulation_name \
     --out $raw_simulated_selection_model_dir/PCA/${simulation_name}_PCA \
     --nonfounders --allow-no-sex \
     --dog \
     --pca 2
    
done


#########################################################
##### Calculating Autosome Lengths #####
#########################################################
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Raw Data ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
##���������������������
##�� Neutral Model (Simulated) �� 
##���������������������

# Loop through each .map file in the directory
for map_file in "$raw_simulated_neutral_model_dir"/*.map; do
    prefix=$(basename "$map_file" .map) # Extract the basename without the .map extension
    output_file="${raw_simulated_neutral_model_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"
    # Remove the outputfile if it already exists
    rm -f "$output_file"
    # Loop through each unique chromosome that isn't x, y, or mt
    for unique_chr in $(awk '{print $1}' "$map_file" | grep -v -E '^(x|y|mt)$' | sort -u); do
        # Find max and min positions for the current chromosome
        max_pos=$(awk -v chr="$unique_chr" '$1 == chr {print $4}' "$map_file" | sort -nr | head -n1)
        min_pos=$(awk -v chr="$unique_chr" '$1 == chr {print $4}' "$map_file" | sort -n | head -n1 | awk '{printf "%.0f", $1}')

        # Check if max_pos or min_pos are empty
        if [ -z "$max_pos" ] || [ -z "$min_pos" ]; then
            echo "Error: Unable to find max_pos or min_pos for $unique_chr"
            continue
        fi
        # Compute chromosome length in base pairs
        chr_length=$((max_pos - min_pos + 1))
        # # Debug output
        # echo "Debug: max_pos=$max_pos, min_pos=$min_pos, chr_length=$chr_length"
        # Check if chr_length is a valid number
        if [ "$chr_length" -le 0 ]; then
            echo "Error: Invalid chromosome length for $unique_chr"
            continue
        fi
        chr_length_KB=$(echo "scale=0; $chr_length / 1000" | bc)
        # Count the number of SNPs for the current chromosome
        snp_count=$(awk -v chr="$unique_chr" '$1 == chr' "$map_file" | wc -l)
        snps_per_megabases=$(echo "scale=2; $snp_count / ($chr_length_KB / 1000)" | bc)

        # Append chromosome information to output file
        echo -e "$unique_chr\t$chr_length\t$chr_length_KB\t$snp_count\t$snps_per_megabases" >> "$output_file"
    done
    
    # Sort the output file by chromosomes
    sort -o "$output_file" -k1,1n "$output_file"
    # Add the header to the output file
    sed -i "1i $autosome_lengths_header" "$output_file"
done

echo "Computed chromosome lengths and SNP density for the raw Neutral Model simulations, saved to: $raw_simulated_neutral_model_dir"

##���������������������
##�� Selection Model (Simulated) �� 
##���������������������

# Loop through each .map file in the directory
for map_file in "$raw_simulated_selection_model_dir"/*.map; do
    prefix=$(basename "$map_file" .map) # Extract the basename without the .map extension
    output_file="${raw_simulated_selection_model_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"
    # Remove the outputfile if it already exists
    rm -f "$output_file"
    # Loop through each unique chromosome that isn't x, y, or mt
    for unique_chr in $(awk '{print $1}' "$map_file" | grep -v -E '^(x|y|mt)$' | sort -u); do
        # Find max and min positions for the current chromosome
        max_pos=$(awk -v chr="$unique_chr" '$1 == chr {print $4}' "$map_file" | sort -nr | head -n1)
        min_pos=$(awk -v chr="$unique_chr" '$1 == chr {print $4}' "$map_file" | sort -n | head -n1 | awk '{printf "%.0f", $1}')

        # Check if max_pos or min_pos are empty
        if [ -z "$max_pos" ] || [ -z "$min_pos" ]; then
            echo "Error: Unable to find max_pos or min_pos for $unique_chr"
            continue
        fi
        # Compute chromosome length in base pairs
        chr_length=$((max_pos - min_pos + 1))
        # # Debug output
        # echo "Debug: max_pos=$max_pos, min_pos=$min_pos, chr_length=$chr_length"
        # Check if chr_length is a valid number
        if [ "$chr_length" -le 0 ]; then
            echo "Error: Invalid chromosome length for $unique_chr"
            continue
        fi
        chr_length_KB=$(echo "scale=0; $chr_length / 1000" | bc)
        # Count the number of SNPs for the current chromosome
        snp_count=$(awk -v chr="$unique_chr" '$1 == chr' "$map_file" | wc -l)
        snps_per_megabases=$(echo "scale=2; $snp_count / ($chr_length_KB / 1000)" | bc)

        # Append chromosome information to output file
        echo -e "$unique_chr\t$chr_length\t$chr_length_KB\t$snp_count\t$snps_per_megabases" >> "$output_file"
    done
    
    # Sort the output file by chromosomes
    sort -o "$output_file" -k1,1n "$output_file"
    # Add the header to the output file
    sed -i "1i $autosome_lengths_header" "$output_file"
done

echo "Computed chromosome lengths and SNP density for the raw Selection Model simulations, saved to: $raw_simulated_selection_model_dir"


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Preproccesed Data ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#���������������������
#�� Neutral Model (Simulated) �� 
#���������������������

# Loop through each .bim file in the directory
for bim_file in "$preprocessed_neutral_model_dir"/*.bim; do
    prefix=$(basename "$bim_file" .bim) # Extract the basename without the .bim extension
    output_file="${preprocessed_neutral_model_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"
    # Remove the outputfile if it already exists
    rm -f "$output_file"
    # Loop through each unique chromosome that isn't x, y, or mt
    for unique_chr in $(awk '{print $1}' "$bim_file" | grep -v -E '^(x|y|mt)$' | sort -u); do
        # Find max and min positions for the current chromosome
        max_pos=$(awk -v chr="$unique_chr" '$1 == chr {print $4}' "$bim_file" | sort -nr | head -n1)
        min_pos=$(awk -v chr="$unique_chr" '$1 == chr {print $4}' "$bim_file" | sort -n | head -n1 | awk '{printf "%.0f", $1}')

        # Check if max_pos or min_pos are empty
        if [ -z "$max_pos" ] || [ -z "$min_pos" ]; then
            echo "Error: Unable to find max_pos or min_pos for $unique_chr"
            continue
        fi
        # Compute chromosome length in base pairs
        chr_length=$((max_pos - min_pos + 1))
        # # Debug output
        # echo "Debug: max_pos=$max_pos, min_pos=$min_pos, chr_length=$chr_length"
        # Check if chr_length is a valid number
        if [ "$chr_length" -le 0 ]; then
            echo "Error: Invalid chromosome length for $unique_chr"
            continue
        fi
        chr_length_KB=$(echo "scale=0; $chr_length / 1000" | bc)
        # Count the number of SNPs for the current chromosome
        snp_count=$(awk -v chr="$unique_chr" '$1 == chr' "$bim_file" | wc -l)
        snps_per_megabases=$(echo "scale=2; $snp_count / ($chr_length_KB / 1000)" | bc)

        # Append chromosome information to output file
        echo -e "$unique_chr\t$chr_length\t$chr_length_KB\t$snp_count\t$snps_per_megabases" >> "$output_file"
    done
    
    # Sort the output file by chromosomes
    sort -o "$output_file" -k1,1n "$output_file"
    # Add the header to the output file
    sed -i "1i $autosome_lengths_header" "$output_file"
done
echo "Computed chromosome lengths and SNP density for the preprocessed Neutral Model simulations, saved to: $preprocessed_neutral_model_dir"

#���������������������
#�� Selection Model (Simulated) �� 
#���������������������

# Loop through each .bim file in the directory
for bim_file in "$preprocessed_selection_model_dir"/*.bim; do
    prefix=$(basename "$bim_file" .bim) # Extract the basename without the .bim extension
    output_file="${preprocessed_selection_model_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"
    # Remove the outputfile if it already exists
    rm -f "$output_file"
    # Loop through each unique chromosome that isn't x, y, or mt
    for unique_chr in $(awk '{print $1}' "$bim_file" | grep -v -E '^(x|y|mt)$' | sort -u); do
        # Find max and min positions for the current chromosome
        max_pos=$(awk -v chr="$unique_chr" '$1 == chr {print $4}' "$bim_file" | sort -nr | head -n1)
        min_pos=$(awk -v chr="$unique_chr" '$1 == chr {print $4}' "$bim_file" | sort -n | head -n1 | awk '{printf "%.0f", $1}')

        # Check if max_pos or min_pos are empty
        if [ -z "$max_pos" ] || [ -z "$min_pos" ]; then
            echo "Error: Unable to find max_pos or min_pos for $unique_chr"
            continue
        fi
        # Compute chromosome length in base pairs
        chr_length=$((max_pos - min_pos + 1))
        # # Debug output
        # echo "Debug: max_pos=$max_pos, min_pos=$min_pos, chr_length=$chr_length"
        # Check if chr_length is a valid number
        if [ "$chr_length" -le 0 ]; then
            echo "Error: Invalid chromosome length for $unique_chr"
            continue
        fi
        chr_length_KB=$(echo "scale=0; $chr_length / 1000" | bc)
        # Count the number of SNPs for the current chromosome
        snp_count=$(awk -v chr="$unique_chr" '$1 == chr' "$bim_file" | wc -l)
        snps_per_megabases=$(echo "scale=2; $snp_count / ($chr_length_KB / 1000)" | bc)

        # Append chromosome information to output file
        echo -e "$unique_chr\t$chr_length\t$chr_length_KB\t$snp_count\t$snps_per_megabases" >> "$output_file"
    done
    
    # Sort the output file by chromosomes
    sort -o "$output_file" -k1,1n "$output_file"
    # Add the header to the output file
    sed -i "1i $autosome_lengths_header" "$output_file"
done
echo "Computed chromosome lengths and SNP density for the preprocessed Selection Model simulations, saved to: $preprocessed_selection_model_dir"


# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))s

echo "Total Runtime: $runtime seconds"
