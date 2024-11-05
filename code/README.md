# Pipeline Code

This directory contains the core scripts for the analysis pipeline, along with hyperparameter optimization scripts.

**Note:** The bash and Python scripts in this folder require manual modifications to specify the data paths, Anaconda environment paths, and user-specific settings (such as simulation and analysis settings). These variables are located at the top of each script. Scripts within `/pipeline_scripts` and `/remove_files_scripts` do not require modification for the pipeline to function.

## Empirical Dataset Analysis Pipeline

### Scripts

- **`run_pipeline.sh`**: Runs the main analysis pipeline.
- **`schedule_pipeline_runs.sh`**: Allows for scheduling multiple runs of the analysis pipeline with different settings.
  - **`run_pipeline_scheduled.sh`**: Executes the scheduled pipeline runs.

## Hyperparameter Optimization

### Prerequisites

Before starting the hyperparameter optimization:

1. Run **`run_pipeline.sh`** (suggested with one technical replicate) to generate empirical reference values, which are required for the cost function during hyperparameter optimization.
2. Run **`Retrieve_empirical_data_for_HO.sh`** to retrieve and organize relevant data files from the empirical dataset for the optimization.

Once these steps are completed, the hyperparameter optimization can proceed.

### Scripts

- **`optuna_hyperoptimize_pipeline.py`**: Main script for performing hyperparameter optimization.
  - **`run_pipeline_hyperoptimize_neutral_model.sh`**: Executes the pipeline under a neutral model.

- **`optuna_hyperoptimize_pipeline_refined_optimization_top_n_perc_results.py`**: Script for refined optimization using the top `n` percent of results. This script can be run to increase the technical replicates from a prior hyperparameter optimization run
  - **`run_pipeline_hyperoptimize_neutral_model_refined_optimization_top_n_perc_results.sh`**: Executes refined optimization for the neutral model.
  
- **`optuna_hyperoptimize_pipeline_grid_search_categorical_attributes.py`**: Alternative script using grid search for categorical parameters.
  - **`run_pipeline_hyperoptimize_neutral_model_grid_search_categorical_attributes.sh`**: Runs the grid search-based optimization for the neutral model.
  

