# Example Results
This directory contains example outputs from the pipeline. It includes a summary HTML file generated from running the pipeline on the same empirical dataset used in the Master's thesis report, as well as example output from a Hyperparameter Optimization run.

The summary HTML file can be viewed in any browser and contains:
- Summary of the simulation models and the empirical dataset.
- Selection test results, along with simulation results for selection on a causative variant under different selection pressures, to be used for estimating the selection coefficient of an identified candidate region for selection.
- Gene and phenotype mapping for candidate regions, serving as a starting point for their biological interpretation.


**Note**: the folders `/Pipeline_results_No_MAF`, `Pipeline_results_MAF_0_01` and `Pipeline_results_MAF_0_05` contain the pipeline results with different MAF thresholds for the MAF-based pruning of markers prior to the expected heterozygosity computation. These folders include all result files generated after a completed pipeline run, including the HTML file and files derived from the plots and tables in the summary HTML file.