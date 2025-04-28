
#!/bin/bash -l

####################################  
# Defining the working directory
#################################### 

# HOME="/home/jonathan/pipeline/Computational-modelling-of-genomic-inbreeding-and-roh-islands-in-extremely-small-populations"
HOME="$(dirname "$(dirname "$(realpath "$0")")")"
script_dir="$HOME/code"

# -------------[ Load Configuration ]-------------
CONFIG_FILE="$script_dir/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    echo -e "${GREEN}[INFO]${NC} Loading configuration from ${CONFIG_FILE}"
    source "$CONFIG_FILE"
else
    echo -e "${RED}[ERROR]${NC} Could not find config file at ${CONFIG_FILE}"
    exit 1
fi

######################################  
####### Defining parameter values #######
######################################
# Define the studied breed
# empirical_breed="labrador_retriever" # Variable defined in config.sh
input_data_dir="$HOME/data" 
input_results_dir="$HOME/results" 

HO_results_dir="$HOME/results_HO"
HO_data_dir="$HOME/data_HO" 


######################################  
####### Defining the INPUT files #######
######################################  
preprocessed_data_dir=preprocessed
preprocessed_empirical_breed_data_dir="${preprocessed_data_dir}/empirical/${empirical_breed}"

### ROH Hotspots
ROH_hotspots_dir=ROH-Hotspots

plink_ROH_dir=PLINK/ROH
expected_heterozygosity_dir_NO_MAF=expected_heterozygosity_No_MAF
expected_heterozygosity_dir_MAF_0_05=expected_heterozygosity_MAF_0_05
expected_heterozygosity_dir_MAF_0_01=expected_heterozygosity_MAF_0_01

### Window files
window_files_dir=$preprocessed_data_dir/empirical/genomic_window_files
empirical_dataset_window_file="${window_files_dir}/${empirical_breed}_autosome_windows_100kB_window_sizes.bed"

#�������������
#� Empirical �
#�������������
### ROH-Hotspot Threshold ###
Empirical_breed_ROH_hotspots_dir="${ROH_hotspots_dir}/empirical/${empirical_breed}"
### Inbreeding coefficient ###
Empirical_breed_F_ROH_dir=$plink_ROH_dir/empirical/$empirical_breed/F_ROH
### Expected Heterozygosity distribution ###
Empirical_breed_expected_heterozygosity_dir_NO_MAF=$expected_heterozygosity_dir_NO_MAF/empirical/$empirical_breed
Empirical_breed_expected_heterozygosity_dir_MAF_0_05=$expected_heterozygosity_dir_MAF_0_05/empirical/$empirical_breed
Empirical_breed_expected_heterozygosity_dir_MAF_0_01=$expected_heterozygosity_dir_MAF_0_01/empirical/$empirical_breed
##############################################################################################  
############ Copying the directories #################################################################
############################################################################################## 

###  Empirical preprocessed data ### 
mkdir -p "${HO_data_dir}/${preprocessed_empirical_breed_data_dir}"
cp -r "${input_data_dir}/${preprocessed_empirical_breed_data_dir}/." "${HO_data_dir}/${preprocessed_empirical_breed_data_dir}"

### Genomic Window File ###
mkdir -p "${HO_data_dir}/${window_files_dir}"
cp -r "${input_data_dir}/${window_files_dir}/${empirical_breed}_autosome_windows_100kB_window_sizes.bed" "${HO_data_dir}/${window_files_dir}/${empirical_breed}_autosome_windows_100kB_window_sizes.bed"

###  ROH-Hotspot Threshold ### 
mkdir -p "${HO_results_dir}/${Empirical_breed_ROH_hotspots_dir}"
cp -r "${input_results_dir}/${Empirical_breed_ROH_hotspots_dir}/." "${HO_results_dir}/${Empirical_breed_ROH_hotspots_dir}"

###  Inbreeding coefficient ### 
mkdir -p "${HO_results_dir}/${Empirical_breed_F_ROH_dir}"
cp -r "${input_results_dir}/${Empirical_breed_F_ROH_dir}/." "${HO_results_dir}/${Empirical_breed_F_ROH_dir}"

###  Expected Heterozygosity distribution ### 
mkdir -p "${HO_results_dir}/${Empirical_breed_expected_heterozygosity_dir_NO_MAF}"
cp -r "${input_results_dir}/${Empirical_breed_expected_heterozygosity_dir_NO_MAF}/." "${HO_results_dir}/${Empirical_breed_expected_heterozygosity_dir_NO_MAF}"

mkdir -p "${HO_results_dir}/${Empirical_breed_expected_heterozygosity_dir_MAF_0_05}"
cp -r "${input_results_dir}/${Empirical_breed_expected_heterozygosity_dir_MAF_0_05}/." "${HO_results_dir}/${Empirical_breed_expected_heterozygosity_dir_MAF_0_05}"

mkdir -p "${HO_results_dir}/${Empirical_breed_expected_heterozygosity_dir_MAF_0_01}"
cp -r "${input_results_dir}/${Empirical_breed_expected_heterozygosity_dir_MAF_0_01}/." "${HO_results_dir}/${Empirical_breed_expected_heterozygosity_dir_MAF_0_01}"

echo "Done!"
echo "Necessairy reference values for the Hyperparameter Optimization have now been copied and stored in are copied and stored in $HO_data_dir and $HO_results_dir."
echo "Hyperparameter Optimization can now be performed"
