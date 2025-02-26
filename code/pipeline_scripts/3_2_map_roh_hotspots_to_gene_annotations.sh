
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

# empirical_breed=labrador_retriever # Defined in run_pipeline.sh

####################################  
# Defining the working directory
#################################### 

# HOME=/home/jonathan
cd $HOME

####################################  
# Defining the input files
#################################### 

# Defining the path to the gene annotation file
# gene_annotations_filepath # Variable Defined in run_pipeline.sh
gene_annotations_dir=$(dirname "$gene_annotations_filepath")

# results_dir=$HOME/results # Variable Defined in run_pipeline.sh
ROH_hotspots_results_dir=$results_dir/ROH-Hotspots
empirical_breed_roh_hotspots_dir=$ROH_hotspots_results_dir/empirical/$empirical_breed

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

#!/bin/bash

# Determine if the file is compressed and set the correct filename
if [[ "$gene_annotations_filepath" == *.gz ]]; then
    uncompressed_gene_annotations_file="${gene_annotations_filepath%.gz}"
    if [ ! -f "$uncompressed_gene_annotations_file" ]; then
        echo "Unzipping $gene_annotations_filepath"
        gunzip -k "$gene_annotations_filepath"
    fi
else
    uncompressed_gene_annotations_file="$gene_annotations_filepath"
fi

# Define temp transcript file
temp_transcript_file="${gene_annotations_dir}/transcripts_temp.gtf"

# Process GTF file to extract transcript entries and remove 'chr' prefix
awk '$3 == "transcript" {if($1 ~ /^chr/) $1 = substr($1, 4); print $0}' OFS="\t" "$uncompressed_gene_annotations_file" > "$temp_transcript_file"

# Iterate through all ROH-hotspot files and run intersect
for roh_hotspot_file in "$empirical_breed_roh_hotspots_dir"/*.bed; do
    prefix=$(basename "$roh_hotspot_file" .bed)
    output_file="${gene_mapping_output_dir}/${prefix}_gene_mapping.txt"
    output_transcript_file="${gene_mapping_output_dir}/${prefix}_transcripts.txt"
    output_gene_names_file="${gene_mapping_output_dir}/${prefix}_gene_names.txt"

    # Run bedtools intersect function        
    bedtools intersect -wa -a "$temp_transcript_file" -b "$roh_hotspot_file" > "$output_file"

    # Extract transcripts and gene names
    awk '$3 == "transcript"' "$output_file" > "$output_transcript_file"
    awk '$3 == "transcript" {print $13}' "$output_file" | uniq > "$output_gene_names_file"
done

# Remove the temporary files after processing
rm "$temp_transcript_file"


# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo " Mapping of ROH-hotspots to genes completed"
echo "The outputfiles are stored in: $gene_mapping_output_dir"
echo "Runtime: $script_runtime seconds"