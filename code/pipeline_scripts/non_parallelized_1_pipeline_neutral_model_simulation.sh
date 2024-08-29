
#!/bin/bash -l

# Start the timer 
script_start=$(date +%s)

####################################  
# Defining the working directory
#################################### 

HOME=/home/jonathan
cd $HOME

pipeline_script_dir=$HOME/code/pipeline_scripts

#################################### 
# Defining Simulation parameters
#################################### 
# data_dir=$HOME/data # Variable Defined in run_pipeline.sh
output_dir_neutral_simulation=$data_dir/raw/simulated/neutral_model

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
    export chr_simulated="$chr_simulated" #Variable defined in run_pipeline.sh
    export Ne_burn_in="$Ne_burn_in" #Variable defined in run_pipeline.sh
    export nInd_founder_population="$nInd_founder_population" #Variable defined in run_pipeline.sh
    export Inbred_ancestral_population="$Inbred_ancestral_population" #Variable defined in run_pipeline.sh
    export N_e_bottleneck="$N_e_bottleneck" #Variable defined in run_pipeline.sh
    export n_simulated_generations_breed_formation="$n_simulated_generations_breed_formation" #Variable defined in run_pipeline.sh
    export n_individuals_breed_formation="$n_individuals_breed_formation" #Variable defined in run_pipeline.sh
    export reference_population_for_snp_chip="$reference_population_for_snp_chip" #Variable defined in run_pipeline.sh   
    export output_sim_files_basename="sim_${counter}_neutral_model_${chr_simulated}"
    export output_dir_neutral_simulation="$output_dir_neutral_simulation"
    export selected_chr_snp_density_mb="$selected_chr_snp_density_mb" #Variable defined in run_pipeline.sh
    export Introduce_mutations="$Introduce_mutations" #Variable defined in run_pipeline.sh
        

    Rscript -e "rmarkdown::render('$pipeline_script_dir/1-1_dogs_founder_pop_sim_neutral_model.Rmd')"     
    
    
      
    echo "Simulation $counter of $n_simulation_replicates completed"
done



# Ending the timer 
script_end=$(date +%s)
# Calculating the script_runtime of the script
script_runtime=$((script_end-script_start))

echo "Neutral model simulations of dogs completed"
echo "The outputfiles are stored in: $output_dir_neutral_simulation"
echo "Runtime: $script_runtime seconds"