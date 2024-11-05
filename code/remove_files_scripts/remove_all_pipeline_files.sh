######################################
####### Defining the working directory #######
######################################
HOME="/home/jonathan"
cd $HOME

# export empirical_dog_breed="german_shepherd"
empirical_dog_breed="labrador_retriever" # Defined in run_pipeline.sh

#############################################
####### Defining paths for the files to be removed #######
#############################################
data_dir=$HOME/data
### Raw data ###
raw_data_dir=$data_dir/raw
simulated_raw_data_dir=$raw_data_dir/simulated
### Preprocesed data ###
preprocessed_data_dir=$data_dir/preprocessed
empirical_preprocessed_data_dir=$preprocessed_data_dir/empirical
empirical_breed_preprocessed_data_dir="$empirical_preprocessed_data_dir/$empirical_dog_breed"
simulated_preprocessed_data_dir=$preprocessed_data_dir/simulated

### Results directory ###
results_dir=$HOME/results

####################################  
# Defining the directories to delete
#################################### 

rm -r $results_dir
rm -r $empirical_breed_preprocessed_data_dir
rm -r $simulated_preprocessed_data_dir
rm -r $simulated_raw_data_dir
