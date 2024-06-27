
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate bedtools
# /home/martin/anaconda3/envs/bedtools/bin/bedtools --version: bedtools v2.30.0  
# bedtools coverage -h  # Documentation about the merge function

######################################  
####### Defining parameter values #######
######################################
overlap_fraction=1.0 # 100 % of the genomic 100k bp-window ("a-file") needs to be overlapping with the roh-segment ("b-file") 
# $n_individuals_breed_formation is imported from run_pipeline.sh! (the main script)

# Hardcoding the number of individual within a simulated population, to calculate the ROH-frequency correctly.
# This is required since not all individuals might have ROH-segments resulting in that the number of individual ROH-files and the amount of individuals in the population could differ

# chr_simulated # Imported from run_pipeline.sh
simulated_chr_number=$(echo $chr_simulated | grep -o '[0-9]\+')

# Defining the header of the output file
header="#CHR\tPOS1\tPOS2\tCOUNT\tFREQUENCY"

# # Boolean value to determine whether to run the selection simulation code
# selection_simulation=TRUE # Defined in run_pipeline.sh

######################################  
####### Defining the working directory #######
######################################
HOME=/home/jonathan
cd $HOME

######################################  
####### Defining the input files #######
######################################  
# Defining input directory of the ROH-files
# results_dir=$HOME/results # Variable Defined in run_pipeline.sh
plink_results_dir=$results_dir/PLINK/ROH
simulated_plink_dir=$plink_results_dir/simulated



#�����������������
#�100kbp window files of�
#� the dog autosome   �
#�����������������
# Defining the path to the 100kbp window files for the dog autosome
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
preprocessed_data_dir=$data_dir/preprocessed
window_files_dir=$preprocessed_data_dir/empirical/genomic_window_files

#���������������
#� Empirical ROH-data �
#���������������
# empirical_dog_breed="empirical_breed" # Defined in run_pipeline.sh
empirical_breed_pop_hom_file_dir=$plink_results_dir/empirical/$empirical_dog_breed
# Defining path to input directory of Individual ROH-files (bed format)
empirical_breed_indv_bed_files_dir=$empirical_breed_pop_hom_file_dir/individual_ROH/bed_format

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
bedtools_results_dir=$results_dir/Bedtools/coverage

#�������������
#� Empirical �
#�������������
coverage_output_empirical_breed_dir=$bedtools_results_dir/empirical/$empirical_dog_breed
# Creating a directory to store the output files in, if it does not already exist.
mkdir -p $coverage_output_empirical_breed_dir

# Defining the directory where the ROH-frequency results for the german shepherd "population" will be stored
roh_frequencies_empirical_breed_dir=$coverage_output_empirical_breed_dir/pop_roh_freq
# Creating a directory to store the output files in, if it does not already exist.
mkdir -p $roh_frequencies_empirical_breed_dir


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

# To enhance the performance and reduce memory, a temporary window file is created only containing windows for the simulated chromosome.
temp_window_file="$window_files_dir/temp_canine_reference_assembly_simulated_chr_100kB_window_sizes.bed"
awk -v chr="$simulated_chr_number" 'NR == 1 || $1 == chr' "$window_files_dir/canine_reference_assembly_autosome_windows_100kB_window_sizes.bed" > $temp_window_file

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
if [ "$empirical_processing" = TRUE ]; then
    # Running coverage command for every individual to count to which roh-segments an individuals maps to.
    for indv_roh_file in $empirical_breed_indv_bed_files_dir/*.bed; do
        basename_part=$(basename "${indv_roh_file%.*}") # Extracting basename part without extension
        output_file="$coverage_output_empirical_breed_dir/${basename_part}_coverage.bed"       

        # Run bedtools coverage-function 
        # Process substitution is used on the individual ROH-files to remove their headers and to make only columns 1 to 3 be processed (chr,pos1,pos2)   
        bedtools coverage \
        -a "$window_files_dir/${empirical_dog_breed}_autosome_windows_100kB_window_sizes.bed" \
        -b <(tail -n +2 "$indv_roh_file") \
        -counts \
        -f $overlap_fraction \
        > "$output_file"    

    done
else
    echo "Empirical data has been set to not be processed, since files have already been created."
fi



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
    -a $temp_window_file \
    -b <(tail -n +2 "$indv_roh_file") \
    -counts \
    -f $overlap_fraction \
    > "$output_file" 


    
    # # Run bedtools coverage-function 
    # # Process substitution is used on the individual ROH-files to remove their headers and to make only columns 1 to 3 be processed (chr,pos1,pos2)   
    # bedtools coverage \
    # -a "$window_files_dir/canine_reference_assembly_autosome_windows_100kB_window_sizes.bed" \
    # -b <(tail -n +2 "$indv_roh_file") \
    # -counts \
    # -f $overlap_fraction \
    # > "$output_file" 
done

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

if [ "$selection_simulation" = TRUE ]; then
    # Running coverage command for every individual to count to which roh-segments an individual maps.
    for indv_roh_file in $selection_model_indv_bed_files_dir/*.bed; do
        basename_part=$(basename "${indv_roh_file%.*}") # Extracting the basename part 
        output_file="$coverage_output_selection_model_dir/${basename_part}_coverage.bed" 


        # Run bedtools coverage-function 
        # Process substitution is used on the individual ROH-files to remove their headers and to make only columns 1 to 3 be processed (chr,pos1,pos2)   
        bedtools coverage \
        -a $temp_window_file \
        -b <(tail -n +2 "$indv_roh_file") \
        -counts \
        -f $overlap_fraction \
        > "$output_file" 


        
        # # # Run bedtools coverage-function 
        # # # Process substitution is used on the individual ROH-files to remove their headers and to make only columns 1 to 3 be processed (chr,pos1,pos2)   
        # # bedtools coverage \
        # # -a "$window_files_dir/canine_reference_assembly_autosome_windows_100kB_window_sizes.bed" \
        # # -b <(tail -n +2 "$indv_roh_file") \
        # # -counts \
        # # -f $overlap_fraction \
        # # > "$output_file" 

        
        # # Run bedtools coverage-function 
        # # Process substitution is used on the individual ROH-files to remove their headers and to make only columns 1 to 3 be processed (chr,pos1,pos2)   
        # bedtools coverage \
        # -a "$window_files_dir/canine_reference_assembly_autosome_windows_100kB_window_sizes.bed" \
        # -b <(tail -n +2 "$indv_roh_file") \
        # -counts \
        # -f $overlap_fraction \
        # > "$output_file" 
    done

else
    echo "Selection simulation is set to FALSE. Skipping the selection model processing."
fi


# Clean up the temp window file after use
rm $temp_window_file

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#
# Calculating population ROH frequency
# 
###Input:
# Individual ROH-window-count:  /home/jonathan/results/PLINK/empirical/$empirical_dog_breed/individual_roh/bed_format 
# 
###Output:
# /home/jonathan/results/Bedtools/empirical/$empirical_dog_breed/coverage/all_autosomes_100kb_window_size/sorted_population_coverage.bed
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Empirical Data  ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
if [ "$empirical_processing" = TRUE ]; then
    # # Count the number of individual bed files
    # num_individuals_empirical=$(find $coverage_output_empirical_breed_dir -maxdepth 1 -type f -name "*.bed" | wc -l)


    # Extract unique simulation prefixes
    datasets_prefixes=$(find "$coverage_output_empirical_breed_dir" -maxdepth 1 -type f -name "*_ROH_IID_*_coverage.bed" | sed 's/.*\/\([^/]*\)_ROH_IID_[0-9]*_.*\.bed/\1/' | sort -u)

    # Iterate over each simulation (unique simulation prefix)
    for prefix in $datasets_prefixes; do
        # Remove existing frequency file if it already exists for the simulation!
        rm -f "${roh_frequencies_empirical_breed_dir}/${prefix}_ROH_freq.bed"
        
        # Filter files belonging to the current simulation prefix
        dataset_files=$(find "$coverage_output_empirical_breed_dir" -maxdepth 1 -type f -name "${prefix}_ROH_IID_*_coverage.bed")
        
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
        > "${roh_frequencies_empirical_breed_dir}/${prefix}_ROH_freq.bed"
    done

    echo "Population level ROH-Window-frequencies computed for the empirical data"
    echo "The Output file(s) is stored in: ${roh_frequencies_empirical_breed_dir}"
else
    echo ""
fi


#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

echo "coverage_output_neutral_model_dir: ${coverage_output_neutral_model_dir}"

# Extract unique simulation prefixes
# sort -u extracts unique prefixes, in an alphabetical order
simulation_prefixes_neutral_model=$(ls $coverage_output_neutral_model_dir/*_ROH_IID_*_coverage.bed | sed 's/.*\/\([^/]*\)_ROH_IID_[0-9]*_.*\.bed/\1/' | sort -u)

# Iterate over each simulation (unique simulation prefix)
for prefix in $simulation_prefixes_neutral_model; do
    # Remove existing frequency file if it already exists for the simulation!
    rm -f "${roh_frequencies_neutral_model_dir}/${prefix}_ROH_freq.bed"


    # Filter files belonging to the current simulation prefix
    simulation_files="$coverage_output_neutral_model_dir/${prefix}_ROH*"
    #
    # Using awk to calculate the sum of counts for each window and add a frequency column. 
    # Then the file is sorted by genomic coordinates
    awk -v num_indiv="$n_individuals_breed_formation" -v header="$header" '{
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

if [ "$selection_simulation" = TRUE ]; then
    echo "coverage_output_selection_model_dir: ${coverage_output_selection_model_dir}"

    # Extract unique simulation prefixes
    # sort -u extracts unique prefixes, in an alphabetical order
    simulation_prefixes_selection_model=$(find "$coverage_output_selection_model_dir" -name "*_ROH_IID_*_coverage.bed" -exec basename {} \; | sed 's/_ROH_IID_[0-9]*_coverage\.bed//' | sort -Vu)

    # Iterate over each simulation (unique simulation prefix)
    for prefix in $simulation_prefixes_selection_model; do
        # Remove existing frequency file if it already exists for the simulation!
        rm -f "${roh_frequencies_selection_model_dir}/${prefix}_ROH_freq.bed"
        
        # Find files belonging to the current simulation prefix
        simulation_files=$(find "$coverage_output_selection_model_dir" -name "${prefix}_ROH*")

        # Using awk to calculate the sum of counts for each window and add a frequency column. 
        # Then the file is sorted by genomic coordinates
        awk -v num_indiv="$n_individuals_breed_formation" -v header="$header" '{
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
else
    echo ""
fi



# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))




echo "Runtime: $script_runtime seconds"