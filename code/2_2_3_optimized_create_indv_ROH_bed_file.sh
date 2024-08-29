
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate bedtools # /home/martin/anaconda3/envs/bedtools/bin/bedtools --version: bedtools v2.30.0  

######################################  
####### Defining parameter values #######
######################################
# Defining the header of the output file
header="#CHR\tPOS1\tPOS2"

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
# results_dir=$HOME/results # Variable Defined in run_pipeline.sh
plink_results_dir=$results_dir/PLINK/ROH
simulated_plink_dir=$plink_results_dir/simulated
#�������������
#� Empirical �
#�������������
# empirical_dog_breed="german_shepherd" # Defined in run_pipeline.sh
empirical_breed_pop_hom_file_dir=$plink_results_dir/empirical/$empirical_dog_breed

#�������������
#� Simulated � 
#�������������
neutral_model_pop_hom_file_dir=$simulated_plink_dir/neutral_model
selection_model_pop_hom_file_dir=$simulated_plink_dir/selection_model

#################################### 
# Defining the output files
#################################### 
#¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤ Empirical ¤
#¤¤¤¤¤¤¤¤¤¤¤¤¤
empirical_breed_indv_files=$empirical_breed_pop_hom_file_dir/individual_ROH
mkdir -p $empirical_breed_indv_files

# Creating a directory to store the .BED-files in, if it does not already exist.
empirical_breed_indv_bed_files_dir=$empirical_breed_indv_files/bed_format
mkdir -p $empirical_breed_indv_bed_files_dir
#�������������
#� Simulated � 
#�������������
### Neutral Model ###
neutral_model_indv_files_dir=$neutral_model_pop_hom_file_dir/individual_ROH
mkdir -p $neutral_model_indv_files_dir
# Creating a directory to store the .BED-files in, if it does not already exist.
neutral_model_indv_bed_files_dir=$neutral_model_indv_files_dir/bed_format
mkdir -p $neutral_model_indv_bed_files_dir

### Selection Model ###
selection_model_indv_files_dir=$selection_model_pop_hom_file_dir/individual_ROH
mkdir -p $selection_model_indv_files_dir
# Creating a directory to store the .BED-files in, if it does not already exist.
selection_model_indv_bed_files_dir=$selection_model_indv_files_dir/bed_format
mkdir -p $selection_model_indv_bed_files_dir

###############################################################################################  
# RESULTS
############################################################################################### 



#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Creating individual .hom files
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Number of parallel jobs to run at a time
max_parallel_jobs_create_indv_hom_files=20
max_parallel_jobs_make_indv_bed=400

# # Function to process a single .hom file
# create_indv_hom_files() {
#     local hom_file=$1
#     local simulation_model_indv_files_dir=$2
    
#     # Extract simulation name from the file name    
#     simulation_name=$(basename "$hom_file" | awk -F '.hom' '{print $1}')
    
#     # Extract unique IIDs
#     unique_iids=$(awk '{print $2}' "$hom_file" | sort -u)
    
#     # Remove existing output files with the same IID (if they exist)
#     for identifier in $unique_iids; do
#         rm -f "${simulation_model_indv_files_dir}/${simulation_name}_IID_${identifier}.hom"
#     done

#     # Read the input .hom file line by line, skipping the first line
#     sed 1d "$hom_file" | while IFS= read -r line; do
#         # Extract IID from the second column
#         iid=$(echo "$line" | awk '{print $2}')
        
#         # Append the line to the corresponding IID file with simulation name prefix
#         echo "$line" >> "${simulation_model_indv_files_dir}/${simulation_name}_IID_${iid}.hom"
#     done

#     # echo "Processed $hom_file"
# }
create_indv_hom_files() {
    local hom_file=$1
    local simulation_model_indv_files_dir=$2
    
    # Extract simulation name from the file name    
    simulation_name=$(basename "$hom_file" | awk -F '.hom' '{print $1}')

    # # Extract unique IIDs
    # unique_iids=$(awk '{print $2}' "$hom_file" | sort -u)
    
    # # Remove existing output files with the same IID (if they exist)
    # for identifier in $unique_iids; do
    #     rm -f "${simulation_model_indv_files_dir}/${simulation_name}_IID_${identifier}.hom"
    # done

    
    # Process the input .hom file in one go skipping the first line
    awk -v sim_name="$simulation_name" -v output_dir="$simulation_model_indv_files_dir" '
    {
        # Skip the header (first line)
        if (NR == 1) next;

        # Extract IID from the second column of the population .hom file
        iid = $2;

        # Defining the full path of the outputfile
        output_file = output_dir "/" sim_name "_IID_" iid ".hom";

        # Appending the line to the corresponding IID file with simulation name prefix
        print $0 >> output_file;
    }' "$hom_file"




}


# Function to convert a single .hom file to .bed format
convert_indv_hom_to_bed() {
    local hom_file=$1
    local individual_id=$(basename "$hom_file" .hom)
    local simulation_model_indv_bed_files_dir=$2    
    # # Remove existing .bed file (if it exists)
    # rm -f "${simulation_model_indv_bed_files_dir}/${individual_id}.bed"    
    # Convert .hom to .bed format
    awk 'BEGIN {OFS="\t"} {print $4,$7,$8}' "$hom_file" | sed '1i'"$header" > "${simulation_model_indv_bed_files_dir}/${individual_id}.bed"
    # echo "Processed $hom_file"
}




#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Empirical Data (German Shepherd) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

if [ "$empirical_processing" = TRUE ]; then
    # Read each .hom file in the directory
    for hom_file in "$empirical_breed_pop_hom_file_dir"/*.hom; do
        # Extract the empirical name from the .hom file name
        empirical_name=$(basename "$hom_file" | awk -F '.hom' '{print $1}')
        
        # Extract unique IIDs
        unique_iids=$(awk '{print $2}' "$hom_file" | sort -u)

        # Remove existing output files with the same IID (if they exist)
        for identifier in $unique_iids; do
            rm -f "$empirical_breed_indv_files/${empirical_name}_IID_${identifier}.hom"
        done

        # Read the input .hom file line by line, skipping the first line
        sed 1d "$hom_file" | while IFS= read -r line; do
            # Extract IID from the second column
            iid=$(echo "$line" | awk '{print $2}')

            # Define the output file
            output_file="$empirical_breed_indv_files/${empirical_name}_IID_${iid}.hom"

            # Append the line to the corresponding IID file with simulation name prefix
            echo "$line" >> "$output_file"
        done
    done

    echo "Creation of individual ROH files completed for the empirical data"
    echo "The output files are stored in: $empirical_breed_indv_files"
else
    echo "Empirical data has been set to not be processed, since files have already been created."
fi


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
rm -f "${neutral_model_indv_files_dir}/*.hom" #Removing pre-existing individual hom-files in the directory

# Parallel processing of .hom files in the directory
for hom_file in $neutral_model_pop_hom_file_dir/*.hom; do
    create_indv_hom_files $hom_file $neutral_model_indv_files_dir &

    # Control the number of parallel jobs
    while [ $(jobs -r | wc -l) -ge $max_parallel_jobs_create_indv_hom_files ]; do
        wait -n
    done

done

# Wait for all background jobs to finish
wait
echo "Creation of individual ROH files completed for the neutral model"
echo "The output files are stored in: $neutral_model_indv_files_dir"

# # Read each .hom file in the directory
# for hom_file in $neutral_model_pop_hom_file_dir/*.hom; do
#     # Extract simulation name from the file name    
#     simulation_name=$(basename "$hom_file" | awk -F '.hom' '{print $1}')
    
#     # Extract unique IIDs
#     unique_iids=$(awk '{print $2}' "$hom_file" | sort -u)
    
#     # Remove existing output files with the same IID (if they exist)
#     for identifier in $unique_iids; do
#         rm -f "$neutral_model_indv_files_dir/${simulation_name}_IID_${identifier}.hom"
#     done

    
#     # Read the input .hom file line by line, skipping the first line
#     sed 1d "$hom_file" | while IFS= read -r line; do
#         # Extract IID from the second column
#         iid=$(echo "$line" | awk '{print $2}')
        
#         # Append the line to the corresponding IID file with simulation name prefix
#         echo "$line" >> "$neutral_model_indv_files_dir/${simulation_name}_IID_${iid}.hom"
#     done
# done


# #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# #¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
# #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
rm -f "${selection_model_indv_files_dir}/*.hom" #Removing pre-existing individual hom-files in the directory

if [ "$selection_simulation" = TRUE ]; then
    # Read each .hom file in the directory
    for hom_file in $selection_model_pop_hom_file_dir/*.hom; do
        create_indv_hom_files $hom_file $selection_model_indv_files_dir &

        # Control the number of parallel jobs
        while [ $(jobs -r | wc -l) -ge $max_parallel_jobs_create_indv_hom_files ]; do
            wait -n
        done
    done

    # Wait for all background jobs to finish
    wait
    echo "Creation of individual ROH files completed for the selection model"
    echo "The output files are stored in: $selection_model_indv_files_dir"


else
    echo "Selection simulation is set to FALSE. Skipping the selection model processing."
fi



# if [ "$selection_simulation" = TRUE ]; then
#     # Read each .hom file in the directory
#     for hom_file in $selection_model_pop_hom_file_dir/*.hom; do
#         create_indv_hom_files $hom_file $selection_model_indv_files_dir &

#         # Control the number of parallel jobs
#         while [ $(jobs -r | wc -l) -ge $max_parallel_jobs ]; do
#             wait -n
#         done
#     done

#     echo "Creation of individual ROH files completed for the selection model"
#     echo "The output files are stored in: $selection_model_indv_files_dir"

# else
#     echo "Selection simulation is set to FALSE. Skipping the selection model processing."
# fi




# if [ "$selection_simulation" = TRUE ]; then
#     # Read each .hom file in the directory
#     for hom_file in $selection_model_pop_hom_file_dir/*.hom; do
#         # Extract simulation name from the file name    
#         simulation_name=$(basename "$hom_file" | awk -F '.hom' '{print $1}')
        
#         # Extract unique IIDs
#         unique_iids=$(awk '{print $2}' "$hom_file" | sort -u)
        
#         # Remove existing output files with the same IID (if they exist)
#         for identifier in $unique_iids; do
#             rm -f "$selection_model_indv_files_dir/${simulation_name}_IID_${identifier}.hom"
#         done

        
#         # Read the input .hom file line by line, skipping the first line
#         sed 1d "$hom_file" | while IFS= read -r line; do
#             # Extract IID from the second column
#             iid=$(echo "$line" | awk '{print $2}')
            
#             # Append the line to the corresponding IID file with simulation name prefix
#             echo "$line" >> "$selection_model_indv_files_dir/${simulation_name}_IID_${iid}.hom"
#         done
#     done

#     echo "Creation of individual ROH files completed for the selection model"
#     echo "The output files are stored in: $selection_model_indv_files_dir"

# else
#     echo "Selection simulation is set to FALSE. Skipping the selection model processing."
# fi



#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Creating bed-files from the .hom-files
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Empirical Data  ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
if [ "$empirical_processing" = TRUE ]; then
    #Convert each individual .hom file into .bed-format
    for hom_file in $empirical_breed_indv_files/*.hom; do
        # Extract individual ID from the file name (everything before the .hom extension)
        individual_id=$(basename "$hom_file" .hom)
        
        # Remove existing .bed file (if it exists)
        rm -f "$empirical_breed_indv_bed_files_dir/${individual_id}.bed"
        
        # Convert .hom to .bed format
        awk 'BEGIN {OFS="\t"} {print $4,$7,$8}' "$hom_file" | sed '1i'"$header" > "$empirical_breed_indv_bed_files_dir/${individual_id}.bed"
    done

    echo "Creation of individual ROH files in BED-format completed for the empirical data"
    echo "The output files are stored in: $empirical_breed_indv_bed_files_dir"
else
    echo ""
fi

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
rm -f "${neutral_model_indv_bed_files_dir}/*.bed" # Removing all pre-existing individual .bed files in the directory

# Loop over each .hom file and process it in parallel
for hom_file in $neutral_model_indv_files_dir/*.hom; do
    convert_indv_hom_to_bed $hom_file $neutral_model_indv_bed_files_dir &

    # Control the number of parallel jobs
    while [ $(jobs -r | wc -l) -ge $max_parallel_jobs_make_indv_bed ]; do
        wait -n
    done
done

# Wait for all background jobs to finish
wait
echo "Creation of individual ROH files in BED-format completed for the neutral model"
echo "The output files are stored in: $neutral_model_indv_bed_files_dir"

# # Convert each individual .hom file into .bed-format
# for hom_file in $neutral_model_indv_files_dir/*.hom; do
#     # Extract individual ID from the file name (everything before the .hom extension)
#     individual_id=$(basename "$hom_file" .hom)    
    
#     # Remove existing .bed file (if it exists)
#     rm -f "$neutral_model_indv_bed_files_dir/${individual_id}.bed"
    
#     # Convert .hom to .bed format
#     awk 'BEGIN {OFS="\t"} {print $4,$7,$8}' "$hom_file" | sed '1i'"$header" > "$neutral_model_indv_bed_files_dir/${individual_id}.bed"
# done

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
rm -f "${selection_model_indv_bed_files_dir}/*.bed" # Removing all pre-existing individual .bed files in the directory

if [ "$selection_simulation" = TRUE ]; then
    # Loop over each .hom file and process it in parallel
    for hom_file in $selection_model_indv_files_dir/*.hom; do
        convert_indv_hom_to_bed $hom_file $selection_model_indv_bed_files_dir &
        # Control the number of parallel jobs
        while [ $(jobs -r | wc -l) -ge $max_parallel_jobs_make_indv_bed ]; do
            wait -n
        done
    done
    # Wait for all background jobs to finish
    wait
    echo "Creation of individual ROH files in BED-format completed for the selection model"
    echo "The output files are stored in: $selection_model_indv_bed_files_dir"
else
    echo ""
fi


# if [ "$selection_simulation" = TRUE ]; then
#     # Convert each individual .hom file into .bed-format
#     for hom_file in $selection_model_indv_files_dir/*.hom; do
#         # Extract individual ID from the file name (everything before the .hom extension)
#         individual_id=$(basename "$hom_file" .hom)
        
#         # Remove existing .bed file (if it exists)
#         rm -f "$selection_model_indv_bed_files_dir/${individual_id}.bed"
        
#         # Convert .hom to .bed format
#         awk 'BEGIN {OFS="\t"} {print $4,$7,$8}' "$hom_file" | sed '1i'"$header" > "$selection_model_indv_bed_files_dir/${individual_id}.bed"
#     done
#     echo "Creation of individual ROH files in BED-format completed for the selection model"
#     echo "The output files are stored in: $selection_model_indv_bed_files_dir"

# else
#     echo ""
# fi


# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo "Individual ROH-files created successfully."

echo "Total Runtime: $script_runtime seconds"
