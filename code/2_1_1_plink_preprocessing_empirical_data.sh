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
#�������������
#� Empirical �
#�������������

# Defining input directory
raw_data_dir=$HOME/data/raw
raw_german_shepherd_dir=$raw_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

#################################### 
# Defining the output files
#################################### 
# Defining output directory
preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
mkdir -p $preprocessed_german_shepherd_dir

raw_german_shepherd_PCA_dir=$raw_german_shepherd_dir/PCA
# Creating the PCA directory if it doesnt already exist
mkdir -p $raw_german_shepherd_PCA_dir


###############################################################################################  
# RESULTS
############################################################################################### 


#########################################################
##### PLINK preprocessing #####
#########################################################
#--geno 0.05: maximum threshold for allowed missing genotype rate per marker (5%). If more than 5 % of the individuals in the sampled population has missing genotype at that marker, then the marker will be pruned away
#--mind 0.1: maximum threshold for allowed non-genotyped markers per individual (10%). Individuals with more non-genotyped markers than this threshold, will be pruned away.
# --pca 2: Performing PCA analysis to identify outliers in the dataset by calculating 2 principal components (PCA1,PCA2) that captures the major sources of variation in the dataset while reducing the dimensionality of the data.

# plink \
# --file $raw_german_shepherd_dir/Wang_HDGenetDogs_Genotypes_100621_UK \
# --out $preprocessed_german_shepherd_dir/german_shepherd_filtered \
# --make-bed \
# --dog \
# --geno 0.05 --mind 0.1 \
# --maf 0.05 \
# --pca 2
 
# echo "PLINK preprocessing completed"

plink \
--file $raw_german_shepherd_dir/Wang_HDGenetDogs_Genotypes_100621_UK \
--out $preprocessed_german_shepherd_dir/german_shepherd_filtered \
--make-bed \
--dog \
--geno 0.05 --mind 0.1 \
--pca 2
 
echo "PLINK preprocessing completed"






# Performing PCA on the non-preprocessed dataset for comparison. 
plink \
  --file $raw_german_shepherd_dir/Wang_HDGenetDogs_Genotypes_100621_UK \
  --out $raw_german_shepherd_PCA_dir/Wang_HDGenetDogs_Genotypes_100621_UK \
  --dog \
  --pca 2

#########################################################
##### Calculating Autosome Lengths #####
#########################################################
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Raw Empirical Data (German Shepherd) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Loop through each .map file in the directory
for map_file in "$raw_german_shepherd_dir"/*.map; do
    prefix=$(basename "$map_file" .map) # Extract the basename without the .map extension
    output_file="${raw_german_shepherd_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"
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

echo "Computed chromosome lengths and SNP density for the preprocessed empirical data, saved to: $raw_german_shepherd_dir"

# Check if the output file exists
if [ -f "$output_file" ]; then
    # Sum the values in the 4th column using awk
    export num_markers_raw_empirical_dataset=$(awk '{sum += $4} END {print sum}' "$output_file")
fi

# Output the sum
echo "Total number of markers in the raw empirical dataset: $num_markers_raw_empirical_dataset"



#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Preproccesed Empirical Data (German Shepherd) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Loop through each .bim file in the directory
for bim_file in "$preprocessed_german_shepherd_dir"/*.bim; do
    prefix=$(basename "$bim_file" .bim) # Extract the basename without the .bim extension
    output_file="${preprocessed_german_shepherd_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"
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

echo "Computed chromosome lengths and SNP density for the preprocessed empirical data, saved to: $preprocessed_german_shepherd_dir"
# Check if the output file exists
if [ -f "$output_file" ]; then

    ### Counting how many markers the preprocessed dataset contains ###
    # Sum the values in the 4th column using awk
    export num_markers_preprocessed_empirical_dataset=$(awk '{sum += $4} END {print sum}' "$output_file")

    # Remove "chr" prefix from the simulated chromosome (i.e chr3 becomes 3)
    chr_number=$(echo "$chr_simulated" | sed 's/chr//')

    ### Extracting the SNP Density of the selected chromosome that will be simulated ###
    # Step 1: Find the row where column 1 is equal to the chromosome number in $chr_number
    selected_row=$(awk -v chr="$chr_number" '$1 == chr' "$output_file")
    echo "selected_row: $selected_row"
    # Step 2: Extract the SNP density value from the selected row
    export selected_chr_preprocessed_snp_density_mb=$(echo "$selected_row" | awk '{print $5}')

fi

# Output the sum
echo "Total number of markers in the preprocessed empirical dataset: $num_markers_preprocessed_dataset"
echo "Selected chromosome (chr$chr_simulated) has after the preprocessing the following SNP density per Mb: $selected_chr_preprocessed_snp_density_mb"
echo "selected_chr_preprocessed_snp_density_mb in plink_preprocessing_empirical_data.sh: $selected_chr_preprocessed_snp_density_mb"

# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))s

echo "Total Runtime: $runtime seconds"
