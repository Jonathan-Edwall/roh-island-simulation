
#!/bin/bash
# Start the timer 
start=$(date +%s)
######################################  
####### Defining parameter values #######
######################################
# Define the window sizes in base pairs
window_size_bp=100000  # 100kB as window size
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
HOME=/home/jonathan
cd $HOME
######################################  
####### Defining the input files #######
######################################  
# Defining the path to the 100kbp window files for the dog autosome
preprocessed_data_dir=$HOME/data/preprocessed
#�������������
#� Empirical �
#�������������
preprocessed_german_shepherd_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
german_shepherd_autosome_lengths_file=$preprocessed_german_shepherd_dir/german_shepherd_filtered_autosome_lengths_and_marker_density.tsv
######################################  
####### Defining the output files #######
######################################  
window_files_dir=$preprocessed_data_dir/empirical/genomic_window_files
mkdir -p $window_files_dir
#�������������
#� Empirical �
#�������������
german_shepherd_output_window_file=$window_files_dir/german_shepherd_autosome_windows_100kB_window_sizes.bed

# Remove the existing output file if it exists
if [ -e "$german_shepherd_output_window_file" ]; then
    rm "$german_shepherd_output_window_file"
fi


#���������������������
#� 100kbp window files based on�
#� the canine reference assembly�
#� UU_Cfam_GSD_1.0          �
#���������������������
canine_reference_assembly_output_window_file=$window_files_dir/canine_reference_assembly_autosome_windows_100kB_window_sizes.bed

# Remove the existing output file if it exists
if [ -e "$canine_reference_assembly_output_window_file" ]; then
    rm "$canine_reference_assembly_output_window_file"
fi

###############################################################################################  
# RESULTS
############################################################################################### 
#�������������
#� Empirical window file �
#�������������
# Write the header to the output file
echo -e "#Chromosome\tStart\tEnd" > $german_shepherd_output_window_file
# Read the input file $german_shepherd_autosome_lengths_file line by line, skipping the first line
sed 1d "$german_shepherd_autosome_lengths_file" | while IFS=$'\t' read -r line; do
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
        echo -e "$chrom\t$window_start\t$window_end" >> "$german_shepherd_output_window_file"
        # Move to the next window position
        ((window_start += window_size_bp))
    done
done

# Sort the output file by genomic coordinates
sort -k1,1n -k2,2n -o "$german_shepherd_output_window_file" "$german_shepherd_output_window_file"

echo "Window file written to $german_shepherd_output_window_file"
#���������������������
#� 100kbp window files based on�
#� the canine reference assembly�
#� UU_Cfam_GSD_1.0          �
#���������������������
# Write the header to the output file
echo -e "#Chromosome\tStart\tEnd" > "$canine_reference_assembly_output_window_file"
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
        echo -e "$chrom\t$window_start\t$window_end" >> "$canine_reference_assembly_output_window_file"
        # Move to the next window position
        ((window_start += window_size_bp))
    done
done

# Sort the output file by genomic coordinates
sort -k1,1n -k2,2n -o "$canine_reference_assembly_output_window_file" "$canine_reference_assembly_output_window_file"
echo "Window file written to $canine_reference_assembly_output_window_file"
# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))s
echo "Genomic window files successfully created"
echo "Total Runtime: $runtime seconds"
