
#!/bin/bash -l

# Start the timer 
start=$(date +%s)

####################################  
# Defining the working directory
#################################### 

HOME=/home/jonathan
cd $HOME

pipeline_script_dir=$HOME/code/pipeline_scripts

#################################### 
# Defining Simulation parameters
#################################### 
output_dir_neutral_simulation=$HOME/data/raw/simulated/neutral_model

# export chr_simulated="chr3"
# n_simulation_replicates=20 #20

mkdir -p $output_dir_neutral_simulation



#����������������������������������������������������������������������������
# Function: 
# Founder population simulation for Dogs (Neutral Model) in AlphaSimR
#
###Input: 
# 
###Output: 
#����������������������������������������������������������������������������
cd $output_dir_neutral_simulation

# Running the simulation 20 times
for ((counter=1; counter<=$n_simulation_replicates; counter++))
do
    # Define the parameters to be used in the .Rmd-script:

    export output_sim_files_basename="sim_${counter}_neutral_model_${chr_simulated}"
    export output_dir_neutral_simulation="$output_dir_neutral_simulation"
    export chr_simulated="$chr_simulated" #Variable defined in run_pipeline.sh
    export selected_chr_snp_density_mb="$selected_chr_snp_density_mb" #Variable defined in run_pipeline.sh
        

    Rscript -e "rmarkdown::render('$pipeline_script_dir/1-1_dogs_founder_pop_sim_neutral_model.Rmd')"     
    
    
      
    echo "Simulation $counter of $n_simulation_replicates completed"
done



# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Neutral model simulations of dogs completed"
echo "The outputfiles are stored in: $output_dir_neutral_simulation"
echo "Runtime: $runtime seconds"