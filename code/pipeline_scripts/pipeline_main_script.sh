
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
export output_dir_neutral_simulation=$HOME/data/raw/simulated/neutral_model

export chr_simulated="chr3"
n_simulation_replicates=20

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
    export output_sim_files_basename="sim_${counter}_neutral_model_${chr_simulated}"
        

    Rscript -e "rmarkdown::render('$script_dir/1-1_dogs_founder_pop_sim_neutral_model.Rmd', params = list(output_dir_neutral_simulation = '$output_dir_neutral_simulation', output_sim_files_basename = '$output_sim_files_basename', chr_simulated = '$chr_simulated'))"
    
    
    #Rscript "$script_dir/1-1_dogs_founder_pop_sim_neutral_model.R" "$output_dir_neutral_simulation" "$output_sim_files_basename" "$chr_simulated"
    
    
    
      
    echo "Simulation $counter of $n_simulation_replicates completed"
done



# Ending the timer 
end=$(date +%s)
# Calculating the runtime of the script
runtime=$((end-start))

echo "Neutral model simulations of dogs completed"
echo "The outputfiles are stored in: $output_dir_neutral_simulation"
echo "Runtime: $runtime seconds"