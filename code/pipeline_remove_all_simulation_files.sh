######################################
####### Defining the working directory #######
######################################
HOME=/home/jonathan
cd $HOME

# export empirical_dog_breed="german_shepherd"
empirical_dog_breed="labrador_retriever" # Defined in run_pipeline_hyperoptimize_neutral_model.sh

#############################################
####### Defining paths for the files to be removed #######
#############################################
# data_dir=$HOME/data # Defined in run_pipeline_hyperoptimize_neutral_model.sh
data_dir=$HOME/data_HO
### Raw data ###
raw_data_dir=$data_dir/raw
simulated_raw_data_dir=$raw_data_dir/simulated
### Preprocesed data ###
preprocessed_data_dir=$data_dir/preprocessed
# empirical_preprocessed_data_dir=$preprocessed_data_dir/empirical
# empirical_breed_preprocessed_data_dir="$empirical_preprocessed_data_dir/$empirical_dog_breed"
simulated_preprocessed_data_dir=$preprocessed_data_dir/simulated

### Results directory ###
# results_dir=$HOME/results # Defined in run_pipeline_hyperoptimize_neutral_model.sh
results_dir=$HOME/results_HO

Bedtools_coverage_simulated_dir=$results_dir/Bedtools/coverage/simulated
plink_allele_freq_simulated_dir=$results_dir/PLINK/allele_freq/simulated
plink_ROH_simulated_dir=$results_dir/PLINK/ROH/simulated
ROH_hotspot_simulated_dir=$results_dir/ROH-Hotspots/simulated
expected_heterozygosity_No_MAF_simulated=$results_dir/expected_heterozygosity_No_MAF/simulated
####################################  
# Defining the directories to delete
#################################### 

# rm -r $results_dir
rm -r $Bedtools_coverage_simulated_dir
rm -r $plink_allele_freq_simulated_dir
rm -r $plink_ROH_simulated_dir
rm -r $ROH_hotspot_simulated_dir
rm -r $expected_heterozygosity_No_MAF_simulated


# rm -r $empirical_breed_preprocessed_data_dir
rm -r $simulated_preprocessed_data_dir
rm -r $simulated_raw_data_dir
