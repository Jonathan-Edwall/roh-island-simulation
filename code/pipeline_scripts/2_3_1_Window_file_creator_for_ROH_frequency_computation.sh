
#!/bin/bash
# Start the timer 
start=$(date +%s)
######################################  
####### Defining parameter values #######
######################################
# # Boolean value to determine whether to run the selection simulation code
# selection_simulation=TRUE # Defined in run_pipeline.sh


# Define the window sizes in base pairs
window_size_bp=100000  # 100kB as window size

# To create window files for the studied species, one has to manually input the correct chromosomes and chromosomes sizes 
# in basepairs into the variable: "chromosome_lengths_bp"
#���������������������
#� 100kbp window files based on�
#� the canine reference assembly�
#� UU_Cfam_GSD_1.0          �
#���������������������
# Chromosome lengths of the dog autosome, derived from the canine reference assembly UU_Cfam_GSD_1.0,
# which can be found through this link:
# https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_011100685.1/
declare -A chromosome_lengths_bp=(
    ["1"]=123556469 ["2"]=84979418 ["3"]=92479059 ["4"]=89535178 ["5"]=89562946
    ["6"]=78113029 ["7"]=81081596 ["8"]=76405709 ["9"]=61171909 ["10"]=70643054
    ["11"]=74805798 ["12"]=72970719 ["13"]=64299765 ["14"]=61112200 ["15"]=64676183
    ["16"]=60362399 ["17"]=65088165 ["18"]=56472973 ["19"]=55516201 ["20"]=58627490
    ["21"]=51742555 ["22"]=61573679 ["23"]=53134997 ["24"]=48566227 ["25"]=51730745
    ["26"]=39257614 ["27"]=46662488 ["28"]=41733330 ["29"]=42517134 ["30"]=40643782
    ["31"]=39901454 ["32"]=40225481 ["33"]=32139216 ["34"]=42397973 ["35"]=28051305
    ["36"]=31223415 ["37"]=30785915 ["38"]=24803098
)
####################################  
# Defining the working directory
#################################### 
# HOME=/home/jonathan
cd $HOME
######################################  
####### Defining the input files #######
######################################  
# Defining the path to the 100kbp window files for the dog autosome
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
preprocessed_data_dir=$data_dir/preprocessed
#�������������
#� Empirical �
#�������������
# empirical_breed="german_shepherd" # Defined in run_pipeline.sh
preprocessed_empirical_breed_dir=$preprocessed_data_dir/empirical/$empirical_breed
empirical_breed_autosome_lengths_file=$preprocessed_empirical_breed_dir/"${empirical_breed}_filtered_autosome_lengths_and_marker_density.tsv"
######################################  
####### Defining the output files #######
######################################  
window_files_dir=$preprocessed_data_dir/empirical/genomic_window_files
mkdir -p $window_files_dir
#�������������
#� Empirical �
#�������������
empirical_dataset_output_window_file="${window_files_dir}/${empirical_breed}_autosome_windows_100kB_window_sizes.bed"
if [ "$empirical_processing" = TRUE ]; then
    # Remove the existing output file if it exists
    if [ -e "$empirical_dataset_output_window_file" ]; then
        rm "$empirical_dataset_output_window_file"
    fi
else
    echo "Empirical data has been set to not be processed, since files have already been created."
fi
#���������������������
#� 100kbp window files based on�
#� the canine reference assembly�
#� UU_Cfam_GSD_1.0          �
#���������������������
species_reference_assembly_output_window_file=$window_files_dir/${empirical_species}_reference_assembly_autosome_windows_100kB_window_sizes.bed
# Remove the existing output file if it exists
if [ -e "$species_reference_assembly_output_window_file" ]; then
    rm "$species_reference_assembly_output_window_file"
fi
###############################################################################################  
# RESULTS
############################################################################################### 
#�������������
#� Empirical window file �
#�������������
if [ "$empirical_processing" = TRUE ]; then
    # Write the header to the output file
    echo -e "#Chromosome\tStart\tEnd" > $empirical_dataset_output_window_file
    # Read the input file $empirical_breed_autosome_lengths_file line by line, skipping the first line
    sed 1d "$empirical_breed_autosome_lengths_file" | while IFS=$'\t' read -r line; do
        chrom=$(echo "$line" | cut -f1)
        length_bp=$(echo "$line" | cut -f2)
        window_start=1
        while ((window_start <= length_bp)); do
            window_end=$((window_start + window_size_bp - 1))
            # Ensure that the final window of a chromosome doesn't exceed the chromosome length
            if ((window_end > length_bp)); then
                window_end=$length_bp
            fi
            # Append the window to the output file
            echo -e "$chrom\t$window_start\t$window_end" >> "$empirical_dataset_output_window_file"
            # Move to the next window position
            ((window_start += window_size_bp))
        done
    done

else
    echo ""
fi
# Sort the output file by genomic coordinates
sort -k1,1n -k2,2n -o "$empirical_dataset_output_window_file" "$empirical_dataset_output_window_file"
echo "Window file written to $empirical_dataset_output_window_file"

#����������������������������������
#� Creation of the 100kbp window files based on    �
#� the chromosomes and chromosome lengths in the  �
#� chromosome_lengths_bp variable, defined above    �
#����������������������������������
# Write the header to the output file
echo -e "#Chromosome\tStart\tEnd" > "$species_reference_assembly_output_window_file"
# Iterate over chromosome lengths and generate windows
for chrom in "${!chromosome_lengths_bp[@]}"; do
    length_bp=${chromosome_lengths_bp[$chrom]}
    window_start=1
    while ((window_start <= length_bp)); do
        window_end=$((window_start + window_size_bp - 1))
        # Ensure that the final window of a chromosome doesn't exceed the chromosome length
        if ((window_end > length_bp)); then
            window_end=$length_bp
        fi
        # Append the window to the output file
        echo -e "$chrom\t$window_start\t$window_end" >> "$species_reference_assembly_output_window_file"
        # Move to the next window position
        ((window_start += window_size_bp))
    done
done
# Sort the output file by genomic coordinates
sort -k1,1n -k2,2n -o "$species_reference_assembly_output_window_file" "$species_reference_assembly_output_window_file"
echo "Window file written to $species_reference_assembly_output_window_file"
# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))s
echo "Genomic window files successfully created"
echo "Total Runtime: $runtime seconds"