
#!/bin/bash -l

# Start the timer 
start=$(date +%s)


####################################  
# Defining the working directory
#################################### 

HOME=/home/jonathan
#cd $HOME

script_dir=$HOME/code/pipeline_scripts

######################################  
####### Defining parameter values #######
######################################

######################################  
####### Defining the INPUT files #######
######################################  

### ROH Hotspots
ROH_hotspots_dir=$HOME/results/ROH-Hotspots
Selection_strength_test_dir=$ROH_hotspots_dir/selection_strength_test
Sweep_test_dir=$ROH_hotspots_dir/sweep_test

plink_ROH_dir=$HOME/results/PLINK/ROH
expected_heterozygosity_dir=$HOME/results/expected_heterozygosity

#�������������
#� Empirical �
#�������������

German_shepherd_ROH_hotspots_dir=$ROH_hotspots_dir/empirical/german_shepherd
German_shepherd_autosome_ROH_freq_dir=$German_shepherd_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq
### Inbreeding coefficient ###
German_shepherd_F_ROH_dir=$plink_ROH_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813/F_ROH
### Expected Heterozygosity distribution ###
German_shepherd_H_e_dir=$expected_heterozygosity_dir/empirical/german_shepherd


#�������������
#� Simulated � 
#�������������
simulated_roh_hotspots_dir=$ROH_hotspots_dir/simulated

### ROH hotspots ###
Neutral_model_ROH_hotspots_dir=$ROH_hotspots_dir/simulated/neutral
Neutral_model_autosome_ROH_freq_dir=$Neutral_model_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq

Selection_model_ROH_hotspots_dir=$ROH_hotspots_dir/simulated/selection
Selection_model_autosome_ROH_freq_dir=$Selection_model_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq

### Inbreeding coefficient ###
Neutral_model_F_ROH_dir=$plink_ROH_dir/simulated/neutral_model/F_ROH
Selection_model_F_ROH_dir=$plink_ROH_dir/simulated/selection_model/F_ROH

### Expected Heterozygosity distribution ###
Neutral_model_H_e_dir=$expected_heterozygosity_dir/simulated/neutral_model
Selection_model_H_e_dir=$expected_heterozygosity_dir/simulated/selection_model

######################################  
####### Defining the OUTPUT files #######
######################################  



##############################################################################################  
############ RESULTS ###########################################################################
############################################################################################## 


# Construct the params list
export Selection_strength_test_dir="$Selection_strength_test_dir"
export Sweep_test_dir="$Sweep_test_dir"

############### 
## Empirical ###
###############

### ROH hotspots ###
export Empirical_data_ROH_hotspots_dir="$German_shepherd_ROH_hotspots_dir"

export Empirical_data_autosome_ROH_freq_dir="$German_shepherd_autosome_ROH_freq_dir"
### Inbreeding coefficient ###
export Empirical_data_F_ROH_dir="$German_shepherd_F_ROH_dir"
### Expected Heterozygosity distribution ###
export Empirical_data_H_e_dir="$German_shepherd_H_e_dir"

############### 
## Simulated ###
###############

### ROH hotspots ###
export Neutral_model_ROH_hotspots_dir="$Neutral_model_ROH_hotspots_dir"
export Neutral_model_autosome_ROH_freq_dir="$Neutral_model_autosome_ROH_freq_dir"
export Selection_model_ROH_hotspots_dir="$Selection_model_ROH_hotspots_dir"
export Selection_model_autosome_ROH_freq_dir="$Selection_model_autosome_ROH_freq_dir"

### Inbreeding coefficient ###
export Neutral_model_F_ROH_dir="$Neutral_model_F_ROH_dir"
export Selection_model_F_ROH_dir="$Selection_model_F_ROH_dir"

### Expected Heterozygosity distribution ###
export Neutral_model_H_e_dir="$Neutral_model_H_e_dir"
export Selection_model_H_e_dir="$Selection_model_H_e_dir"

# echo "output_dir_sweep_test: $selection_strength_testing_results_dir "

# Render the R Markdown document with the current input bed file
Rscript -e "rmarkdown::render('$script_dir/13_pipeline_results.Rmd')"



# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Pipeline results finished"
echo "Runtime: $runtime seconds"

