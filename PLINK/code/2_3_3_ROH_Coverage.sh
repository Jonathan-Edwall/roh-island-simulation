
#!/bin/bash -l

# Start the timer 
start=$(date +%s)

# Change working directory
HOME=/home/jonathan

cd $HOME


# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate bedtools
# /home/martin/anaconda3/envs/bedtools/bin/bedtools --version: bedtools v2.30.0  

# bedtools coverage -h  # Documentation about the merge function

echo "conda activated?"

# Defining path to the output directory of PLINK-files
plink_output_dir=$HOME/results/PLINK
german_shepherd_plink_output_dir=$plink_output_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

# Defining path to the output directory of bedtools-files
bedtools_output_dir=$HOME/results/Bedtools

#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
# Defining the input files.
# Example input-file:   & merged_roh_regions.bed
#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

# Defining path to input directory of Individual ROH-files (bed format)

individual_merged_overlapping_rohs_dir=$german_shepherd_plink_output_dir/individual_roh/bed_format
#individual_merged_overlapping_rohs_dir=$german_shepherd_plink_output_dir/small_scale_individual_roh_20_ind/bed_format

# Defining path to the population-scale ROH-file with overlapping regions merged (bed format)

german_shepherd_bedtools_output_dir=$bedtools_output_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813
merged_roh_regions_dir=$german_shepherd_bedtools_output_dir/merged

#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
# Defining the output files.
# Example output-file: 
#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

# Defining path to the output directory

coverage_output_dir=$german_shepherd_bedtools_output_dir/coverage/all_autosomes_100kb_window_size
#coverage_output_dir=$german_shepherd_bedtools_output_dir/coverage/small_scale_individual_roh_20_ind/reverse_test

# Creating a directory to store the output files in, if it does not already exist.
mkdir -p $coverage_output_dir


#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
# Function: bedtools coverage
#
# Calculating the population-based frequency of ROH-segments
#
###Input:
# Individual ROH:  /home/jonathan/results/PLINK/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813/individual_roh/bed_format 
# Merged ROH regions: /home/jonathan/results/Bedtools/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813/merged
# 
###Output:
# /home/jonathan/results/Bedtools/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813/coverage
#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい



## Running coverage command for every individual to count to which roh-segments an individuals maps to.
#for indv_roh_file in $individual_merged_overlapping_rohs_dir/*.bed; do
#    individual_id=$(basename "$indv_roh_file" .bed | sed 's/_ROH//') # Extracting individual ID from the file name
#    output_file="$coverage_output_dir/${individual_id}_ROH_coverage.bed"       
#    
#    # Run bedtools coverage-function 
#    # Process substitution is used on the individual ROH-files to remove their headers and to make only columns 1 to 3 be processed (chr,pos1,pos2)   
#    bedtools coverage\
#    -a $merged_roh_regions_dir/all_autosomes_windows_100kB_window_sizes.bed\
#    -b <(tail -n +2 "$indv_roh_file")\
#    -counts\
#    > "$output_file"    
#        
#    
#done

#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
#
# Calculating population ROH frequency
# 
###Input:
# Individual ROH-window-count:  /home/jonathan/results/PLINK/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813/individual_roh/bed_format 
# 
###Output:
# /home/jonathan/results/Bedtools/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813/coverage/all_autosomes_100kb_window_size/sorted_population_coverage.bed
#いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい



final_results_dir=$coverage_output_dir/results
# Creating a directory to store the output files in, if it does not already exist.
mkdir -p $final_results_dir

# Count the number of individual bed files
num_individuals=$(find $coverage_output_dir -maxdepth 1 -type f -name "*.bed" | wc -l)

# Calculate the sum of counts for each window and add frequency column
awk -v num_indiv="$num_individuals" '{a[$1"\t"$2"\t"$3]+=$4} END {for (i in a) print i "\t" a[i] "\t" a[i]/num_indiv}' $coverage_output_dir/*.bed > $final_results_dir/population_coverage.bed


# Sort the population_coverage.bed file based on genomic coordinates#sort -k1,1 -k2,2n $final_results_dir/population_coverage.bed > $final_results_dir/sorted_population_coverage.bed
sort -k1,1V -k2,2n ${final_results_dir}/population_coverage.bed > ${final_results_dir}/sorted_population_coverage.bed





# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Counting window frequency of roh-segments on a population level"
echo "Outputfiles are stored in: $coverage_output_dir"
echo "Runtime: $runtime seconds"