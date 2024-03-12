import os
import pandas as pd

def generate_hom_files(input_file):
    # Read the input .hom file into a DataFrame
    df = pd.read_csv(input_file, delim_whitespace=True)

    # Group the data by IID
    grouped = df.groupby('IID')

    # Iterate over each group
    for iid, group_df in grouped:
        # Generate filename with IID as prefix
        output_file = f"{iid}_ROH.hom"

        # Create subfolder for output files
        output_folder = os.path.join(os.path.dirname(input_file), "individual_roh")
        os.makedirs(output_folder, exist_ok=True)  # Create folder if it doesn't exist

        # Write the group data to a new .hom file in the subfolder
        output_path = os.path.join(output_folder, output_file)
        group_df.to_csv(output_path, sep='\t', index=False)

if __name__ == "__main__":

    # Specify the path to the input .hom file
    PLINK_results_path = "PLINK/results/PLINK"
    sample_path = "empirical/doi_10_5061_dryad_h44j0zpkf__v20210813/german_shepherd_ROH.hom"
    input_path = os.path.join(PLINK_results_path, sample_path)
    
    # Generate separate .hom files for each IID
    generate_hom_files(input_path)
