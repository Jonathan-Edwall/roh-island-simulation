
#!/bin/bash -l

# Start the timer 
start=$(date +%s)


######################################  
####### Defining parameter values #######
######################################
# Defining the header of the output file
autosome_lengths_header="#Chromosome\tLength(bp)\tLength(KB)"
F_ROH_header="#IID\tF_ROH\tROH_length_kB\tKBAVG"


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



plink_ROH_results_dir=$HOME/results/PLINK/ROH
preprocessed_data_dir=$HOME/data/preprocessed

#�������������
#� Empirical �
#�������������
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

german_shepherd_pop_hom_file_dir=$plink_ROH_results_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

#�������������
#� Simulated � 
#�������������
simulated_plink_dir=$plink_ROH_results_dir/simulated

preprocessed_simulated_data_dir=$preprocessed_data_dir/simulated
preprocessed_neutral_model_dir=$preprocessed_simulated_data_dir/neutral_model
preprocessed_selection_model_dir=$preprocessed_simulated_data_dir/selection_model


neutral_model_pop_hom_file_dir=$simulated_plink_dir/neutral_model
selection_model_pop_hom_file_dir=$simulated_plink_dir/selection_model

#################################### 
# Defining the output files
#################################### 
#¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤ Empirical ¤
#¤¤¤¤¤¤¤¤¤¤¤¤¤
german_shepherd_F_ROH_results=$german_shepherd_pop_hom_file_dir/F_ROH
mkdir -p $german_shepherd_F_ROH_results

#�������������
#� Simulated � 
#�������������
### Neutral Model ###
neutral_model_F_ROH_results=$neutral_model_pop_hom_file_dir/F_ROH
mkdir -p $neutral_model_F_ROH_results

### Selection Model ###
selection_model_F_ROH_results=$selection_model_pop_hom_file_dir/F_ROH
mkdir -p $selection_model_F_ROH_results

###############################################################################################  
# RESULTS
############################################################################################### 

#########################################################
##### Computing F_ROH #####
#########################################################

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Empirical Data (German Shepherd) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Loop through each .hom file in the directory
for hom_file in "$german_shepherd_pop_hom_file_dir"/*.hom.indiv; do
    prefix=$(basename "$hom_file" _ROH.hom.indiv) # Extract the basename without the _ROH.hom.indiv extension
    # Define the output file
    output_file="$german_shepherd_F_ROH_results/${prefix}_F_ROH.tsv"
    # Find autosome lengths file for the current .hom file
    autosome_lengths_file="${preprocessed_german_shepherd_dir}/${prefix}_filtered_autosome_lengths_and_marker_density.tsv"
    # Check if the corresponding autosome lengths file is found
    if [ ! -f "$autosome_lengths_file" ]; then
        echo "Error: $autosome_lengths_file: Autosome lengths file not found for $hom_file"
        continue
    fi

    # Compute autosome length in KB
    autosome_length_kb=$(sed 1d "$autosome_lengths_file" | awk '{ sum += $2 } END { print sum / 1000 }')
    # Find and remove output file (if it exists)
    find "$german_shepherd_F_ROH_results" -name "${prefix}_F_ROH*" -type f -exec rm -f {} +
    # Read the input .hom file line by line, skipping the first line
    sed 1d "$hom_file" | while IFS= read -r line; do
        # Extract IID from the second column
        iid=$(echo "$line" | awk '{print $2}')
        ROH_length_KB=$(echo "$line" | awk '{print $5}')
        # Convert autosome_length_kb to a regular decimal number for the F_ROH computation
        autosome_length_kb_decimal=$(printf "%.5f" "$autosome_length_kb")
        # Calculate F_ROH using awk
        F_ROH=$(awk -v ROH_length_KB="$ROH_length_KB" -v autosome_length_kb="$autosome_length_kb_decimal" 'BEGIN { printf "%.5f", ROH_length_KB / autosome_length_kb }')
        # # Debug the output
        # echo " iid=$iid, ROH_length_KB=$ROH_length_KB, autosome_length_kb=$autosome_length_kb, F_ROH=$F_ROH"
        KB_AVG=$(echo "$line" | awk '{print $6}')
        # Append F_ROH information to output file
        echo -e "$iid\t$F_ROH\t$ROH_length_KB\t$KB_AVG" >> "$output_file"
    done
    # Sort the output file by IID (Individual ID)
    sort -o "$output_file" -k1,1n "$output_file"
    # Add the header to the output file
    sed -i "1i $F_ROH_header" "$output_file"

    # Compute average F_ROH
    avg_F_ROH=$(awk -F'\t' '{ sum += $2 } END { printf "%.5f", sum / NR }' "$output_file")
    
    # Rename output file to include average F_ROH as suffix
    mv "$output_file" "${output_file%.tsv}_${avg_F_ROH}_avg.tsv"
done
echo "Computed Inbreeding Coefficients (F_ROH) for the Empirical Data. Results saved to: $german_shepherd_F_ROH_results"



#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Loop through each .hom file in the directory
for hom_file in "$neutral_model_pop_hom_file_dir"/*.hom.indiv; do
    prefix=$(basename "$hom_file" _ROH.hom.indiv) # Extract the basename without the _ROH.hom.indiv extension
    # Define the output file
    output_file="$neutral_model_F_ROH_results/${prefix}_F_ROH.tsv"
    # Find autosome lengths file for the current .hom file
    autosome_lengths_file="${preprocessed_neutral_model_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"
    # Check if the corresponding autosome lengths file is found
    if [ ! -f "$autosome_lengths_file" ]; then
        echo "Error: Autosome lengths file not found for $hom_file"
        continue
    fi

    # Compute autosome length in KB
    autosome_length_kb=$(sed 1d "$autosome_lengths_file" | awk '{ sum += $2 } END { print sum / 1000 }')
    # Find and remove output file (if it exists)
    find "$neutral_model_F_ROH_results" -name "${prefix}_F_ROH*" -type f -exec rm -f {} +

    # Read the input .hom file line by line, skipping the first line
    sed 1d "$hom_file" | while IFS= read -r line; do
        # Extract IID from the second column
        iid=$(echo "$line" | awk '{print $2}')
        ROH_length_KB=$(echo "$line" | awk '{print $5}')
        # Convert autosome_length_kb to a regular decimal number for the F_ROH computation
        autosome_length_kb_decimal=$(printf "%.5f" "$autosome_length_kb")
        # Calculate F_ROH using awk
        F_ROH=$(awk -v ROH_length_KB="$ROH_length_KB" -v autosome_length_kb="$autosome_length_kb_decimal" 'BEGIN { printf "%.5f", ROH_length_KB / autosome_length_kb }')
        # # Debug the output
        # echo " iid=$iid, ROH_length_KB=$ROH_length_KB, autosome_length_kb=$autosome_length_kb, F_ROH=$F_ROH"
        KB_AVG=$(echo "$line" | awk '{print $6}')
        # Append F_ROH information to output file
        echo -e "$iid\t$F_ROH\t$ROH_length_KB\t$KB_AVG" >> "$output_file"
    done
    # Sort the output file by IID (Individual ID)
    sort -o "$output_file" -k1,1n "$output_file"
    # Add the header to the output file
    sed -i "1i $F_ROH_header" "$output_file"
    # Compute average F_ROH
    avg_F_ROH=$(awk -F'\t' '{ sum += $2 } END { printf "%.5f", sum / NR }' "$output_file")
    
    # Rename output file to include average F_ROH as suffix
    mv "$output_file" "${output_file%.tsv}_${avg_F_ROH}_avg.tsv"
done
echo "Computed Inbreeding Coefficients (F_ROH) for the Neutral Model data. Results saved to: $neutral_model_F_ROH_results"

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Loop through each .hom file in the directory
for hom_file in "$selection_model_pop_hom_file_dir"/*.hom.indiv; do
    prefix=$(basename "$hom_file" _ROH.hom.indiv) # Extract the basename without the _ROH.hom.indiv extension
    # Define the output file
    output_file="$selection_model_F_ROH_results/${prefix}_F_ROH.tsv"
    # Find autosome lengths file for the current .hom file
    autosome_lengths_file="${preprocessed_selection_model_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"
    # Check if the corresponding autosome lengths file is found
    if [ ! -f "$autosome_lengths_file" ]; then
        echo "Error: Autosome lengths file not found for $hom_file"
        continue
    fi

    # Compute autosome length in KB
    autosome_length_kb=$(sed 1d "$autosome_lengths_file" | awk '{ sum += $2 } END { print sum / 1000 }')
    # Find and remove output file (if it exists)
    find "$selection_model_F_ROH_results" -name "${prefix}_F_ROH*" -type f -exec rm -f {} +
    # Read the input .hom file line by line, skipping the first line
    sed 1d "$hom_file" | while IFS= read -r line; do
        # Extract IID from the second column
        iid=$(echo "$line" | awk '{print $2}')
        ROH_length_KB=$(echo "$line" | awk '{print $5}')
        # Convert autosome_length_kb to a regular decimal number for the F_ROH computation
        autosome_length_kb_decimal=$(printf "%.5f" "$autosome_length_kb")
        # Calculate F_ROH using awk
        F_ROH=$(awk -v ROH_length_KB="$ROH_length_KB" -v autosome_length_kb="$autosome_length_kb_decimal" 'BEGIN { printf "%.5f", ROH_length_KB / autosome_length_kb }')
        # # Debug the output
        # echo " iid=$iid, ROH_length_KB=$ROH_length_KB, autosome_length_kb=$autosome_length_kb, F_ROH=$F_ROH"
        KB_AVG=$(echo "$line" | awk '{print $6}')
        # Append F_ROH information to output file
        echo -e "$iid\t$F_ROH\t$ROH_length_KB\t$KB_AVG" >> "$output_file"
    done
    # Sort the output file by IID (Individual ID)
    sort -o "$output_file" -k1,1n "$output_file"
    # Add the header to the output file
    sed -i "1i $F_ROH_header" "$output_file"

    # Compute average F_ROH
    avg_F_ROH=$(awk -F'\t' '{ sum += $2 } END { printf "%.5f", sum / NR }' "$output_file")
    
    # Rename output file to include average F_ROH as suffix
    mv "$output_file" "${output_file%.tsv}_${avg_F_ROH}_avg.tsv"
done
echo "Computed Inbreeding Coefficients (F_ROH) for the Selection Model data. Results saved to: $selection_model_F_ROH_results"



 # Ending the timer 
 end=$(date +%s)
 # Calculating the runtime of the script
 runtime=$((end-start))s

echo "F_ROH computed successfully."

echo "Total Runtime: $runtime seconds"
