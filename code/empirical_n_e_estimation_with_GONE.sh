#!/bin/bash -l

# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate plink

######################################  
####### Defining parameter values #######
######################################
empirical_preprocessed_data_basename=german_shepherd_filtered
empirical_raw_data_basename=LR_fs
autosomal_chromosomes_species="1-38"
empirical_geneticmap_filetype_raw_data=.bim

####################################  
# Defining the working directory
#################################### 
HOME=/home/jonathan
cd $HOME
script_directory=$HOME/code

####################################  
# Defining the input files
#################################### 

# Defining input directory
raw_data_dir=$HOME/data/raw
raw_german_shepherd_dir=$raw_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

preprocessed_data_dir=$HOME/data/preprocessed
preprocessed_empirical_dog_breed_dir=$preprocessed_data_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

####################################  
# Defining the output files
#################################### 
GONE_dir=$HOME/GONE



###############################################################################################  
# RESULTS - Using Preprocessed Data
############################################################################################### 

##########################  
# Estimating N_e from raw data  #
##########################

# ¤¤¤¤ Use if the geneticmap is in .bim format
plink \
--bfile $raw_german_shepherd_dir/$empirical_raw_data_basename \
--recode \
--dog \
--chr $autosomal_chromosomes_species \
--out $GONE_dir/$empirical_raw_data_basename 

empirical_data_basename=$empirical_raw_data_basename

# #################################  
# # Estimating N_e from preprocessed data   #
# ################################# 

# # Convert .bed, .bim, .fam to .ped and .map
# plink \
# --bfile $preprocessed_empirical_dog_breed_dir/$empirical_preprocessed_data_basename \
# --recode \
# --dog \
# --out $GONE_dir/$empirical_preprocessed_data_basename


# empirical_data_basename=$empirical_preprocessed_data_basename


####################  
####### GONE #######  
####################

echo ".Map and .Ped files created."
echo "GONE will now be run for N_e estimation of the empirical dataset"


cd $GONE_dir 
# Making all the relevant programmes for GONE executable
chmod u+x PROGRAMMES/*


bash script_GONE.sh $empirical_data_basename 

###################  
# Viewing the results #  
###################
cd $script_directory


export GONE_results_dir="$GONE_dir"
export empirical_data_prefix="$empirical_data_basename"


Rscript -e "rmarkdown::render('$script_directory/GONE_Empirical_Ne_estimation.Rmd')"

# # Remove copied files from GONE directory
# rm $GONE_dir/$empirical_data_basename.map 
# rm $GONE_dir/$empirical_data_basename.ped
# rm $GONE_dir/$empirical_data_basename.log
# rm $GONE_dir/$empirical_data_basename.nosex


rm $GONE_dir/$empirical_data_basename.*
# rm $GONE_dir/*$empirical_data_basename.*



# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Total Runtime: $runtime seconds"
