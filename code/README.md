# Pipeline Code

This directory contains the core scripts for the analysis pipeline, along with hyperparameter optimization scripts.

**Note:** The bash (.sh) and Python (.py) core scripts (`/code`) of this folder require manual modifications to specify data paths, the Conda initialization script, and user-specific settings (such as simulation and analysis parameters, the maximum number of simulations to run in parallel etc). These parameters are located at the top of each script and the settings will be exported to the subscripts in `/pipeline_scripts` and `/remove_files_scripts`.

Scripts in `/pipeline_scripts` and `/remove_files_scripts` do not require modification when running the pipeline with "default" settings. However, they can be customized based on user preferences, for instance, to modify the ROH computation settings or adjust the genomic binning window size. Additionally, modifying the AlphaSimR (simulation) scripts and the `chromosome_lengths_bp` parameter in
 `./pipeline_scripts/2_3_1_Window_file_creator_for_ROH_frequency_computation.sh` would allow the pipeline to be used for species other than dogs.  

The `/OMIA_scraping` directory contains scripts for scraping and processing recorded phenotypes of a specific species from OMIA. These scripts are generalized to work for scraping phenotypes for any existing species on OMIA (such as dogs, cattle, chicken, etc). Instructions for setting up and using these scripts can be found within the directory. 

The `/Windows OS scripts` folder contains .rmd scripts created during the development of the `.rmd` scripts in `/pipeline_scripts`. These scripts may be useful for testing modifications locally in a GUI environment, such as RStudio.

The scripts in the `/gosling_scripts` folder generate Gosling.js. plots for visualizing the empirical ROH hotspots. These plots are not essential for the pipeline analysis, but could potentially be a useful tool for visualizing the ROH frequency of these hotspots and their surrounding regions.

## Prerequisites
To make the scripts in this pipeline executable, follow these steps:
- Navigate to the `/code` directory.
- Run the following command to make all `.sh`, `.py`, and `.Rmd` files executable:
```bash
  find . -type f \( -name "*.sh" -o -name "*.py" -o -name "*.Rmd" \) -exec chmod +x {} \; 
```

## Gene Annotations and Phenotype mapping
To map genes to the identified ROH-hotspot regions, specify the correct gene annotation file in the `gene_annotations_filepath` parameter in the main script (`run_pipeline.sh`).

To map ROH hotspots to phenotypes, set the correct `omia_scraped_phenotypes_data_filepath` and `omia_phenotypes_filepath` parameters in the main script. For studies of dog breeds, the predefined default phenotype files in `data/preprocessed/empirical/omia_scraped_phene_data` and `data/preprocessed/empirical/omia_phenotype_data/` can be used. Additionally, ensure that the correct VBO ID(s) are set in the `vertebrate_breed_ontology_ids` parameter in the main script (`run_pipeline.sh`).

## Empirical Dataset Analysis Pipeline

### Scripts

- **`run_pipeline.sh`**: Runs the main analysis pipeline.
- **`schedule_pipeline_runs.sh`**: Allows for scheduling multiple pipeline runs of the analysis pipeline with different settings.
  - **`run_pipeline_scheduled.sh`**: Executes the scheduled pipeline runs.

## Hyperparameter Optimization

### Prerequisites

Before starting the hyperparameter optimization, gather the necessary empirical reference values by following these steps:

1. Run **`run_pipeline.sh`**: It is recommended to run with one technical replicate (`n_simulation_replicates=1`) and disable selection model simulations (`selection_simulation=FALSE`), to quickly generate the empirical reference values, which will be used as parameters in the cost function of the hyperparameter optimization run.
2. Run **`Retrieve_empirical_data_for_HO.sh`**: This script copies the data files containing information about the reference values and saves them in the directory designated for the Hyperparameter Optimization data and results.

Once these steps are complete, you can proceed with hyperparameter optimization.

### Scripts
- **`optuna_hyperoptimize_pipeline.py`**: Main script for performing hyperparameter optimization.
  - **`run_pipeline_hyperoptimize_neutral_model.sh`**: Runs the analysis pipeline for the neutral model under trial in each optimization trial.

- **`optuna_hyperoptimize_pipeline_refined_optimization_top_n_perc_results.py`**: Script for refined optimization using the top `n` percent of results. This script can be used to increase the technical replicates to get more well informed results from a prior hyperparameter optimization run.
  - **`run_pipeline_hyperoptimize_neutral_model_refined_optimization_top_n_perc_results.sh`**: Executes the analysis pipeline for the neutral model under trial in the hyperparameter optimization run.
  
- **`optuna_hyperoptimize_pipeline_grid_search_categorical_attributes.py`**: Alternative script using grid search for categorical parameters.
  - **`run_pipeline_hyperoptimize_neutral_model_grid_search_categorical_attributes.sh`**: Executes the analysis pipeline for the neutral model under trial in the hyperparameter optimization run.

### Running the scripts
To execute these optuna scripts, ensure that the required conda environment is activated.
For example, **`optuna_hyperoptimize_pipeline.py`** can be run in the following way:
``` bash
conda activate roh_island_sim_env && python optuna_hyperoptimize_pipeline.py
```