import os
import subprocess
import optuna
import json
import pandas as pd
import signal
import sys

HO_id = f"HO_grid_search_top_1_perc_results"
# Dynamically determine the root directory one level up from the current script's directory
root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
path_to_results_folder = f"{root_dir}/hyperoptimizer_results"
pop_histories_top_results_file="HO_top_results_population_histories.tsv"
pop_histories_top_results_file_full_path=f"{path_to_results_folder}/{pop_histories_top_results_file}"

# Loading the population histories of the top results, of which grid search will be run for.
pop_histories = pd.read_csv(pop_histories_top_results_file_full_path, sep="\t", header=0)

# Global variable to store the current population history
current_pop_history = None

# Function to handle user interruption
def signal_handler(sig, frame):
    print('Optimization interrupted. Exiting.')
    sys.exit(0)
# Register the signal handler
signal.signal(signal.SIGINT, signal_handler)

# Define the objective function
def objective(trial):
    # Define the directory and the path to the file where you want to log the failed rows
    output_dir = path_to_results_folder
    failed_trials_file = os.path.join(output_dir, f"failed_trials_{HO_id}.tsv")
    header = "Chr\tChr_specific_recomb_rate"

    # Function to append the failed parameters to the file
    def log_failed_parameters(chr_simulated, chr_specific_recombination_rate):
        file_exists = os.path.isfile(failed_trials_file)
        
        with open(failed_trials_file, 'a') as f:
            if not file_exists:
                f.write(header)
            f.write(
                f"{chr_simulated}\t{chr_specific_recombination_rate}\n"

            )
    try:
        global current_pop_history  # Use the global variable
        # # Extract parameters
        chr_simulated = trial.suggest_categorical('chr_simulated', ["chr1", "chr2", "chr3", "chr9", "chr20", "chr21", "chr28", "chr38"])
        chr_specific_recombination_rate = trial.suggest_categorical('chr_specific_recombination_rate', [True, False])
        # Extract parameters for the current trial
        Ne_burn_in = current_pop_history['NeBurnIn']
        n_bottleneck = current_pop_history['nBottleneck']
        n_generations_bottleneck = current_pop_history['nGenBottleneck']
        n_simulated_generations_breed_formation = current_pop_history['nGenBreed']
        n_individuals_breed_formation = current_pop_history['nBreed']

        # Run the pipeline with the parameters from the selected row
        result = subprocess.run(['bash', 'run_pipeline_hyperoptimize_neutral_model_grid_search_categorical_attributes.sh',
                                 str(HO_results_file), str(chr_simulated), str(chr_specific_recombination_rate), 
                                 str(Ne_burn_in), str(n_bottleneck), str(n_generations_bottleneck),
                                 str(n_simulated_generations_breed_formation),
                                 str(n_individuals_breed_formation),
                                 ],
                                capture_output=True, text=True)
        
        # Check if the pipeline ran successfully
        if result.returncode != 0:
            raise RuntimeError(f"Pipeline failed: {result.stderr}")

        # Read the cost function value from the last row of the results file
        df = pd.read_csv(HO_results_file_full_path, sep="\t")

        # Validate that the current trial is found in the last row of the cost_value results file. If not, the trial is faulty and should be skipped!
        last_row = df.iloc[-1].astype(str)

        print(f"Comparing trial parameters to last row of results file:")

        # print(f"Comparing trial parameters to last row of results file:")
        print(f"chr_simulated: {str(chr_simulated).lower()} == {last_row['Chr'].lower()}")
        print(f"chr_specific_recombination_rate: {str(chr_specific_recombination_rate).lower()} == {last_row['Chr_specific_recomb_rate'].lower()}\n")

        print(f"Ne_burn_in: {str(Ne_burn_in).lower()} == {last_row['NeBurnIn'].lower()}")
        print(f"n_bottleneck: {str(n_bottleneck).lower()} == {last_row['nBottleneck'].lower()}")
        print(f"n_generations_bottleneck: {str(n_generations_bottleneck).lower()} == {last_row['nGenBottleneck'].lower()}")
        print(f"n_simulated_generations_breed_formation: {str(n_simulated_generations_breed_formation).lower()} == {last_row['nGenBreed'].lower()}")
        print(f"n_individuals_breed_formation: {str(n_individuals_breed_formation).lower()} == {last_row['nBreed'].lower()}")
        # print(f"reference_population_for_snp_chip: {str(reference_population_for_snp_chip).lower()} == {last_row['SNPchipRefPop'].lower()}")
        if not (
            last_row["Chr"].lower() == str(chr_simulated).lower() and
            last_row["NeBurnIn"].lower() == str(Ne_burn_in).lower() and
            last_row["nBottleneck"].lower() == str(n_bottleneck).lower() and
            last_row["nGenBottleneck"].lower() == str(n_generations_bottleneck).lower() and
            last_row["nGenBreed"].lower() == str(n_simulated_generations_breed_formation).lower() and
            last_row["nBreed"].lower() == str(n_individuals_breed_formation).lower() and
            last_row['Chr_specific_recomb_rate'].lower() == str(chr_specific_recombination_rate).lower()
        ):
            raise RuntimeError("Trial parameters do not match the last row of the results file.")           

        # Extract the cost function value
        cost_value = float(last_row["Sim_Cost_Result"])
        return cost_value
    except Exception as e:
        print(f"\n {10 * '!'}\n Error during optimization: {e}\n{10 * '!'}\n")
        # Log the failed parameters
        log_failed_parameters(chr_simulated,chr_specific_recombination_rate )
        # # Log the failed parameters
        # log_failed_parameters(chr_simulated, Ne_burn_in, n_bottleneck,
        #                 n_generations_bottleneck, n_simulated_generations_breed_formation, n_individuals_breed_formation, reference_population_for_snp_chip)

        return float('inf')


sampler = optuna.samplers.GridSampler({
    'chr_simulated': ["chr1", "chr2", "chr3", "chr9", "chr20", "chr21", "chr28", "chr38"],
    'chr_specific_recombination_rate': [True, False]
})


# Run the grid search of the categorical attributes for each population history
for i, history in pop_histories.iterrows():
    print(f"\n{'¤'*100}\n")
    HO_results_file = f"neutral_models_cost_function_results_{HO_id}.tsv"
    HO_results_file_full_path = f"{path_to_results_folder}/{HO_results_file}"

    current_pop_history = history  # Update the global variable before running HO
    # Create a new study for each population history
    study = optuna.create_study(direction='minimize', sampler=sampler)
    study.optimize(objective)

# Save the best hyperparameters
best_params = study.best_params
HO_best_params_file = f"best_hyperparameters_{HO_id}.json"
with open(HO_best_params_file, 'w') as f:
    json.dump(best_params, f)

print("Best hyperparameters:", best_params)

