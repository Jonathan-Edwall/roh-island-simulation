import os
import subprocess
import optuna
import json
import pandas as pd


import signal

import sys

# Function to handle user interruption
def signal_handler(sig, frame):

    print('Optimization interrupted. Exiting.')

    sys.exit(0)

# Register the signal handler
signal.signal(signal.SIGINT, signal_handler)

# Define the objective function
def objective(trial):
    # Define the directory and the path to the file where you want to log the failed rows
    output_dir = '/home/jonathan/hyperoptimizer_results'
    failed_trials_file = os.path.join(output_dir, 'failed_trials.tsv')
    # Define the header with tab separation
    # header = "Chr\tNeBurnIn\tnInd\tInbredFo\tNeBottleneck\tnGenBottleneck\tnGenBreed\tnBreed\tSNPchipRefPop\tMutations\tSim_H_e\tSim_H_e_5th_perc\tSim_F_ROH\tSim_ROH_hotspot_thr\tSim_Cost_Result\n"
    # header = "Chr\tNeBurnIn\tInbredFo\tNeBottleneck\tnGenBottleneck\tnGenBreed\tnBreed\tSNPchipRefPop\tMutations\tSim_H_e\tSim_H_e_5th_perc\tSim_F_ROH\tSim_ROH_hotspot_thr\tSim_Cost_Result\n"
    # header = "Chr\tNeBurnIn\tnInd\tInbredFo\tNeBottleneck\tnGenBottleneck\tnGenBreed\tnBreed\tSNPchipRefPop\tMutations\tSim_H_e\tSim_H_e_5th_perc\tSim_F_ROH\tSim_ROH_hotspot_thr\tSim_Cost_Result\n"
    # header = "Chr\tNeBurnIn\tnInd\tInbredFo\tNeBottleneck\tnGenBottleneck\tnGenBreed\tnBreed\tSNPchipRefPop\tMutations\tSim_H_e\tSim_H_e_5th_perc\tSim_F_ROH\tSim_ROH_hotspot_thr\tSim_Cost_Result\n"
    # header = "Chr\tNeBurnIn\tnInd\tInbredFo\tnBottleneck\tnGenBottleneck\tnGenBreed\tnBreed\tSNPchipRefPop\tMutations\tSim_F_ROH\tSim_ROH_hotspot_thr\tH_e_MAF_0_01\tH_e_5th_perc_MAF_0_01\tH_e_No_MAF\tH_e_5th_perc_No_MAF\tSim_Cost_Result"
    header = "Chr\tNeBurnIn\tnBottleneck\tnGenBottleneck\tnGenBreed\tnBreed\tChr_specific_recomb_rate\tSim_F_ROH\tSim_ROH_hotspot_thr\tH_e_MAF_0_01\tH_e_5th_perc_MAF_0_01\tH_e_No_MAF\tH_e_5th_perc_No_MAF\tSim_Cost_Result"

    # Function to append the failed parameters to the file
    def log_failed_parameters(chr_simulated, Ne_burn_in,n_bottleneck, n_generations_bottleneck, n_simulated_generations_breed_formation, n_individuals_breed_formation):
        file_exists = os.path.isfile(failed_trials_file)
        
        with open(failed_trials_file, 'a') as f:
            if not file_exists:
                f.write(header)
            f.write(
                f"{chr_simulated}\t{Ne_burn_in}\t{n_bottleneck}\t"
                f"{n_generations_bottleneck}\t{n_simulated_generations_breed_formation}\t{n_individuals_breed_formation}\t\n"

            )


    # # Function to append the failed parameters to the file
    # def log_failed_parameters(chr_simulated, Ne_burn_in,n_bottleneck, n_generations_bottleneck, n_simulated_generations_breed_formation, n_individuals_breed_formation, reference_population_for_snp_chip):
    #     file_exists = os.path.isfile(failed_trials_file)
        
    #     with open(failed_trials_file, 'a') as f:
    #         if not file_exists:
    #             f.write(header)
    #         f.write(
    #             f"{chr_simulated}\t{Ne_burn_in}\t{n_bottleneck}\t"
    #             f"{n_generations_bottleneck}\t{n_simulated_generations_breed_formation}\t{n_individuals_breed_formation}\t"
    #             f"{reference_population_for_snp_chip}\n"
    #         )


    try:
        #         # Extract parameters
        # chr_simulated = trial.suggest_categorical('chr_simulated', ["chr28", "chr1", "chr13", "chr3"])
        # Ne_burn_in = trial.suggest_int('Ne_burn_in',  50, 5000, step=25)
        # n_bottleneck = trial.suggest_int('n_bottleneck', 20, 125, step=5)
        # n_generations_bottleneck = trial.suggest_int('n_generations_bottleneck', 1, 20, step=1)
        # n_simulated_generations_breed_formation = trial.suggest_int('n_simulated_generations_breed_formation', 40, 80, step=5)
        # n_individuals_breed_formation = trial.suggest_int('n_individuals_breed_formation', 130, 170, step=25)
        # reference_population_for_snp_chip = trial.suggest_categorical('reference_population_for_snp_chip', ["last_breed_formation_generation", "last_bottleneck_generation"])

        # # Extract parameters
        # chr_simulated = trial.suggest_categorical('chr_simulated', ["chr28", "chr1","chr3"])
        # chr_simulated = trial.suggest_categorical('chr_simulated', ["chr28", "chr1", "chr13", "chr3"])
        chr_simulated = trial.suggest_categorical('chr_simulated', ["chr1", "chr2", "chr3", "chr9", "chr20", "chr21", "chr28", "chr38"])
        # chr_simulated = trial.suggest_categorical('chr_simulated', ["chr1","chr3"])
        Ne_burn_in = trial.suggest_int('Ne_burn_in',  100, 7000, step=5)
        n_bottleneck = trial.suggest_int('n_bottleneck', 5, 100, step=1)
        n_generations_bottleneck = trial.suggest_int('n_generations_bottleneck', 1, 15, step=1)
        n_simulated_generations_breed_formation = trial.suggest_int('n_simulated_generations_breed_formation', 40, 130, step=1)
        n_individuals_breed_formation = trial.suggest_int('n_individuals_breed_formation', 100, 650, step=5)
        chr_specific_recombination_rate = trial.suggest_categorical('chr_specific_recombination_rate', [True, False])
        # reference_population_for_snp_chip = trial.suggest_categorical('reference_population_for_snp_chip', ["last_breed_formation_generation", "last_bottleneck_generation"])
        # # Narrowing down to the best fit
        # chr_simulated = trial.suggest_categorical('chr_simulated', ["chr1","chr3"])
        # Ne_burn_in = trial.suggest_int('Ne_burn_in',  2000, 5000, step=5)
        # n_bottleneck = trial.suggest_int('n_bottleneck', 5, 30, step=1)
        # n_generations_bottleneck = trial.suggest_int('n_generations_bottleneck', 1, 3, step=1)
        # n_simulated_generations_breed_formation = trial.suggest_int('n_simulated_generations_breed_formation', 70, 110, step=1)
        # n_individuals_breed_formation = trial.suggest_int('n_individuals_breed_formation', 200, 550, step=5)
        # reference_population_for_snp_chip = trial.suggest_categorical('reference_population_for_snp_chip', ["last_breed_formation_generation"])


        # # Run the pipeline with the given parameters
        # result = subprocess.run(['bash', 'run_pipeline_hyperoptimize_neutral_model.sh',
        #                          chr_simulated, str(Ne_burn_in), 
        #                          str(n_bottleneck), str(n_generations_bottleneck),
        #                          str(n_simulated_generations_breed_formation),
        #                          str(n_individuals_breed_formation),
        #                          reference_population_for_snp_chip], capture_output=True, text=True)
        # Run the pipeline with the given parameters
        result = subprocess.run(['bash', 'run_pipeline_hyperoptimize_neutral_model.sh',
                                 chr_simulated, str(Ne_burn_in), 
                                 str(n_bottleneck), str(n_generations_bottleneck),
                                 str(n_simulated_generations_breed_formation),
                                 str(n_individuals_breed_formation),str(chr_specific_recombination_rate),
                                ], capture_output=True, text=True)


        # Check if the pipeline ran successfully
        if result.returncode != 0:
            raise RuntimeError(f"Pipeline failed: {result.stderr}")

        # Read the cost function value from the last row of the results file
        df = pd.read_csv("/home/jonathan/hyperoptimizer_results/neutral_models_cost_function_results.tsv", sep="\t")

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


        # if not (
        #     last_row["Chr"].lower() == str(chr_simulated).lower() and
        #     last_row["NeBurnIn"].lower() == str(Ne_burn_in).lower() and
        #     last_row["nBottleneck"].lower() == str(n_bottleneck).lower() and
        #     last_row["nGenBottleneck"].lower() == str(n_generations_bottleneck).lower() and
        #     last_row["nGenBreed"].lower() == str(n_simulated_generations_breed_formation).lower() and
        #     last_row["nBreed"].lower() == str(n_individuals_breed_formation).lower() and
        #     last_row["SNPchipRefPop"].lower() == str(reference_population_for_snp_chip).lower()
        # ):
        #     raise RuntimeError("Trial parameters do not match the last row of the results file.")           
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

# Create a study object
study = optuna.create_study(direction='minimize')

# Run the optimization
study.optimize(objective, n_trials=1000)
# study.optimize(objective, n_trials=2)

# Save the best hyperparameters
best_params = study.best_params
with open('best_hyperparameters.json', 'w') as f:
    json.dump(best_params, f)

print("Best hyperparameters:", best_params)

