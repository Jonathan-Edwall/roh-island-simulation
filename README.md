# Computational Modeling of Genomic Inbreeding and Homozygosity Islands in Populations with Extremely Small Effective Sizes 

**Discerning Genomic Signals of Selection from Inbreeding: A Simulation-Based Approach Using Labrador Retrievers as a Case Study**

## Repository Overview

This repository contains a computational pipeline developed as part of a Master’s thesis project. This pipeline is made for discerning genomic signatures of selection from inbreeding  in empirical populations with extremely small effective population sizes.
The pipeline analyzes SNP-chip genotyped data from a chosen empirical dataset and runs simulations using [AlphaSimR](https://cran.r-project.org/web/packages/AlphaSimR/index.html).These simulations allow for selection testing of identified Runs of Homozygosity (ROH) hotspots (also known as ROH islands) from the empirical dataset and allows the user to estimate the selection strength (selection coefficient) of the discovered empirical candidate regions for selection.

The pipeline is currently developed for analysis of SNP-chip data from empirical dog breeds, however it could be modified to support other species by modifying the simulation scenarios. Additionally, the pipeline currently only supports the simulation of one chromosome per individual rather than full-scale simulation of the genome.
The empirical dataset used in the development of this pipeline is a [Labrador Retriever dataset from Matsumoto et al. (2023)](https://datadryad.org/stash/dataset/doi:10.5061/dryad.v6wwpzgw0)

To ensure that the population history of the simulated models aligns well with the empirical datasets, the repository includes hyperparameter optimization through the program Optuna, using a cost function developed in the master thesis project.

## Key Components

- **Identification of ROH and ROH Hotspots in the Empirical Dataset**: The pipeline identifies Runs of Homozygosity (ROH) and ROH hotspots within the provided dataset.
  
- **Selection Testing and Selection Strength Estimation**: The pipeline performs selection sweep tests using expected heterozygosity to identify selection within the empirical ROH hotspots. Subsequent analysis steps are also performed for the candidate regions of selection to estimate their selection strength (selection coefficient).
  
- **Population History Fine-tuning**: For better alignment with empirical dataset, scripts are available for hyperparameter optimization of the simulation models. This is done using the program Optuna, to refine the population histories in the simulations.

## Getting Started
Clone the repository and navigate to the /code directory to access provided scripts:
``` bash
git clone https://github.com/Jonathan-Edwall/roh-island-simulation.git
```

## Requirements
This pipeline was developed and tested with the following software versions (though other versions may work):
- R v4.3.3
- [AlphaSimR v1.4.2](https://cran.r-project.org/web/packages/AlphaSimR/readme/README.html) 
- Bedtools v2.30.0
- Optuna v4.0.0
- Python v3.9.7
- PLINK v1.90b6.21
- Selenium (optional for OMIA phenotype search)

### Setting Up the Anaconda Environment
To quickly install the necessary dependencies, the `conda-lock` file `roh_island_sim_env_lock_file.yml` can be used to create a conda environment named `roh_island_sim_env`, using the same package versions as the pipeline was developed under.  

To install the conda environment from the conda-lock file, do the following steps:
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
The pipeline assumes the conda environment is named `roh_island_sim_env`. If you choose a different environment name, be sure to update the environment name in the relevant bash files in the `/code` directory.