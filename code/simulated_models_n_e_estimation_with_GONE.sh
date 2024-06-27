#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

# Activate conda environment
source /home/martin/anaconda3/etc/profile.d/conda.sh  # Source Conda initialization script
conda activate plink

######################################  
####### Defining parameter values #######
######################################
# chr_simulated="chr1" # Imported from run_pipeline.sh
# selection_models_list=("s02" "s04" "s06" "s08")
selection_models_list=("s04" "s06" "s08")


# # Boolean value to determine whether to run the selection simulation code
# selection_simulation=TRUE # Defined in run_pipeline.sh


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
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
raw_data_dir=$data_dir/raw
raw_simulated_dir=$raw_data_dir/simulated

base_population_simulation_name="post_bottleneck_population_${chr_simulated}"


#�������������
#� Neutral Model � 
#�������������
raw_simulated_neutral_model_dir=$raw_simulated_dir/neutral_model

neutral_model_simulation_name="sim_1_neutral_model_${chr_simulated}"
#�������������
#� Selection Model � 
#�������������
raw_simulated_selection_model_dir=$raw_simulated_dir/selection_model
# selection_model_simulation_name="sim_1_selection_model_s08_chr1"



####################################  
# Defining the output files
#################################### 
GONE_dir=$HOME/GONE

# ##########################  
# # Base population (post bottleneck): Estimating N_e   #
# ##########################
# cp $raw_simulated_dir/$base_population_simulation_name.map $GONE_dir/$base_population_simulation_name.map 
# cp $raw_simulated_dir/$base_population_simulation_name.ped $GONE_dir/$base_population_simulation_name.ped 

# ###########  
# ## GONE ### 
# ###########
# echo "Running GONE to get N_e estimation of $base_population_simulation_name"

# cd $GONE_dir 
# # Making all the relevant programmes for GONE executable
# chmod u+x PROGRAMMES/*

# bash script_GONE.sh $base_population_simulation_name

# rm $GONE_dir/$base_population_simulation_name.map 
# rm $GONE_dir/$base_population_simulation_name.ped
# ##################  
# ## Viewing the result #
# ##################


# cd $script_directory


# export GONE_results_dir="$GONE_dir"
# export empirical_data_prefix="$base_population_simulation_name"

# # Modify the pipeline_result_summary.sh script call to include the MAF status suffix in the output file name
# output_file="$script_directory/GONE_Empirical_Ne_estimation_${base_population_simulation_name}.html"
# # Render the R Markdown document with the current input bed file
# Rscript -e "rmarkdown::render('$script_directory/GONE_Empirical_Ne_estimation.Rmd', output_file = '$output_file')"

##########################  
# Neutral Model: Estimating N_e   #
##########################

# ¤¤¤¤ Use if the geneticmap is in .bim format
plink \
--bfile $raw_simulated_neutral_model_dir/$neutral_model_simulation_name \
--recode \
--dog \
--out $GONE_dir/$neutral_model_simulation_name 

###########  
## GONE ### 
###########
echo "Running GONE to get N_e estimation of $neutral_model_simulation_name"

cd $GONE_dir 
# Making all the relevant programmes for GONE executable
chmod u+x PROGRAMMES/*

bash script_GONE.sh $neutral_model_simulation_name


##################  
## Viewing the result #
##################


cd $script_directory


export GONE_results_dir="$GONE_dir"
export empirical_data_prefix="$neutral_model_simulation_name"

# Modify the pipeline_result_summary.sh script call to include the MAF status suffix in the output file name
output_file="$script_directory/GONE_Empirical_Ne_estimation_${neutral_model_simulation_name}.html"
# Render the R Markdown document with the current input bed file
Rscript -e "rmarkdown::render('$script_directory/GONE_Empirical_Ne_estimation.Rmd', output_file = '$output_file')"

# rm $GONE_dir/$neutral_model_simulation_name.map
# rm $GONE_dir/$neutral_model_simulation_name.ped
# rm $GONE_dir/$neutral_model_simulation_name.log
# rm $GONE_dir/$neutral_model_simulation_name.nosex

rm $GONE_dir/*$neutral_model_simulation_name.*


##########################  
# Selection Model: Estimating N_e   #
##########################
if [ "$selection_simulation" = TRUE ]; then
  # Iterate through each selection model
  for model in "${selection_models_list[@]}"; do
    # Construct the selection_model_simulation_name
    selection_model_simulation_name="sim_1_selection_model_${model}_${chr_simulated}"

    # ¤¤¤¤ Use if the geneticmap is in .bim format
    plink \
    --bfile $raw_simulated_selection_model_dir/$selection_model_simulation_name \
    --recode \
    --dog \
    --out $GONE_dir/$selection_model_simulation_name

    # GONE section
    echo "Running GONE to get N_e estimation of $selection_model_simulation_name"

    cd $GONE_dir
    # Make all the relevant programs for GONE executable
    chmod u+x PROGRAMMES/*

    # Run GONE script
    bash script_GONE.sh "$selection_model_simulation_name"

    # Viewing the result
    cd $script_directory

    # Set environment variables
    export GONE_results_dir="$GONE_dir"
    export empirical_data_prefix="$selection_model_simulation_name"

    # Modify the pipeline_result_summary.sh script call to include the MAF status suffix in the output file name
    output_file="$script_directory/GONE_Empirical_Ne_estimation_${selection_model_simulation_name}.html"
    
    # Render the R Markdown document with the current input bed file
    Rscript -e "rmarkdown::render('$script_directory/GONE_Empirical_Ne_estimation.Rmd', output_file = '$output_file')"

    # Remove copied files from GONE directory
    # rm $GONE_dir/$selection_model_simulation_name.map 
    # rm $GONE_dir/$selection_model_simulation_name.ped
    # rm $GONE_dir/$selection_model_simulation_name.log
    # rm $GONE_dir/$selection_model_simulation_name.nosex

    rm $GONE_dir/*$selection_model_simulation_name.*


  done
else
    echo "Selection simulation is set to FALSE. Skipping the selection model processing."
fi


# Ending the timer 
script_end=$(date +%s)
# Calculating the runtime of the script
script_runtime=$((script_end-script_start))

echo "Total Runtime: $script_runtime seconds"
