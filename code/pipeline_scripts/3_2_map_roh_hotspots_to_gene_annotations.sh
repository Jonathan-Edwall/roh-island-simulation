
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)


# Activate conda environment
# conda_env_full_path="/home/martin/anaconda3/etc/profile.d/conda.sh"
source $conda_env_full_path  # Source Conda initialization script
conda activate bedtools
# # /home/martin/anaconda3/envs/bedtools/bin/bedtools --version: bedtools v2.30.0  

# # bedtools intersect -h  # Documentation about the merge function

# wait 
# empirical_dog_breed=labrador_retriever # Defined in run_pipeline.sh

####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME

####################################  
# Defining the input files
#################################### 

# Defining the path to the annotation file
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
preprocessed_data_dir=$data_dir/preprocessed
preprocessed_dog_gene_annotations_file_dir=$preprocessed_data_dir/empirical/dog_gene_annotations

# results_dir=$HOME/results # Variable Defined in run_pipeline.sh
ROH_hotspots_results_dir=$results_dir/ROH-Hotspots
empirical_breed_roh_hotspots_dir=$ROH_hotspots_results_dir/empirical/$empirical_dog_breed

echo "ROH hotspot directory: $empirical_breed_roh_hotspots_dir"

#$empirical_breed_roh_hotspots_dir/chr17_ROH_Hotspot_windows.bed

#################################### 
# Defining the output dirs
#################################### 

# gene_mapping_output_dir=$empirical_breed_roh_hotspots_dir/hotspot_gene_mapping
# gene_mapping_output_dir=$empirical_breed_roh_hotspots_dir/hotspot_gene_mapping_ROS_Cfam_1_0
gene_mapping_output_dir=$empirical_breed_roh_hotspots_dir/hotspot_gene_mapping
echo "ROH hotspot directory: $gene_mapping_output_dir"

# Creating a directory to store the .BED-files in, if it does not already exist.
mkdir -p $gene_mapping_output_dir

#����������������������������������������������������������������������������
# Function: bedtools intersect
#
###Input:
# 
###Output:
#����������������������������������������������������������������������������

#phenotype_file=$preprocessed_phenotype_file_dir/ALL_dog_phenotypes.bed
#phenotype_file=$preprocessed_phenotype_file_dir/ALL_phenotypes_empirical_breed.bed
# phenotype_file=$preprocessed_phenotype_file_dir/all_non_defect_phenotypes_any_breed.bed
#phenotype_file=$preprocessed_phenotype_file_dir/all_non_defect_phenotypes_empirical_breed.bed

# compressed_gene_annotations_file=$preprocessed_dog_gene_annotations_file_dir/ncbiRefSeq.gtf.gz
# canfam_reference_genome=True
compressed_gene_annotations_file=$preprocessed_dog_gene_annotations_file_dir/canFam3.ncbiRefSeq.gtf.gz
canfam_reference_genome=True
# compressed_gene_annotations_file=$preprocessed_dog_gene_annotations_file_dir/Canis_lupus_familiaris.ROS_Cfam_1.0.112.gtf.gz
# canfam_reference_genome=False


# Uncompress the GTF file if it hasn't been uncompressed already
uncompressed_gene_annotations_file=${compressed_gene_annotations_file%.gz}
if [ ! -f "$uncompressed_gene_annotations_file" ]; then
    echo "Unzipping $compressed_gene_annotations_file"
    gunzip -k "$compressed_gene_annotations_file"
fi
# uncompressed_gene_annotations_file=${compressed_gene_annotations_file%.gz}
# uncompressed_gene_annotations_file=$preprocessed_dog_gene_annotations_file_dir/transcripts_temp.gtf
# uncompressed_gene_annotations_file=$preprocessed_dog_gene_annotations_file_dir/canFam3.ncbiRefSeq.gtf

# uncompressed_gene_annotations_file=$preprocessed_dog_gene_annotations_file_dir/Canis_lupus_familiaris.ROS_Cfam_1.0.112.gtf


if [ $canfam_reference_genome = True ]; then
    # Create a temporary file with only transcript entries
    # grep -P "\ttranscript\t" "$uncompressed_gene_annotations_file" > "$temp_transcript_file"
    temp_transcript_file="${preprocessed_dog_gene_annotations_file_dir}/transcripts_temp.gtf"    

    # sed 's/^chr//' $uncompressed_gene_annotations_file > $temp_transcript_file
    # awk '{if($1 ~ /^chr/) $1 = substr($1, 4); print}' "$uncompressed_gene_annotations_file" > "$temp_transcript_file"
    awk '$3 == "transcript" {if($1 ~ /^chr/) $1 = substr($1, 4); print $0}' OFS="\t" "$uncompressed_gene_annotations_file" > "$temp_transcript_file"
    # awk  "$uncompressed_gene_annotations_file" | head



    # Running intersect command for every chromosome ROH-hotspot file.
    for roh_hotspot_file in $empirical_breed_roh_hotspots_dir/*.bed; do
        # echo "i do get here, correct?"
        # echo "Processing file: $roh_hotspot_file"
        prefix=$(basename "$roh_hotspot_file" .bed) # Extracting basename without the .bed extension
        output_file="${gene_mapping_output_dir}/${prefix}_gene_mapping.txt"
        output_transcript_file="${gene_mapping_output_dir}/${prefix}_transcripts.txt"
        output_gene_names_file="${gene_mapping_output_dir}/${prefix}_gene_names.txt"

        # Run bedtools intersect-function        
        bedtools intersect \
        -wa \
        -a "$temp_transcript_file" \
        -b "$roh_hotspot_file" \
        > "$output_file"

        # Extract transcripts and gene names
        awk '$3 == "transcript"' "$output_file" > "$output_transcript_file"
        awk '$3 == "transcript" {print $13}' "$output_file" | uniq > "$output_gene_names_file"

    done

    # Remove the temporary files after processing
    rm "$temp_transcript_file"
else
    # Running intersect command for every chromosome ROH-hotspot file.
    for roh_hotspot_file in $empirical_breed_roh_hotspots_dir/*.bed; do
        echo "should never get here"
        echo "Processing file: $roh_hotspot_file"
        prefix=$(basename "$roh_hotspot_file" .bed) # Extracting basename without the .bed extension
        output_file="${gene_mapping_output_dir}/${prefix}_gene_mapping.txt" 
        output_transcript_file="${gene_mapping_output_dir}/${prefix}_transcripts.txt" 
        output_gene_names_file="${gene_mapping_output_dir}/${prefix}_gene_names.txt" 

        # Run bedtools intersect-function        
        bedtools intersect \
        -wa \
        -a "$uncompressed_gene_annotations_file" \
        -b "$roh_hotspot_file" \
        > "$output_file"    

        awk '$3 == "transcript"' $output_file > $output_transcript_file

        awk '$3 == "transcript" {print $10}' $output_file | uniq > $output_gene_names_file

    done

fi


# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo " Mapping of ROH-hotspots to genes completed"
echo "The outputfiles are stored in: $gene_mapping_output_dir"
echo "Runtime: $script_runtime seconds"