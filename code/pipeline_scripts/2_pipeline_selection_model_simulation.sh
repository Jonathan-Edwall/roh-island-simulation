
#!/bin/bash -l

# Start the timer 
start=$(date +%s)

####################################  
# Defining the working directory
#################################### 

HOME=/home/jonathan
#cd $HOME

script_dir=$HOME/code/pipeline_scripts

#################################### 
# Defining Simulation parameters
#################################### 
export output_dir_selection_simulation=$HOME/data/raw/simulated/selection_model
#mkdir -p $output_dir_selection_simulation
mkdir -p $output_dir_selection_simulation/variant_freq_plots # Also creating a subdirectory for storing the images of the simulation runs

export chr_simulated="chr3"
export n_generations_selection_sim=40 # 40 default
export n_ind_per_selection_sim_generation=50
selection_coefficient_list=(0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8)
#selection_coefficient_list=(0.1 0.2)

n_simulation_replicates=5




#����������������������������������������������������������������������������
# Function: 
# Selection Scenario simulation for Dogs in AlphaSimR
#
###Input: 
# 
###Output: 
#����������������������������������������������������������������������������
cd $output_dir_selection_simulation

# Running the simulation n_simulation_replicates (20) times to create 20 technical replicates
for ((counter=1; counter<=$n_simulation_replicates; counter++))
do
    
    # Loop over each selection coefficient
    for selection_coefficient in "${selection_coefficient_list[@]}"
    do
    export output_sim_files_basename="sim_${counter}_selection_model_s$(echo "$selection_coefficient" | sed 's/\.//')_${chr_simulated}"
    export selection_coefficient="$selection_coefficient"
    echo $selection_coefficient

        Rscript -e "rmarkdown::render('$script_dir/2-5_1_dogs_founder_pop_sim_selection_model.Rmd', 
            params = list(
                output_dir_selection_simulation = '$output_dir_selection_simulation', 
                output_sim_files_basename = '$output_sim_files_basename', 
                chr_simulated = '$chr_simulated',
                n_generations_selection_sim = '$n_generations_selection_sim',
                selection_coefficient = '$selection_coefficient',
                n_ind_per_selection_sim_generation = '$n_ind_per_selection_sim_generation'
            ))"
        
        echo "Simulation $counter with selection coefficient $selection_coefficient completed"
    done
done





# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "selection model simulations of dogs completed"
echo "The outputfiles are stored in: $output_dir_selection_simulation"
echo "Runtime: $runtime seconds"