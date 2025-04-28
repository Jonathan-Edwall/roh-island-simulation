# Pipeline Code

This directory contains the core scripts for the analysis pipeline, along with hyperparameter optimization scripts and a configuration script for the pipeline.

The bash (.sh) and Python (.py) core scripts of this `/code` folder require manual modifications to specify user-specific settings such as simulation and analysis parameters, population history settings and the maximum number of parallel simulations. **These settings are located at the top of each script** and will be exported to the subscripts in `/pipeline_scripts` and `/remove_files_scripts` during the pipeline run.

**Note:** This directory also includes a configuration script, `config.sh`, which lets the user specify general pipeline settings such as path to the conda initialization script, information about the empirical dataset and the studied species and relevant files for phenotype and gene mapping. For more information, **see Section 1.1**.

Scripts in `/pipeline_scripts` and `/remove_files_scripts` do not require modification when running the pipeline with "default" settings. However, they can be customized based on user preferences, such as modifying ROH computation settings, data preprocessing or adjusting the genomic binning window size. 
Additionally, the AlphaSimR simulation scripts can be modified to accommodate species whose population histories are inadequately modeled by the demographic events implemented in this pipeline, which by default models an outbred population undergoing a bottleneck event followed by a  subsequent population expansion.  
 - **Note:** The demographic events used in the simulation models have been selected to capture the population history of modern dog breeds. Specifically, simulations begin with coalescent simulations of an outbred dog population to generate a founder population. This founder population then undergoes a bottleneck event mimicking the formation of modern dog breeds, followed by a subsequent population size expansion to represent the population size growth of modern dog breeds. 

The `/OMIA_scraping` directory contains scripts for scraping and processing recorded phenotypes of a specific species from OMIA. These scripts are generalized to work for scraping phenotypes for any existing species on OMIA (such as dogs, cattle, chicken, etc). Instructions for setting up and using these scripts can be found within the directory. 

The `/Windows OS scripts` folder contains .rmd scripts created during the development of the `.rmd` scripts in `/pipeline_scripts`. These scripts may be useful for testing modifications locally in a GUI environment, such as RStudio.

The scripts in the `/gosling_scripts` folder generate Gosling.js. plots for visualizing the empirical ROH hotspots. These plots are not essential for the pipeline analysis, but could potentially be a useful tool for visualizing the ROH frequency of these hotspots and their surrounding regions.

## 1. Prerequisites
To make the scripts in this pipeline executable, follow these steps:
- Navigate to the `/code` directory.
- Run the following command to make all `.sh`, `.py`, and `.Rmd` files executable:
```bash
  find . -type f \( -name "*.sh" -o -name "*.py" -o -name "*.Rmd" \) -exec chmod +x {} \; 
```

### 1.1 Configuration file (`config.sh`)
Before using the pipeline, you muist modify the configuration file `config.sh` to specify the species to study, simulation settings, path to anaconfa etc.
More specifically the following settings must be specified:
- **`conda_setup_script_path`**: Path to the Conda initialization script
- **`empirical_species`**: Species of the empirical dataset (affects for instance species-specific options in PLINK)
- **`empirical_breed`**: Species/breed studied
- **`empirical_raw_data_basename`**: Basename of the raw empirical dataset files
- **`empirical_autosomal_chromosomes`**: Range of empirical autosomal chromosomes to include in the analysis
- **`mutation_rate`**: Mutation rate for the studied species, used in the coalescent simulations and subsequent forward simulations if `introduce_mutations=TRUE`)
- **`chromosome_recombination_rates_cM_per_Mb`**: Specifies the chromosome specific recombination rates for the studied species
- **`gene_annotations_filepath`**: Path to the gene annotation file to be used for mapping genes to the identified empirical ROH hotspot regions.
- **`omia_scraped_phenotypes_data_filepath`** & **`omia_phenotypes_filepath`**: OMIA Phenotype annotation files to be used in the mapping of ROH hotspots to phenotypes. The former refers to the scraped (raw) phenotype file from OMIA, while the latter refers to the OMIA phenotype .bed file.
  -  **Note:** Premade phenotypes files exists for the study of dogs, cat, chicken, pig, gray wolf and taurine cattle (last updated 2025-04-24). These can be found in `data/preprocessed/empirical/omia_scraped_phene_data` and `data/preprocessed/empirical/omia_phenotype_data/` respectively. 
- **`vertebrate_breed_ontology_ids`**: A list of Vertebrate Breed Ontology ID:s to use for associating phenotypes with the studied species.

More detailed information about these variables can be found in the `config.sh` script which also includes example inputs based on the analysis of Labrador retriever dogs.


## 2. Empirical Dataset Analysis Pipeline
### 2.1 Prerequisites
#### 2.1.1 Gene Annotations and Phenotype mapping
To ensure accurate mapping of phenotypes and genes to the identified ROH hotspot regions, make sure that the `omia_scraped_phenotypes_data_filepath`, `omia_phenotypes_filepath` and (`gene_annotations_filepath`) parameters are correctly specified in `config.sh`.

### 2.2 Scripts

- **`run_pipeline.sh`**: Runs the main analysis pipeline.
- **`schedule_pipeline_runs.sh`**: Allows for scheduling multiple pipeline runs of the analysis pipeline with different settings.
  - **`run_scheduled_pipeline_runs.sh`**: Executes the scheduled pipeline runs.

#### 2.2.1 Running the scripts
The analysis pipeline scripts can be executed as regular bash scripts.
To run a single pipeline analysis use:
``` bash
bash ./run_pipeline.sh
```
To schedule multiple analyses, use:
``` bash
bash ./schedule_pipeline_runs.sh
```
## 3. Hyperparameter Optimization

### 3.1 Prerequisites

Before starting the hyperparameter optimization, gather the necessary empirical reference values by following these steps:

1. Run **`run_pipeline.sh`**: It is recommended to run with one technical replicate (`n_simulation_replicates=1`) and disable selection model simulations (`selection_simulation=FALSE`), to quickly generate the empirical reference values, which will be used as parameters in the cost function of the hyperparameter optimization run.
2. Run **`Retrieve_empirical_data_for_HO.sh`**: This script copies the data files containing information about the reference values and saves them in the directory designated for the Hyperparameter Optimization data and results.

Once these steps are completed, you can proceed with the hyperparameter optimization.

### 3.2 Scripts
- **`optuna_hyperoptimize_pipeline.py`**: Main script for performing hyperparameter optimization.
  - **`run_pipeline_hyperoptimize_neutral_model.sh`**: Runs the analysis pipeline for the neutral model under trial in each optimization trial.

- **`optuna_hyperoptimize_pipeline_refined_optimization_top_n_perc_results.py`**: Script for refined optimization using the top `n` percent of results. This script can be used to increase the technical replicates to get more well informed results from a prior hyperparameter optimization run.
  - **`run_pipeline_hyperoptimize_neutral_model_refined_optimization_top_n_perc_results.sh`**: Executes the analysis pipeline for the neutral model under trial in the hyperparameter optimization run.
  
- **`optuna_hyperoptimize_pipeline_grid_search_categorical_attributes.py`**: Alternative script using grid search for categorical parameters.
  - **`run_pipeline_hyperoptimize_neutral_model_grid_search_categorical_attributes.sh`**: Executes the analysis pipeline for the neutral model under trial in the hyperparameter optimization run.

#### 3.2.1 Running the scripts
To run these Optuna scripts, the Conda environment `roh_island_sim_env` must be activated, which can be achieved by running the configuration script **`config.sh`**. For example, to run the script **`optuna_hyperoptimize_pipeline.py`**, the following command can be used: 
``` bash
source ./config.sh && python3 optuna_hyperoptimize_pipeline.py
```