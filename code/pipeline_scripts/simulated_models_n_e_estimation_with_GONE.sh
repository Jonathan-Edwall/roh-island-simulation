#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

# Defining the path to the Conda initialization script
# conda_setup_script_path="/home/martin/anaconda3/etc/profile.d/conda.sh"
# source $conda_setup_script_path  # Source Conda initialization script
# Activate the conda environment
# conda activate roh_island_sim_env

######################################  
####### Defining parameter values #######
######################################
# chr_simulated="chr1" # Imported from run_pipeline.sh
# selection_models_list=("s0075" "s01" "s0125" "s015" "s02" "s03" "s04" "s05" "s06" "s07" "s08")
selection_models_list=("s04" "s06" "s08")

# Extract the start and end of the chromosome range (e.g., "1-19")
start_chromosome=$(echo $empirical_autosomal_chromosomes | cut -d'-' -f1)
end_chromosome=$(echo $empirical_autosomal_chromosomes | cut -d'-' -f2)

# Calculate the number of chromosomes in the range
num_chromosomes=$((end_chromosome - start_chromosome + 1))

# empirical_species="dog" # Variable Defined in run_pipeline.sh
# Define species-specific options
if [[ "$empirical_species" == "dog" ]]; then
    species_flag="--dog"
else
    species_flag="--chr-set $num_chromosomes"
fi



####################################  
# Defining the working directory
#################################### 
# HOME=/home/jonathan
cd $HOME

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

##########################  
# Neutral Model: Estimating N_e   #
##########################

# ¤¤¤¤ Use if the geneticmap is in .bim format
plink \
--bfile $raw_simulated_neutral_model_dir/$neutral_model_simulation_name \
--recode \
$species_flag \
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


cd $pipeline_scripts_dir


export GONE_results_dir="$GONE_dir"
export empirical_data_prefix="$neutral_model_simulation_name"

# Modify the pipeline_result_summary.sh script call to include the MAF status suffix in the output file name
# output_file="$pipeline_scripts_dir/GONE_Ne_estimation_${neutral_model_simulation_name}.html"
output_file="$results_dir/GONE_Ne_estimation_${neutral_model_simulation_name}.html"


# Render the R Markdown document with the current input bed file
Rscript -e "rmarkdown::render('$pipeline_scripts_dir/GONE_Ne_estimation.Rmd', output_file = '$output_file')"

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
    $species_flag \
    --out $GONE_dir/$selection_model_simulation_name

    # GONE section
    echo "Running GONE to get N_e estimation of $selection_model_simulation_name"

    cd $GONE_dir
    # Make all the relevant programs for GONE executable
    chmod u+x PROGRAMMES/*

    # Run GONE script
    bash script_GONE.sh "$selection_model_simulation_name"

    # Viewing the result
    cd $pipeline_scripts_dir

    # Set environment variables
    export GONE_results_dir="$GONE_dir"
    export empirical_data_prefix="$selection_model_simulation_name"

    # Modify the pipeline_result_summary.sh script call to include the MAF status suffix in the output file name
    # output_file="$pipeline_scripts_dir/GONE_Ne_estimation_${selection_model_simulation_name}.html"
    output_file="$results_dir/GONE_Ne_estimation_${selection_model_simulation_name}.html"

    
    # Render the R Markdown document with the current input bed file
    Rscript -e "rmarkdown::render('$pipeline_scripts_dir/GONE_Ne_estimation.Rmd', output_file = '$output_file')"

    # Remove copied files from GONE directory
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
