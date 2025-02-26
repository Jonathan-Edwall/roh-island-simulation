#!/bin/bash
# Start the timer 
script_start=$(date +%s)

######################################  
####### Defining the working directory #######
######################################
cd $HOME # Defined in run_pipeline.sh

# empirical_breed="labrador_retriever" # Defined in run_pipeline.sh

#############################################  
####### Defining paths for the files to be removed #######
#############################################  

# Defining input directory of the ROH-files
plink_results_dir=$results_dir/PLINK/ROH
simulated_plink_dir=$plink_results_dir/simulated

bedtools_results_dir=$results_dir/Bedtools/coverage
simulated_bedtools_dir=$bedtools_results_dir/simulated



#���������������
#� Empirical Data �
#���������������
# export empirical_breed="german_shepherd"
# empirical_breed="labrador_retriever" # Defined in run_pipeline.sh

empirical_breed_pop_hom_file_dir=$plink_results_dir/empirical/$empirical_breed
# Defining path to input directory of Individual ROH-files (bed format)
empirical_breed_indv_ROH_files_dir=$empirical_breed_pop_hom_file_dir/individual_ROH

coverage_output_empirical_breed_dir=$bedtools_results_dir/empirical/$empirical_breed


#���������������
#� Simulated Data �
#���������������
##### Neutral Model #####
neutral_model_pop_hom_file_dir=$simulated_plink_dir/neutral_model
neutral_model_indv_ROH_files_dir=$neutral_model_pop_hom_file_dir/individual_ROH

coverage_output_neutral_model_dir=$simulated_bedtools_dir/neutral_model
##### Selection Model ##### 
selection_model_pop_hom_file_dir=$simulated_plink_dir/selection_model
selection_model_indv_ROH_files_dir=$selection_model_pop_hom_file_dir/individual_ROH

coverage_output_selection_model_dir=$simulated_bedtools_dir/selection_model







####################################  
# Defining the directories to delete
#################################### 

# Remove individual coverage files
rm $coverage_output_empirical_breed_dir/*.bed

# Find is used to deal with the large amount of files to be deleted (the "rm" command is limited with how many arguments (files) it can take) 
find "$coverage_output_neutral_model_dir" -maxdepth 1 -type f -name "*.bed" -delete
find "$coverage_output_selection_model_dir" -maxdepth 1 -type f -name "*.bed" -delete


# Remove individual ROH-files
rm -r $empirical_breed_indv_ROH_files_dir
rm -r $neutral_model_indv_ROH_files_dir
rm -r $selection_model_indv_ROH_files_dir


