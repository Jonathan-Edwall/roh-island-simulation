# Pipeline Code

This directory contains the core scripts for the analysis pipeline, along with hyperparameter optimization scripts.

**Note:** The bash (.sh) and Python (.py) scripts in this folder require manual modifications to specify data paths, the Anaconda environment path, and user-specific settings (such as simulation and analysis parameters, the maximum number of simulations to run in parallel etc).
These parameters are located at the top of each script. 

Scripts in `/pipeline_scripts` and `/remove_files_scripts` do not require modification when running the pipeline with "default" settings. However, they can be customized based on user preferences, for instance, to modify the ROH computation settings or adjust the genomic binning window size.

The `/Windows OS scripts` folder contains .rmd scripts made during the development of the .rmd scripts within `/pipeline_scripts`. These scripts may be useful for testing modifications of these scripts locally in a GUI environment, such as RStudio.

## Prerequisites
To make the scripts in this pipeline executable, follow these steps:
- Navigate to the `/code` directory.
- Run the following command to make all `.sh`, `.py`, and `.Rmd` files executable:

```bash
  find . -type f \( -name "*.sh" -o -name "*.py" -o -name "*.Rmd" \) -exec chmod +x {} \; 
```

## Gene Annotations and Phenotype mapping
To map genes to the identified ROH-hotspot regions, specify the correct gene annotation file in the `compressed_gene_annotations_file` parameter located in **`/pipeline_scripts/3_2_map_roh_hotspots_to_gene_annotations.sh`**. 

To map ROH hotspots to phenotypes, set `phenotype_file` to the correct BED file in **`pipeline_scripts/3_1_map_roh_hotspots_to_phenotypes.sh`**. For the study of dog breeds, phenotype files in `data/preprocessed/empirical/omia_dog_phenotype_data/` can be used.

## Empirical Dataset Analysis Pipeline

### Scripts

- **`run_pipeline.sh`**: Runs the main analysis pipeline.
- **`schedule_pipeline_runs.sh`**: Allows for scheduling multiple pipeline runs of the analysis pipeline with different settings.
  - **`run_pipeline_scheduled.sh`**: Executes the scheduled pipeline runs.

## Hyperparameter Optimization

### Prerequisites

Before starting the hyperparameter optimization, the empirical reference values need to be collected, which can be achieved in the following way:

1. Run **`run_pipeline.sh`**: It is recommended to run with one technical replicate (`n_simulation_replicates=1`) and disable selection model simulations (`selection_simulation=FALSE`), to quickly generate the empirical reference values, which will be used as parameters in the cost function of the hyperparameter optimization run.
2. Run **`Retrieve_empirical_data_for_HO.sh`**: This script will copy the data files containing information about the reference values and save it in the directory of the Hyperparameter Optimization data and results.

Once these steps are complete, you can proceed with hyperparameter optimization.

### Scripts

- **`optuna_hyperoptimize_pipeline.py`**: Main script for performing hyperparameter optimization.
  - **`run_pipeline_hyperoptimize_neutral_model.sh`**: Runs the analysis pipeline for the neutral model under trial in the optimization.

- **`optuna_hyperoptimize_pipeline_refined_optimization_top_n_perc_results.py`**: Script for refined optimization using the top `n` percent of results. This script can be used to increase the technical replicates to get a more well informed results from a prior hyperparameter optimization run.
  - **`run_pipeline_hyperoptimize_neutral_model_refined_optimization_top_n_perc_results.sh`**: Executes the analysis pipeline for the neutral model under trial in the hyperparameter optimization run.
  
- **`optuna_hyperoptimize_pipeline_grid_search_categorical_attributes.py`**: Alternative script using grid search for categorical parameters.
  - **`run_pipeline_hyperoptimize_neutral_model_grid_search_categorical_attributes.sh`**: Executes the analysis pipeline for the neutral model under trial in the hyperparameter optimization run.


