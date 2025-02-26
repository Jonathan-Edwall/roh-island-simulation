# Computational Modeling of Genomic Inbreeding and Homozygosity Islands in Populations with Extremely Small Effective Sizes 

**Discerning Genomic Signals of Selection from Inbreeding: A Simulation-Based Approach Using Labrador Retrievers as a Case Study**

## Repository Overview

This repository contains a computational pipeline developed [as part of a Master’s thesis project](https://uu.diva-portal.org/smash/record.jsf?pid=diva2%3A1914778&dswid=-3416). This pipeline is made for discerning genomic signatures of selection from inbreeding  in empirical populations with extremely small effective population sizes.
The pipeline analyzes SNP-chip genotyped data from a chosen empirical dataset and runs simulations using [AlphaSimR](https://cran.r-project.org/web/packages/AlphaSimR/index.html). These simulations allow for selection testing of identified Runs of Homozygosity (ROH) hotspots (also known as ROH islands) from the empirical dataset, as well as estimating the selection strength (selection coefficient) of the identified candidate regions for selection.

The empirical dataset used in the development of this pipeline is a [Labrador Retriever dataset from Matsumoto et al. (2023)](https://datadryad.org/stash/dataset/doi:10.5061/dryad.v6wwpzgw0). To use a different dataset, place it in a new folder inside `/data/raw/empirical/`. Name this folder exactly as `"empirical_breed"`, where `"empirical_breed"` is equivalent to the value assigned to the `$empirical_breed` parameter in `/code/run_pipeline.sh`

The pipeline is currently designed for analyzing SNP-chip data from empirical dog breeds; however, it can be adapted for other species by:
- Modifying the simulation scenarios and adjusting the dog-specific settings/variable values in the AlphaSimR scripts.
- Defining the correct chromosomes and reference chromosome sizes for the studied species in the `chromosome_lengths_bp` variable of the script `code/pipeline_scripts/2_3_1_Window_file_creator_for_ROH_frequency_computation.sh`.

Additionally, it is noteworthy that the pipeline currently only supports the simulation of a single chromosome per individual rather than full-scale simulation of the genome.


To ensure that the population history of the simulated models aligns well with the empirical dataset, the repository includes hyperparameter optimization through the program Optuna, using a cost function developed in the Master's thesis project.

## Key Components of the Analysis Pipeline

- **Identification of ROH and ROH Hotspots in Empirical Data**: The pipeline identifies Runs of Homozygosity (ROH) and ROH hotspots within the provided dataset.

- **Population History Fine-tuning**: To better align the simulations with the empirical dataset, the pipeline includes scripts for hyperparameter optimization of the population histories of the simulation models, using Optuna.
  
- **Selection Testing and Selection Strength Estimation**: The pipeline performs selection sweep tests based on the expected heterozygosity of the neutral model to identify candidate regions for selection within the empirical ROH hotspots. Identified candidate regions for selection then undergo estimation of their selection strength (selection coefficient) using the simulated selection models.
  
- **Functional Assessment of Candidate Regions for Selection**: To assess the functionality of the detected empirical candidate regions, they are mapped against non-defect (non-disease-related) phenotypes fetched from OMIA.org as well as against genes from reference assemblies. For more information on how the phenotype file is constructed and requirements for the gene annotation file, see section **Gene Annotations and Phenotype mapping** in `./code` and `code/pipeline_scripts/OMIA_scraping`.
  
- **Generalizable**:
   The pipeline is designed to work with any SNP-chip dataset from populations with extremely small effective population sizes. Full functionality is maintained if the user provides correct phenotype and gene annotation files, along with appropriate simulation parameters (e.g., species-specific mutation and recombination rates, chromosome sizes and the extent of historical bottleneck scenarios etc.).
  - **Note:** This repository includes phenotype files for dogs, chickens, taurine cattle and more. Users can update outdated files or create new ones for additional species available on OMIA.org, using the phenotype scraping script in `code/OMIA_scraping`.

## Getting Started
Clone the repository and navigate to the /code directory to access provided scripts:
``` bash
git clone https://github.com/Jonathan-Edwall/roh-island-simulation.git
```

## Requirements
This pipeline was developed and tested with the following software versions (though other versions may work):
- [AlphaSimR v1.4.2](https://cran.r-project.org/web/packages/AlphaSimR/readme/README.html) 
- [Bedtools v2.30.0](https://bedtools.readthedocs.io/en/latest/#)
- [Optuna v4.0.0](https://optuna.readthedocs.io/en/stable/)
- [PLINK v1.90b6.21](https://www.cog-genomics.org/plink/)
- [Python v3.9.7](https://www.python.org/)
- [R v4.3.3](https://cran.r-project.org/) 
- [Selenium (optional for the OMIA phenotype scraping script)](https://www.selenium.dev/documentation/overview/details/) 

### Setting Up the Anaconda Environment
To quickly install the necessary dependencies, the `conda-lock` file `roh_island_sim_env_lock_file.yml` can be used to create a conda environment named `roh_island_sim_env`, which recreates the environment the pipeline was developed under.  

To install the conda environment from the conda-lock file, follow these steps:
1. **Ensure `conda-lock` package is installed:**
``` bash
conda install conda-forge::conda-lock
```
2. **Install the environment from the `conda-lock` file:**

The `roh_island_sim_env_lock_file.yml` lock file can be found in the root directory of this repository. Assuming that the lock file is in the current working directory, you can use the following command to install the environment: 
``` bash
conda-lock install --name roh_island_sim_env roh_island_sim_env_lock_file.yml
```
Once the environment is set up, you can run the pipeline using this Conda environment.

**Note:**
The pipeline assumes the Conda environment is named `roh_island_sim_env`. If you choose a different environment name, make sure to update the environment name in the relevant bash files in the `/code` directory.

## Example Results
To provide users with an example of the pipeline's output, an example result is available in the `/example_result` directory. This includes a summary HTML file generated from running the pipeline on the same empirical dataset used in the Master's thesis report, as well as example output from a Hyperparameter Optimization run.

The summarizing HTML file contains:
- A summary of the simulation models.
- Selection testing results, along with simulation results for simulations of selection on a causative variant under different selection pressures, to be used for estimating the selection coefficient of an identified candidate region for selection.
- Gene and phenotype mapping for candidate regions, serving as a starting point for their biological interpretation.

## Contact
For questions regarding this pipeline, feel free to contact me at: 
edwalljonathan@gmail.com