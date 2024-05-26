
#!/bin/bash -l

# Start the timer 
start=$(date +%s)

# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate bedtools
# /home/martin/anaconda3/envs/bedtools/bin/bedtools --version: bedtools v2.30.0  
# bedtools coverage -h  # Documentation about the merge function

######################################  
####### Defining parameter values #######
######################################
overlap_fraction=1.0 # 100 % of the genomic 100k bp-window ("a-file") needs to be overlapping with the roh-segment ("b-file") 



# Hardcoding the number of individual within a simulated population, to calculate the ROH-frequency correctly.
# This is required since not all individuals might have ROH-segments resulting in that the number of individual ROH-files and the amount of individuals in the population could differ
num_individuals_simulation=50 
# Defining the header of the output file
header="#CHR\tPOS1\tPOS2\tCOUNT\tFREQUENCY"

######################################  
####### Defining the working directory #######
######################################
HOME=/home/jonathan
cd $HOME

######################################  
####### Defining the input files #######
######################################  
# Defining input directory of the ROH-files
plink_results_dir=$HOME/results/PLINK/ROH
simulated_plink_dir=$plink_results_dir/simulated



#�����������������
#�100kbp window files of�
#� the dog autosome   �
#�����������������
# Defining the path to the 100kbp window files for the dog autosome
preprocessed_data_dir=$HOME/data/preprocessed
window_files_dir=$preprocessed_data_dir/empirical/genomic_window_files

#���������������
#� Empirical ROH-data �
#���������������
german_shepherd_pop_hom_file_dir=$plink_results_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
# Defining path to input directory of Individual ROH-files (bed format)
german_shepherd_indv_bed_files_dir=$german_shepherd_pop_hom_file_dir/individual_ROH/bed_format

#���������������
#� Simulated ROH-data � 
#���������������

##### Neutral Model #####
neutral_model_pop_hom_file_dir=$simulated_plink_dir/neutral_model
neutral_model_indv_bed_files_dir=$neutral_model_pop_hom_file_dir/individual_ROH/bed_format
##### Selection Model ##### 
selection_model_pop_hom_file_dir=$simulated_plink_dir/selection_model
selection_model_indv_bed_files_dir=$selection_model_pop_hom_file_dir/individual_ROH/bed_format

######################################  
####### Defining the output files #######
######################################  
bedtools_results_dir=$HOME/results/Bedtools/coverage

#�������������
#� Empirical �
#�������������
coverage_output_german_shepherd_dir=$bedtools_results_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
# Creating a directory to store the output files in, if it does not already exist.
mkdir -p $coverage_output_german_shepherd_dir

# Defining the directory where the ROH-frequency results for the german shepherd "population" will be stored
roh_frequencies_german_shepherd_dir=$coverage_output_german_shepherd_dir/pop_roh_freq
# Creating a directory to store the output files in, if it does not already exist.
mkdir -p $roh_frequencies_german_shepherd_dir


#�������������
#� Simulated � 
#�������������
simulated_bedtools_dir=$bedtools_results_dir/simulated

##### Neutral Model #####
coverage_output_neutral_model_dir=$simulated_bedtools_dir/neutral_model
# coverage_output_neutral_model_dir=$simulated_bedtools_dir/neutral_model/autosomes_100kb_window_size
mkdir -p $coverage_output_neutral_model_dir

# Defining the directory where the ROH-frequency results for each simulated population will be stored
roh_frequencies_neutral_model_dir=$coverage_output_neutral_model_dir/pop_roh_freq
# Creating a directory to store the output files in, if it does not already exist.
mkdir -p $roh_frequencies_neutral_model_dir


##### Selection Model ##### 

coverage_output_selection_model_dir=$simulated_bedtools_dir/selection_model
# coverage_output_selection_model_dir=$simulated_bedtools_dir/selection_model/autosomes_100kb_window_size
mkdir -p $coverage_output_selection_model_dir

# Defining the directory where the ROH-frequency results for each simulated population will be stored
roh_frequencies_selection_model_dir=$coverage_output_selection_model_dir/pop_roh_freq
# Creating a directory to store the output files in, if it does not already exist.
mkdir -p $roh_frequencies_selection_model_dir


###############################################################################################  
############# RESULTS ###########################################################################
############################################################################################### 


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Function: bedtools coverage
#
# Calculating the population-based frequency of ROH-segments
#
###Input:
# Individual ROH files in .bed-format 
# 100k bp dog autosome window-files 
# 
###Output:
# Coverage file for each individual, mapped to the window file
# Population ROH-frequency file for the 100kbp bp windows, found in ./pop_roh_freq
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Empirical Data (German Shepherd) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Running coverage command for every individual to count to which roh-segments an individuals maps to.
for indv_roh_file in $german_shepherd_indv_bed_files_dir/*.bed; do
    basename_part=$(basename "${indv_roh_file%.*}") # Extracting basename part without extension
    output_file="$coverage_output_german_shepherd_dir/${basename_part}_coverage.bed"       

    # Run bedtools coverage-function 
    # Process substitution is used on the individual ROH-files to remove their headers and to make only columns 1 to 3 be processed (chr,pos1,pos2)   
    bedtools coverage \
    -a "$window_files_dir/german_shepherd_autosome_windows_100kB_window_sizes.bed" \
    -b <(tail -n +2 "$indv_roh_file") \
    -counts \
    -f $overlap_fraction \
    > "$output_file"    

done


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Running coverage command for every individual to count to which roh-segments an individual maps.
for indv_roh_file in $neutral_model_indv_bed_files_dir/*.bed; do
    basename_part=$(basename "${indv_roh_file%.*}") # Extracting the basename part 
    output_file="$coverage_output_neutral_model_dir/${basename_part}_coverage.bed" 
    
    # Run bedtools coverage-function 
    # Process substitution is used on the individual ROH-files to remove their headers and to make only columns 1 to 3 be processed (chr,pos1,pos2)   
    bedtools coverage \
    -a "$window_files_dir/canine_reference_assembly_autosome_windows_100kB_window_sizes.bed" \
    -b <(tail -n +2 "$indv_roh_file") \
    -counts \
    -f $overlap_fraction \
    > "$output_file" 
done


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Running coverage command for every individual to count to which roh-segments an individual maps.
for indv_roh_file in $selection_model_indv_bed_files_dir/*.bed; do
    basename_part=$(basename "${indv_roh_file%.*}") # Extracting the basename part 
    output_file="$coverage_output_selection_model_dir/${basename_part}_coverage.bed" 
    
    # Run bedtools coverage-function 
    # Process substitution is used on the individual ROH-files to remove their headers and to make only columns 1 to 3 be processed (chr,pos1,pos2)   
    bedtools coverage \
    -a "$window_files_dir/canine_reference_assembly_autosome_windows_100kB_window_sizes.bed" \
    -b <(tail -n +2 "$indv_roh_file") \
    -counts \
    -f $overlap_fraction \
    > "$output_file" 
done



#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#
# Calculating population ROH frequency
# 
###Input:
# Individual ROH-window-count:  /home/jonathan/results/PLINK/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813/individual_roh/bed_format 
# 
###Output:
# /home/jonathan/results/Bedtools/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813/coverage/all_autosomes_100kb_window_size/sorted_population_coverage.bed
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Empirical Data (German Shepherd) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Count the number of individual bed files
num_individuals_empirical=$(find $coverage_output_german_shepherd_dir -maxdepth 1 -type f -name "*.bed" | wc -l)


# Extract unique simulation prefixes
datasets_prefixes=$(find "$coverage_output_german_shepherd_dir" -maxdepth 1 -type f -name "*_ROH_IID_*_coverage.bed" | sed 's/.*\/\([^/]*\)_ROH_IID_[0-9]*_.*\.bed/\1/' | sort -u)

# Iterate over each simulation (unique simulation prefix)
for prefix in $datasets_prefixes; do
    # Remove existing frequency file if it already exists for the simulation!
    rm -f "${roh_frequencies_german_shepherd_dir}/${prefix}_ROH_freq.bed"
    
    # Filter files belonging to the current simulation prefix
    dataset_files=$(find "$coverage_output_german_shepherd_dir" -maxdepth 1 -type f -name "${prefix}_ROH_IID_*_coverage.bed")
    
    # Calculate the number of individuals
    num_indiv_empirical_dataset=$(echo "$dataset_files" | wc -l)
    echo "Dataset: ${prefix} \t Individuals: ${num_indiv_empirical_dataset}"

    # Calculate the sum of counts for each window and add frequency column
    awk -v num_indiv="$num_indiv_empirical_dataset" -v header="$header" '
        { window_counts[$1"\t"$2"\t"$3] += $4 } 
    END{

    for (i in window_counts) {
        frequency = window_counts[i] / num_indiv
        print i "\t" window_counts[i] "\t" frequency
                             }
    } ' \
    $dataset_files | sed '1i'"$header" | sort -k1,1n -k2,2n \
    > "${roh_frequencies_german_shepherd_dir}/${prefix}_ROH_freq.bed"
done

echo "Population level ROH-Window-frequencies computed for the empirical data"
echo "The Output file(s) is stored in: ${roh_frequencies_german_shepherd_dir}"


        




#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

echo "coverage_output_neutral_model_dir: ${coverage_output_neutral_model_dir}"

# Extract unique simulation prefixes
# sort -u extracts unique prefixes, in an alphabetical order
simulation_prefixes=$(ls $coverage_output_neutral_model_dir/*_ROH_IID_*_coverage.bed | sed 's/.*\/\([^/]*\)_ROH_IID_[0-9]*_.*\.bed/\1/' | sort -u)

# Iterate over each simulation (unique simulation prefix)
for prefix in $simulation_prefixes; do
    # Remove existing frequency file if it already exists for the simulation!
    rm -f "${roh_frequencies_neutral_model_dir}/${prefix}_ROH_freq.bed"


    # Filter files belonging to the current simulation prefix
    simulation_files="$coverage_output_neutral_model_dir/${prefix}_ROH*"
    #
    # Using awk to calculate the sum of counts for each window and add a frequency column. 
    # Then the file is sorted by genomic coordinates
    awk -v num_indiv="$num_individuals_simulation" -v header="$header" '{
        window_counts[$1"\t"$2"\t"$3]+=$4
    } 
    END {

        for (i in window_counts) {
            frequency = window_counts[i] / num_indiv
            print i "\t" window_counts[i] "\t" frequency
        }
    }' \
    $simulation_files | sed '1i'"$header" | sort -k1,1n -k2,2n \
    > "${roh_frequencies_neutral_model_dir}/${prefix}_ROH_freq.bed"   
      
    echo "Population level ROH-Window-frequencies computed for simulation $prefix"

done



echo "Population level ROH-Window-frequencies computed for the neutral model simulations"
echo "Output files stored in: ${roh_frequencies_neutral_model_dir}"


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

echo "coverage_output_selection_model_dir: ${coverage_output_selection_model_dir}"

# Extract unique simulation prefixes
# sort -u extracts unique prefixes, in an alphabetical order
simulation_prefixes=$(ls $coverage_output_selection_model_dir/*_ROH_IID_*_coverage.bed | sed 's/.*\/\([^/]*\)_ROH_IID_[0-9]*_.*\.bed/\1/' | sort -u)

# Iterate over each simulation (unique simulation prefix)
for prefix in $simulation_prefixes; do
    # Remove existing frequency file if it already exists for the simulation!
    rm -f "${roh_frequencies_selection_model_dir}/${prefix}_ROH_freq.bed"
    
    # Filter files belonging to the current simulation prefix
    simulation_files="$coverage_output_selection_model_dir/${prefix}_ROH*"
    
    # Using awk to calculate the sum of counts for each window and add a frequency column. 
    # Then the file is sorted by genomic coordinates
    awk -v num_indiv="$num_individuals_simulation" -v header="$header" '{
        window_counts[$1"\t"$2"\t"$3]+=$4
    } 
    END{
    for (i in window_counts) {
        frequency = window_counts[i] / num_indiv
        print i "\t" window_counts[i] "\t" frequency
                             }
    } ' \
    $simulation_files | sed '1i'"$header" | sort -k1,1n -k2,2n \
    > "${roh_frequencies_selection_model_dir}/${prefix}_ROH_freq.bed"   
      
    echo "Population level ROH-Window-frequencies computed for simulation $prefix"

done



echo "Population level ROH-Window-frequencies computed for the selection model simulations"
echo "Output files stored in: ${roh_frequencies_selection_model_dir}"



# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))




echo "Runtime: $runtime seconds"