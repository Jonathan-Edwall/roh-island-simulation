
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
####### Defining the INPUT files #######
######################################  
bedtools_results_dir=$HOME/results/Bedtools/coverage

#�������������
#� Empirical �
#�������������
coverage_output_german_shepherd_dir=$bedtools_results_dir/empirical/doi_10_5061_dryad_h44j0zpkf__v20210813

roh_frequencies_german_shepherd_dir=$coverage_output_german_shepherd_dir/pop_roh_freq

#�������������
#� Simulated � 
#�������������
simulated_bedtools_dir=$bedtools_results_dir/simulated
##### Neutral Model #####
coverage_output_neutral_model_dir=$simulated_bedtools_dir/neutral_model
roh_frequencies_neutral_model_dir=$coverage_output_neutral_model_dir/pop_roh_freq
##### Selection Model ##### 
coverage_output_selection_model_dir=$simulated_bedtools_dir/selection_model
roh_frequencies_selection_model_dir=$coverage_output_selection_model_dir/pop_roh_freq

######################################  
####### Defining the OUTPUT files #######
######################################  
ROH_hotspots_dir=$HOME/results/ROH-Hotspots

all_chr_roh_freq_dir_relative_path=Gosling_plots/all_chr_roh_freq

#�������������
#� Empirical �
#�������������
roh_hotspots_output_german_shepherd_dir=$ROH_hotspots_dir/empirical/german_shepherd
mkdir -p $roh_hotspots_output_german_shepherd_dir # Creating subdirectory if it doesn't already exist

gapless_roh_hotspots_german_shepherd_dir=$roh_hotspots_output_german_shepherd_dir/gapless_roh_hotspots
mkdir -p $gapless_roh_hotspots_german_shepherd_dir # Creating subdirectory if it doesn't already exist

autosome_roh_freq_german_shepherd_dir=$roh_hotspots_output_german_shepherd_dir/Gosling_plots/autosome_roh_freq
mkdir -p $autosome_roh_freq_german_shepherd_dir # Creating subdirectory if it doesn't already exist

roh_hotspots_freq_german_shepherd_dir=$roh_hotspots_output_german_shepherd_dir/Gosling_plots/roh_hotspots_freq
mkdir -p $roh_hotspots_freq_german_shepherd_dir # Creating subdirectory if it doesn't already exist

#�������������
#� Simulated � 
#�������������
simulated_roh_hotspots_dir=$ROH_hotspots_dir/simulated
##### Neutral Model #####
Neutral_model_ROH_hotspots_dir=$simulated_roh_hotspots_dir/neutral
mkdir -p $Neutral_model_ROH_hotspots_dir # Creating subdirectory if it doesn't already exist


gapless_roh_hotspots_neutral_model_dir=$Neutral_model_ROH_hotspots_dir/gapless_roh_hotspots
mkdir -p $gapless_roh_hotspots_neutral_model_dir # Creating subdirectory if it doesn't already exist

autosome_roh_freq_neutral_model_dir=$Neutral_model_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq
mkdir -p $autosome_roh_freq_neutral_model_dir # Creating subdirectory if it doesn't already exist

roh_hotspots_freq_neutral_model_dir=$Neutral_model_ROH_hotspots_dir/Gosling_plots/roh_hotspots_freq
mkdir -p $roh_hotspots_freq_neutral_model_dir # Creating subdirectory if it doesn't already exist

##### Selection Model ##### 
Selection_model_ROH_hotspots_dir=$simulated_roh_hotspots_dir/selection
mkdir -p $Selection_model_ROH_hotspots_dir # Creating subdirectory if it doesn't already exist


gapless_roh_hotspots_selection_model_dir=$Selection_model_ROH_hotspots_dir/gapless_roh_hotspots
mkdir -p $gapless_roh_hotspots_selection_model_dir # Creating subdirectory if it doesn't already exist

autosome_roh_freq_selection_model_dir=$Selection_model_ROH_hotspots_dir/Gosling_plots/autosome_roh_freq
mkdir -p $autosome_roh_freq_selection_model_dir # Creating subdirectory if it doesn't already exist

roh_hotspots_freq_selection_model_dir=$Selection_model_ROH_hotspots_dir/Gosling_plots/roh_hotspots_freq
mkdir -p $roh_hotspots_freq_selection_model_dir # Creating subdirectory if it doesn't already exist


######################################  
####### Defining parameter values #######
######################################




##############################################################################################  
############ RESULTS ###########################################################################
############################################################################################## 

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Empirical Data (German Shepherd) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

# Generate the list of .bed files in the directory
bed_files_list=("$roh_frequencies_german_shepherd_dir"/*.bed)


# Loop over each input bed file
for bed_file in "${bed_files_list[@]}"; do
    export pop_roh_freq_bed_file="$bed_file"
    echo "$pop_roh_freq_bed_file"
    
    # Construct the params list
    export input_bed_file="$pop_roh_freq_bed_file"
    export output_directory="$roh_hotspots_output_german_shepherd_dir"
    export gapless_roh_hotspots_directory="$gapless_roh_hotspots_german_shepherd_dir"
    export autosome_roh_freq_directory="$autosome_roh_freq_german_shepherd_dir"
    export roh_hotspots_freq_directory="$roh_hotspots_freq_german_shepherd_dir"
    
    # Render the R Markdown document with the current input bed file
    Rscript -e "rmarkdown::render('$script_dir/3-2_3_ROH_hotspots_identification.Rmd')"
done

echo "ROH-Hotspots detected for the German Shepherd"
echo "The results are stored in: $roh_hotspots_output_german_shepherd_dir"

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Neutral Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Generate the list of .bed files in the directory
bed_files_list=("$roh_frequencies_neutral_model_dir"/*.bed)



# Loop over each input bed file
for bed_file in "${bed_files_list[@]}"; do
    export pop_roh_freq_bed_file="$bed_file"
    echo "$pop_roh_freq_bed_file"
    
    # Construct the params list
    export input_bed_file="$pop_roh_freq_bed_file"
    export output_directory="$Neutral_model_ROH_hotspots_dir"
    export gapless_roh_hotspots_directory="$gapless_roh_hotspots_neutral_model_dir"
    export autosome_roh_freq_directory="$autosome_roh_freq_neutral_model_dir"
    export roh_hotspots_freq_directory="$roh_hotspots_freq_neutral_model_dir"
    
    # Render the R Markdown document with the current input bed file
    Rscript -e "rmarkdown::render('$script_dir/3-2_3_ROH_hotspots_identification.Rmd')"
done

echo "ROH-Hotspots detected for the Neutral Model Simulations"
echo "The results are stored in: $Neutral_model_ROH_hotspots_dir"

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
#¤¤¤¤ Selection Model (Simulated) ¤¤¤¤ 
#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# Generate the list of .bed files in the directory
bed_files_list=("$roh_frequencies_selection_model_dir"/*.bed)



# Loop over each input bed file
for bed_file in "${bed_files_list[@]}"; do
    export pop_roh_freq_bed_file="$bed_file"
    echo "$pop_roh_freq_bed_file"
    
    # Construct the params list
    export input_bed_file="$pop_roh_freq_bed_file"
    export output_directory="$Selection_model_ROH_hotspots_dir"
    export gapless_roh_hotspots_directory="$gapless_roh_hotspots_selection_model_dir"
    export autosome_roh_freq_directory="$autosome_roh_freq_selection_model_dir"
    export roh_hotspots_freq_directory="$roh_hotspots_freq_selection_model_dir"
    
    # Render the R Markdown document with the current input bed file
    Rscript -e "rmarkdown::render('$script_dir/3-2_3_ROH_hotspots_identification.Rmd')"
done

echo "ROH-Hotspots detected for the Selection Model Simulations"
echo "The results are stored in: $Selection_model_ROH_hotspots_dir"




# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "ROH-Hotspots computed for all the datasets"
echo "Runtime: $runtime seconds"

