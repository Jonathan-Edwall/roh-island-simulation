
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)


######################################  
####### Defining parameter values #######
######################################
# Defining the header of the output file
autosome_lengths_header="#Chromosome\tLength(bp)\tLength(KB)"
F_ROH_header="#IID\tF_ROH\tROH_length_kB\tKBAVG"

# # Boolean value to determine whether to run the selection simulation code
# selection_simulation=TRUE # Defined in run_pipeline.sh

####################################  
# Defining the working directory
#################################### 
HOME=/home/jonathan
cd $HOME

####################################  
# Defining the input files
#################################### 
# Defining input directory
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
raw_data_dir=$data_dir/raw


# results_dir=$HOME/results # Variable Defined in run_pipeline.sh
plink_ROH_results_dir=$results_dir/PLINK/ROH
preprocessed_data_dir=$data_dir/preprocessed

#�������������
#� Empirical �
#�������������
# empirical_dog_breed="german_shepherd" # Defined in run_pipeline.sh
preprocessed_empirical_breed_dir=$preprocessed_data_dir/empirical/$empirical_dog_breed

empirical_breed_pop_hom_file_dir=$plink_ROH_results_dir/empirical/$empirical_dog_breed

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
empirical_breed_F_ROH_results=$empirical_breed_pop_hom_file_dir/F_ROH
mkdir -p $empirical_breed_F_ROH_results

#�������������
#� Simulated � 
#�������������
### Neutral Model ###
neutral_model_F_ROH_results_dir=$neutral_model_pop_hom_file_dir/F_ROH
mkdir -p $neutral_model_F_ROH_results_dir

### Selection Model ###
selection_model_F_ROH_results_dir=$selection_model_pop_hom_file_dir/F_ROH
mkdir -p $selection_model_F_ROH_results_dir

###############################################################################################  
# RESULTS
############################################################################################### 

#########################################################
##### Computing F_ROH #####
#########################################################
# Number of parallel jobs to run at a time
max_parallel_jobs=10

# Function to compute F_ROH for a single .hom file
process_hom_file() {
    local hom_file=$1
    local prefix=$(basename "$hom_file" _ROH.hom.indiv)

    local preprocessed_simulation_model_dir=$2
    local autosome_lengths_file="${preprocessed_simulation_model_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"

    local simulation_model_F_ROH_results_dir=$3
    local output_file="${simulation_model_F_ROH_results_dir}/${prefix}_F_ROH.tsv"

    # Check if the corresponding autosome lengths file is found
    if [ ! -f "$autosome_lengths_file" ]; then
        echo "Error: Autosome lengths file not found for $hom_file"
        return
    fi

    # Compute autosome length in KB
    local autosome_length_kb=$(sed 1d "$autosome_lengths_file" | awk '{ sum += $2 } END { print sum / 1000 }')
    
    # Remove any existing output file
    find "$simulation_model_F_ROH_results_dir" -name "${prefix}_F_ROH*" -type f -exec rm -f {} +

    # Process each line of the .hom file
    sed 1d "$hom_file" | while IFS= read -r line; do
        local iid=$(echo "$line" | awk '{print $2}')
        local ROH_length_KB=$(echo "$line" | awk '{print $5}')
        local autosome_length_kb_decimal=$(printf "%.5f" "$autosome_length_kb")
        local F_ROH=$(awk -v ROH_length_KB="$ROH_length_KB" -v autosome_length_kb="$autosome_length_kb_decimal" 'BEGIN { printf "%.5f", ROH_length_KB / autosome_length_kb }')
        local KB_AVG=$(echo "$line" | awk '{print $6}')
        echo -e "$iid\t$F_ROH\t$ROH_length_KB\t$KB_AVG" >> "$output_file"
    done
    
    # Sort the output file by IID (Individual ID)
    sort -o "$output_file" -k1,1n "$output_file"
    
    # Add the header to the output file
    sed -i "1i $F_ROH_header" "$output_file"
    
    # Compute average F_ROH
    local avg_F_ROH=$(awk -F'\t' '{ sum += $2 } END { printf "%.5f", sum / NR }' "$output_file")
    
    # Rename output file to include average F_ROH as suffix
    mv "$output_file" "${output_file%.tsv}_${avg_F_ROH}_avg.tsv"

    echo "Processed $hom_file"
}


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Empirical Data  ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
if [ "$empirical_processing" = TRUE ]; then
    # Loop through each .hom file in the directory
    for hom_file in "$empirical_breed_pop_hom_file_dir"/*.hom.indiv; do
        prefix=$(basename "$hom_file" _ROH.hom.indiv) # Extract the basename without the _ROH.hom.indiv extension
        # Define the output file
        output_file="${empirical_breed_F_ROH_results}/${prefix}_F_ROH.tsv"
        # Find autosome lengths file for the current .hom file
        autosome_lengths_file="${preprocessed_empirical_breed_dir}/${prefix}_filtered_autosome_lengths_and_marker_density.tsv"
        # Check if the corresponding autosome lengths file is found
        if [ ! -f "$autosome_lengths_file" ]; then
            echo "Error: $autosome_lengths_file: Autosome lengths file not found for $hom_file"
            continue
        fi

        # Compute autosome length in KB
        autosome_length_kb=$(sed 1d "$autosome_lengths_file" | awk '{ sum += $2 } END { print sum / 1000 }')
        # Find and remove output file (if it exists)
        find "$empirical_breed_F_ROH_results" -name "${prefix}_F_ROH*" -type f -exec rm -f {} +
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
    echo "Computed Inbreeding Coefficients (F_ROH) for the Empirical Data. Results saved to: $empirical_breed_F_ROH_results"
else
    echo "Empirical data has been set to not be processed, since files have already been created."
fi



#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Loop over each .hom file and process it in parallel
for hom_file in "$neutral_model_pop_hom_file_dir"/*.hom.indiv; do
    process_hom_file $hom_file $preprocessed_neutral_model_dir $neutral_model_F_ROH_results_dir &

    # Control the number of parallel jobs
    while [ $(jobs -r | wc -l) -ge $max_parallel_jobs ]; do
        wait -n
    done
done

# Wait for all background jobs to finish
wait
echo "Computed Inbreeding Coefficients (F_ROH) for the Neutral Model data. Results saved to: $neutral_model_F_ROH_results_dir"

# # Loop through each .hom file in the directory
# for hom_file in "$neutral_model_pop_hom_file_dir"/*.hom.indiv; do
#     prefix=$(basename "$hom_file" _ROH.hom.indiv) # Extract the basename without the _ROH.hom.indiv extension
#     # Define the output file
#     output_file="$neutral_model_F_ROH_results_dir/${prefix}_F_ROH.tsv"
#     # Find autosome lengths file for the current .hom file
#     autosome_lengths_file="${preprocessed_neutral_model_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"
#     # Check if the corresponding autosome lengths file is found
#     if [ ! -f "$autosome_lengths_file" ]; then
#         echo "Error: Autosome lengths file not found for $hom_file"
#         continue
#     fi

#     # Compute autosome length in KB
#     autosome_length_kb=$(sed 1d "$autosome_lengths_file" | awk '{ sum += $2 } END { print sum / 1000 }')
#     # Find and remove output file (if it exists)
#     find "$neutral_model_F_ROH_results_dir" -name "${prefix}_F_ROH*" -type f -exec rm -f {} +

#     # Read the input .hom file line by line, skipping the first line
#     sed 1d "$hom_file" | while IFS= read -r line; do
#         # Extract IID from the second column
#         iid=$(echo "$line" | awk '{print $2}')
#         ROH_length_KB=$(echo "$line" | awk '{print $5}')
#         # Convert autosome_length_kb to a regular decimal number for the F_ROH computation
#         autosome_length_kb_decimal=$(printf "%.5f" "$autosome_length_kb")
#         # Calculate F_ROH using awk
#         F_ROH=$(awk -v ROH_length_KB="$ROH_length_KB" -v autosome_length_kb="$autosome_length_kb_decimal" 'BEGIN { printf "%.5f", ROH_length_KB / autosome_length_kb }')
#         # # Debug the output
#         # echo " iid=$iid, ROH_length_KB=$ROH_length_KB, autosome_length_kb=$autosome_length_kb, F_ROH=$F_ROH"
#         KB_AVG=$(echo "$line" | awk '{print $6}')
#         # Append F_ROH information to output file
#         echo -e "$iid\t$F_ROH\t$ROH_length_KB\t$KB_AVG" >> "$output_file"
#     done
#     # Sort the output file by IID (Individual ID)
#     sort -o "$output_file" -k1,1n "$output_file"
#     # Add the header to the output file
#     sed -i "1i $F_ROH_header" "$output_file"
#     # Compute average F_ROH
#     avg_F_ROH=$(awk -F'\t' '{ sum += $2 } END { printf "%.5f", sum / NR }' "$output_file")
    
#     # Rename output file to include average F_ROH as suffix
#     mv "$output_file" "${output_file%.tsv}_${avg_F_ROH}_avg.tsv"
# done

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
if [ "$selection_simulation" = TRUE ]; then
    # Loop through each .hom file in the directory
    for hom_file in "$selection_model_pop_hom_file_dir"/*.hom.indiv; do
        process_hom_file $hom_file $preprocessed_selection_model_dir $selection_model_F_ROH_results_dir &

        # Control the number of parallel jobs
        while [ $(jobs -r | wc -l) -ge $max_parallel_jobs ]; do
            wait -n
        done

    done

    # Wait for all background jobs to finish
    wait
    echo "Computed Inbreeding Coefficients (F_ROH) for the Selection Model data. Results saved to: $selection_model_F_ROH_results_dir"

else
    echo "Selection simulation is set to FALSE. Skipping the selection model processing."
fi

# if [ "$selection_simulation" = TRUE ]; then
#     # Loop through each .hom file in the directory
#     for hom_file in "$selection_model_pop_hom_file_dir"/*.hom.indiv; do
#         prefix=$(basename "$hom_file" _ROH.hom.indiv) # Extract the basename without the _ROH.hom.indiv extension
#         # Define the output file
#         output_file="$selection_model_F_ROH_results_dir/${prefix}_F_ROH.tsv"
#         # Find autosome lengths file for the current .hom file
#         autosome_lengths_file="${preprocessed_selection_model_dir}/${prefix}_autosome_lengths_and_marker_density.tsv"
#         # Check if the corresponding autosome lengths file is found
#         if [ ! -f "$autosome_lengths_file" ]; then
#             echo "Error: Autosome lengths file not found for $hom_file"
#             continue
#         fi

#         # Compute autosome length in KB
#         autosome_length_kb=$(sed 1d "$autosome_lengths_file" | awk '{ sum += $2 } END { print sum / 1000 }')
#         # Find and remove output file (if it exists)
#         find "$selection_model_F_ROH_results_dir" -name "${prefix}_F_ROH*" -type f -exec rm -f {} +
#         # Read the input .hom file line by line, skipping the first line
#         sed 1d "$hom_file" | while IFS= read -r line; do
#             # Extract IID from the second column
#             iid=$(echo "$line" | awk '{print $2}')
#             ROH_length_KB=$(echo "$line" | awk '{print $5}')
#             # Convert autosome_length_kb to a regular decimal number for the F_ROH computation
#             autosome_length_kb_decimal=$(printf "%.5f" "$autosome_length_kb")
#             # Calculate F_ROH using awk
#             F_ROH=$(awk -v ROH_length_KB="$ROH_length_KB" -v autosome_length_kb="$autosome_length_kb_decimal" 'BEGIN { printf "%.5f", ROH_length_KB / autosome_length_kb }')
#             # # Debug the output
#             # echo " iid=$iid, ROH_length_KB=$ROH_length_KB, autosome_length_kb=$autosome_length_kb, F_ROH=$F_ROH"
#             KB_AVG=$(echo "$line" | awk '{print $6}')
#             # Append F_ROH information to output file
#             echo -e "$iid\t$F_ROH\t$ROH_length_KB\t$KB_AVG" >> "$output_file"
#         done
#         # Sort the output file by IID (Individual ID)
#         sort -o "$output_file" -k1,1n "$output_file"
#         # Add the header to the output file
#         sed -i "1i $F_ROH_header" "$output_file"

#         # Compute average F_ROH
#         avg_F_ROH=$(awk -F'\t' '{ sum += $2 } END { printf "%.5f", sum / NR }' "$output_file")
        
#         # Rename output file to include average F_ROH as suffix
#         mv "$output_file" "${output_file%.tsv}_${avg_F_ROH}_avg.tsv"
#     done
#     echo "Computed Inbreeding Coefficients (F_ROH) for the Selection Model data. Results saved to: $selection_model_F_ROH_results_dir"

# else
#     echo "Selection simulation is set to FALSE. Skipping the selection model processing."
# fi


# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo "F_ROH computed successfully."

echo "Total Runtime: $script_runtime seconds"
