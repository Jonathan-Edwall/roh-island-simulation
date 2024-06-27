
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
neutral_model_indv_files=$neutral_model_pop_hom_file_dir/individual_ROH
mkdir -p $neutral_model_indv_files
# Creating a directory to store the .BED-files in, if it does not already exist.
neutral_model_indv_bed_files_dir=$neutral_model_indv_files/bed_format
mkdir -p $neutral_model_indv_bed_files_dir

### Selection Model ###
selection_model_indv_files=$selection_model_pop_hom_file_dir/individual_ROH
mkdir -p $selection_model_indv_files
# Creating a directory to store the .BED-files in, if it does not already exist.
selection_model_indv_bed_files_dir=$selection_model_indv_files/bed_format
mkdir -p $selection_model_indv_bed_files_dir

###############################################################################################  
# RESULTS
############################################################################################### 



#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Creating individual .hom files
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

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
# Read each .hom file in the directory
for hom_file in $neutral_model_pop_hom_file_dir/*.hom; do
    # Extract simulation name from the file name    
    simulation_name=$(basename "$hom_file" | awk -F '.hom' '{print $1}')
    
    # Extract unique IIDs
    unique_iids=$(awk '{print $2}' "$hom_file" | sort -u)
    
    # Remove existing output files with the same IID (if they exist)
    for identifier in $unique_iids; do
        rm -f "$neutral_model_indv_files/${simulation_name}_IID_${identifier}.hom"
    done

    
    # Read the input .hom file line by line, skipping the first line
    sed 1d "$hom_file" | while IFS= read -r line; do
        # Extract IID from the second column
        iid=$(echo "$line" | awk '{print $2}')
        
        # Append the line to the corresponding IID file with simulation name prefix
        echo "$line" >> "$neutral_model_indv_files/${simulation_name}_IID_${iid}.hom"
    done
done

echo "Creation of individual ROH files completed for the neutral model"
echo "The output files are stored in: $neutral_model_indv_files"

# #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# #¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
# #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

if [ "$selection_simulation" = TRUE ]; then
    # Read each .hom file in the directory
    for hom_file in $selection_model_pop_hom_file_dir/*.hom; do
        # Extract simulation name from the file name    
        simulation_name=$(basename "$hom_file" | awk -F '.hom' '{print $1}')
        
        # Extract unique IIDs
        unique_iids=$(awk '{print $2}' "$hom_file" | sort -u)
        
        # Remove existing output files with the same IID (if they exist)
        for identifier in $unique_iids; do
            rm -f "$selection_model_indv_files/${simulation_name}_IID_${identifier}.hom"
        done

        
        # Read the input .hom file line by line, skipping the first line
        sed 1d "$hom_file" | while IFS= read -r line; do
            # Extract IID from the second column
            iid=$(echo "$line" | awk '{print $2}')
            
            # Append the line to the corresponding IID file with simulation name prefix
            echo "$line" >> "$selection_model_indv_files/${simulation_name}_IID_${iid}.hom"
        done
    done

    echo "Creation of individual ROH files completed for the selection model"
    echo "The output files are stored in: $selection_model_indv_files"

else
    echo "Selection simulation is set to FALSE. Skipping the selection model processing."
fi



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
# Convert each individual .hom file into .bed-format
for hom_file in $neutral_model_indv_files/*.hom; do
    # Extract individual ID from the file name (everything before the .hom extension)
    individual_id=$(basename "$hom_file" .hom)    
    
    # Remove existing .bed file (if it exists)
    rm -f "$neutral_model_indv_bed_files_dir/${individual_id}.bed"
    
    # Convert .hom to .bed format
    awk 'BEGIN {OFS="\t"} {print $4,$7,$8}' "$hom_file" | sed '1i'"$header" > "$neutral_model_indv_bed_files_dir/${individual_id}.bed"
done
echo "Creation of individual ROH files in BED-format completed for the neutral model"
echo "The output files are stored in: $neutral_model_indv_bed_files_dir"



#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
if [ "$selection_simulation" = TRUE ]; then
    # Convert each individual .hom file into .bed-format
    for hom_file in $selection_model_indv_files/*.hom; do
        # Extract individual ID from the file name (everything before the .hom extension)
        individual_id=$(basename "$hom_file" .hom)
        
        # Remove existing .bed file (if it exists)
        rm -f "$selection_model_indv_bed_files_dir/${individual_id}.bed"
        
        # Convert .hom to .bed format
        awk 'BEGIN {OFS="\t"} {print $4,$7,$8}' "$hom_file" | sed '1i'"$header" > "$selection_model_indv_bed_files_dir/${individual_id}.bed"
    done
    echo "Creation of individual ROH files in BED-format completed for the selection model"
    echo "The output files are stored in: $selection_model_indv_bed_files_dir"

else
    echo ""
fi


 # Ending the timer 
 script_end=$(date +%s)
 # Calculating the script_runtime of the script
 script_runtime=$((script_end-script_start))

echo "Individual ROH-files created successfully."

echo "Total Runtime: $script_runtime seconds"
