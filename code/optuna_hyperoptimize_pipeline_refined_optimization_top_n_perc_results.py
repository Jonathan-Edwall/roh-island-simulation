import os
import subprocess
import optuna
import json
import pandas as pd
import signal
import sys

n_results=5 # Define the top n result to rerun
HO_input_results_file = f"neutral_models_cost_function_results.tsv"
# Dynamically determine the root directory one level up from the current script's directory
root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
path_to_results_folder = f"{root_dir}/hyperoptimizer_results"

HO_input_results_file_full_path = f"{path_to_results_folder}/{HO_input_results_file}"

HO_id = "HO_top"
HO_results_file = f"neutral_models_cost_function_results_{HO_id}.tsv"
HO_results_file_full_path = f"{path_to_results_folder}/{HO_results_file}"

# Function to handle user interruption
def signal_handler(sig, frame):
    print('Optimization interrupted. Exiting.')
    sys.exit(0)
# Register the signal handler
signal.signal(signal.SIGINT, signal_handler)

# Load the top 10 % results based on "Sim_Cost_Result"
def load_top_n_results(n,HO_input_results_file_full_path):
    df = pd.read_csv(HO_input_results_file_full_path, sep="\t")
    top_n = df.sort_values("Sim_Cost_Result").head(n)
    return top_n

# Define the objective function
def objective(trial):
    # Define the directory and the path to the file where you want to log the failed rows
    output_dir = path_to_results_folder
    failed_trials_file = os.path.join(output_dir, f"failed_trials_{HO_id}.tsv")
    header = "Chr\tNeBurnIn\tnBottleneck\tnGenBottleneck\tnGenBreed\tnBreed\tChrSpecificRecombRate\n"

    # Function to append the failed parameters to the file
    def log_failed_parameters(chr_simulated, Ne_burn_in, n_bottleneck, n_generations_bottleneck, n_simulated_generations_breed_formation, n_individuals_breed_formation, chr_specific_recombination_rate):
        file_exists = os.path.isfile(failed_trials_file)
        with open(failed_trials_file, 'a') as f:
            if not file_exists:
                f.write(header)
            f.write(f"{chr_simulated}\t{Ne_burn_in}\t{n_bottleneck}\t{n_generations_bottleneck}\t{n_simulated_generations_breed_formation}\t{n_individuals_breed_formation}\t{chr_specific_recombination_rate}\n")

    try:
        trial_number = trial.number       
        row = top_n_results.iloc[trial_number]
        # Extract parameters for the current trial
        chr_simulated = str(row['Chr'])
        Ne_burn_in = int(row['NeBurnIn'])
        n_bottleneck = int(row['nBottleneck'])
        n_generations_bottleneck = int(row['nGenBottleneck'])
        n_simulated_generations_breed_formation = int(row['nGenBreed'])
        n_individuals_breed_formation = int(row['nBreed'])
        # Converting the chr specific recombination rate from a string to boolean
        chr_specific_recombination_rate = True if row['Chr_specific_recomb_rate'] == 'True' else False
        # Run the pipeline with the parameters from the selected row
        result = subprocess.run(['bash', 'run_pipeline_hyperoptimize_neutral_model_refined_optimization_top_n_perc_results.sh',
                                 str(HO_results_file), str(chr_simulated), str(Ne_burn_in),
                                 str(n_bottleneck), str(n_generations_bottleneck),
                                 str(n_simulated_generations_breed_formation),
                                 str(n_individuals_breed_formation), str(chr_specific_recombination_rate),],
                                capture_output=True, text=True)

        # Check if the pipeline ran successfully
        if result.returncode != 0:
            raise RuntimeError(f"Pipeline failed: {result.stderr}")

        # Read the cost function value from the last row of the results file
        df = pd.read_csv(HO_results_file_full_path, sep="\t")
        last_row = df.iloc[-1].astype(str)

        print(f"Comparing trial parameters to last row of results file:")
        print(f"chr_simulated: {str(chr_simulated).lower()} == {last_row['Chr'].lower()}")
        print(f"Ne_burn_in: {str(Ne_burn_in).lower()} == {last_row['NeBurnIn'].lower()}")
        print(f"n_bottleneck: {str(n_bottleneck).lower()} == {last_row['nBottleneck'].lower()}")
        print(f"n_generations_bottleneck: {str(n_generations_bottleneck).lower()} == {last_row['nGenBottleneck'].lower()}")
        print(f"n_simulated_generations_breed_formation: {str(n_simulated_generations_breed_formation).lower()} == {last_row['nGenBreed'].lower()}")
        print(f"n_individuals_breed_formation: {str(n_individuals_breed_formation).lower()} == {last_row['nBreed'].lower()}")
        print(f"chr_specific_recombination_rate: {str(chr_specific_recombination_rate).lower()} == {last_row['Chr_specific_recomb_rate'].lower()}")
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
        print(f"\n{'!' * 10}\n Error during trial: {e}\n{'!' * 10}\n")
        # Log the failed parameters
        log_failed_parameters(chr_simulated, Ne_burn_in, n_bottleneck,
                              n_generations_bottleneck, n_simulated_generations_breed_formation, n_individuals_breed_formation, chr_specific_recombination_rate)
        return float('inf')

# Load top n results
top_n_results=load_top_n_results(n_results,HO_input_results_file_full_path)
# start_entry = 119
# # Slice to keep entries start_entry (10) to top_n_results (200) (corresponding to index 9 to 199)
# top_n_results= top_n_results.iloc[start_entry-1:top_n_results]

# Create the study using a fixed sampler since trials are based on the top 100 results
study = optuna.create_study(direction='minimize')

# Run the optimization, limiting to 100 trials (since we have only 100 results)
study.optimize(objective, n_trials=n_results)

# Save the best hyperparameters
best_params = study.best_params
HO_best_params_file = f"best_hyperparameters_{HO_id}.json"
with open(HO_best_params_file, 'w') as f:
    json.dump(best_params, f)

print("Best hyperparameters:", best_params)
