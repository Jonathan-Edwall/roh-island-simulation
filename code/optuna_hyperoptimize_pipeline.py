import os
import subprocess
import optuna
import json
import pandas as pd
import signal
import sys

HO_id = "test" # Name the Hyperparameter Optimization run
number_of_trials=5
HO_results_file = f"neutral_models_cost_function_results_{HO_id}.tsv"

# Dynamically determine the root directory one level up from the current script's directory
root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
path_to_results_folder = f"{root_dir}/hyperoptimizer_results"
HO_results_file_full_path = f"{path_to_results_folder}/{HO_results_file}"


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
    # Define the header with tab separation
    header = "Chr\tNeBurnIn\tnBottleneck\tnGenBottleneck\tnGenBreed\tnBreed\tChrSpecificRecombRate\n"
    # Function to append the failed parameters to the file
    def log_failed_parameters(chr_simulated, Ne_burn_in,n_bottleneck, n_generations_bottleneck, n_simulated_generations_breed_formation, n_individuals_breed_formation, chr_specific_recombination_rate):
        file_exists = os.path.isfile(failed_trials_file)
        with open(failed_trials_file, 'a') as f:
            if not file_exists:
                f.write(header)
            f.write(
                f"{chr_simulated}\t{Ne_burn_in}\t{n_bottleneck}\t"
                f"{n_generations_bottleneck}\t{n_simulated_generations_breed_formation}\t{n_individuals_breed_formation}\t{chr_specific_recombination_rate}\t\n"

            )
    try:
        # # Extract parameters
        chr_simulated = trial.suggest_categorical('chr_simulated', ["chr1", "chr2", "chr3", "chr9", "chr20", "chr21", "chr28", "chr38"])
        Ne_burn_in = trial.suggest_int('Ne_burn_in',  100, 7000, step=5)
        n_bottleneck = trial.suggest_int('n_bottleneck', 5, 100, step=1)
        n_generations_bottleneck = trial.suggest_int('n_generations_bottleneck', 1, 15, step=1)
        n_simulated_generations_breed_formation = trial.suggest_int('n_simulated_generations_breed_formation', 40, 130, step=1)
        n_individuals_breed_formation = trial.suggest_int('n_individuals_breed_formation', 100, 650, step=5)
        chr_specific_recombination_rate = trial.suggest_categorical('chr_specific_recombination_rate', [True, False])
        # Run the pipeline with the given parameters
        result = subprocess.run(['bash', 'run_pipeline_hyperoptimize_neutral_model.sh',
                                 str(HO_results_file),chr_simulated, str(Ne_burn_in), 
                                 str(n_bottleneck), str(n_generations_bottleneck),
                                 str(n_simulated_generations_breed_formation),
                                 str(n_individuals_breed_formation),str(chr_specific_recombination_rate),
                                ], capture_output=True, text=True)
        # Check if the pipeline ran successfully
        if result.returncode != 0:
            raise RuntimeError(f"Pipeline failed: {result.stderr}")
        # Read the cost function value from the last row of the results file
        df = pd.read_csv(HO_results_file_full_path, sep="\t")
        # Validate that the current trial is found in the last row of the cost_value results file. If not, the trial is faulty and should be skipped!
        last_row = df.iloc[-1].astype(str)
        print(f"Comparing trial parameters to last row of results file:")
        print(f"chr_simulated: {str(chr_simulated).lower()} == {last_row['Chr'].lower()}")
        print(f"Ne_burn_in: {str(Ne_burn_in).lower()} == {last_row['NeBurnIn'].lower()}")
        print(f"n_bottleneck: {str(n_bottleneck).lower()} == {last_row['nBottleneck'].lower()}")
        print(f"n_generations_bottleneck: {str(n_generations_bottleneck).lower()} == {last_row['nGenBottleneck'].lower()}")
        print(f"n_simulated_generations_breed_formation: {str(n_simulated_generations_breed_formation).lower()} == {last_row['nGenBreed'].lower()}")
        print(f"n_individuals_breed_formation: {str(n_individuals_breed_formation).lower()} == {last_row['nBreed'].lower()}")
        print(f"chr_specific_recombination_rate: {str(chr_specific_recombination_rate).lower()} == {last_row['Chr_specific_recomb_rate'].lower()}")
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
        log_failed_parameters(chr_simulated, Ne_burn_in, n_bottleneck,
                        n_generations_bottleneck, n_simulated_generations_breed_formation, n_individuals_breed_formation,chr_specific_recombination_rate )
        # # Log the failed parameters
        # log_failed_parameters(chr_simulated, Ne_burn_in, n_bottleneck,
        #                 n_generations_bottleneck, n_simulated_generations_breed_formation, n_individuals_breed_formation, reference_population_for_snp_chip)
        return float('inf')
    
# Create an Optuna study object
study = optuna.create_study(direction='minimize')
# Check if there already exists a file for the study
# If yes, then load the previous trials, before continuing
if os.path.exists(HO_results_file_full_path):    
    # Load previous trials from TSV
    df = pd.read_csv(HO_results_file_full_path, sep="\t", header=0)
    # Loading the (.add_trial) the previous trials to the study
    for _, row in df.iterrows():
        # Map the row to trial parameters
        trial_params = {
            'chr_simulated': str(row['Chr']),
            'Ne_burn_in': int(row['NeBurnIn']),
            'n_bottleneck': int(row['nBottleneck']),
            'n_generations_bottleneck': int(row['nGenBottleneck']),
            'n_simulated_generations_breed_formation': int(row['nGenBreed']),
            'n_individuals_breed_formation': int(row['nBreed']),
            # Converting the chr specific recombination rate from a string to boolean
            'chr_specific_recombination_rate': True if str(row['Chr_specific_recomb_rate']).lower() == 'true' else False
        }
        # Add the trial to the study
        study.add_trial(
            optuna.create_trial(
                params=trial_params,
                distributions={
                    'chr_simulated': optuna.distributions.CategoricalDistribution(['chr1', 'chr2', 'chr3', 'chr9', 'chr20', 'chr21', 'chr28', 'chr38']),
                    'Ne_burn_in': optuna.distributions.IntDistribution(100, 7000, step=5),
                    'n_bottleneck': optuna.distributions.IntDistribution(5, 100, step=1),
                    'n_generations_bottleneck': optuna.distributions.IntDistribution(1, 15, step=1),
                    'n_simulated_generations_breed_formation': optuna.distributions.IntDistribution(40, 130, step=1),
                    'n_individuals_breed_formation': optuna.distributions.IntDistribution(100, 650, step=5),
                    'chr_specific_recombination_rate': optuna.distributions.CategoricalDistribution([True, False]),
                },
                value=row['Sim_Cost_Result']
            )
        )
# Run the optimization
study.optimize(objective, n_trials=number_of_trials)
# Save the best hyperparameters
best_params = study.best_params
HO_best_params_file = f"best_hyperparameters_{HO_id}.json"
with open(HO_best_params_file, 'w') as f:
    json.dump(best_params, f)
print("Best hyperparameters:", best_params)

