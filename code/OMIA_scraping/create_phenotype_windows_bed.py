import csv
import os
from pathlib import Path 

"""
 #######                                                   
 #       #    # #    #  ####  ##### #  ####  #    #  ####  
 #       #    # ##   # #    #   #   # #    # ##   # #      
 #####   #    # # #  # #        #   # #    # # #  #  ####  
 #       #    # #  # # #        #   # #    # #  # #      # 
 #       #    # #   ## #    #   #   # #    # #   ## #    # 
 #        ####  #    #  ####    #   #  ####  #    #  ####  

"""



def should_exclude_row(row,Vertebrate_breed_ontology_dict,allow_defects,allow_all_breeds):
    considered_defect = row[6] 
    breeds = row[11].lower()  
    chr = row[0]
    pos1 = row[1]
    pos2 = row[2]
    excluded_chromosomes_list = ["x", "y","mt"]

    """
    Prune phenotypes considered as defects (Disease associated?)
    """    
    if allow_defects == False:
        if "yes" in considered_defect.lower():
            return True
    
    """
    Prune phenotypes that are not associated with
    the specified species in Vertebrate_breed_ontology_dict (Set to German shepherd dog by default) and/or non-breed-specific entries 
    """    
    if allow_all_breeds == False:
        if len(breeds) != 0:
            accepted_breed_check = False
            for breed, breed_id in Vertebrate_breed_ontology_dict.items():
                if breed_id.lower() in breeds:
                    accepted_breed_check == True
            if accepted_breed_check == False:
                return True

    """
    Prune phenotypes not associated with genes
    (otherwise no position of the phenotype is provided)
    """    

    if len(pos1) != 0 and len(pos2) != 0 and len(chr) != 0:
        if pos1 != "-" and pos2 != "-" and chr != "-":
            if chr in excluded_chromosomes_list:
                return True
        else:
            return True
    else:
        return True

    return False



def write_to_manual_inspection_file(file_path, rows):
    with open(file_path, mode='w', newline='', encoding='utf-8') as manual_inspection_file:
        csv_writer = csv.writer(manual_inspection_file)
        header_row=['CHR', 'POS1', 'POS2', 'PHENE', 'PHENE_CATEGORY','SINGLE_GENE_TRAIT_OR_DISORDER','DISEASE_RELATED', 'GENE_SYMBOL', 'GENE_DESCRIPTION', 'PHENE_URL', 'GENE_DETAILS_URL', 'BREEDS']
        csv_writer.writerow(header_row)
        csv_writer.writerows(rows)



def load_pruned_entries(file_path):
    pruned_entries = set()
    if not os.path.isfile(file_path):
        return pruned_entries

    with open(file_path, mode='r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        for row in reader:
            # Extracting the relevant columns to create a unique identifier for each row
            phene_url, gene_details_url = row[8:10]
            pruned_entries.add((phene_url, gene_details_url))
    return pruned_entries



def write_to_sorted_bed_file(file_path, rows):
    processed_rows = []
    for row in rows:        
        chr_val, pos1_val, pos2_val = row[:3]
        # Convert positions to integers
        pos1_val = int(pos1_val)
        pos2_val = int(pos2_val)
        # Ensure pos1 is smaller than pos2
        if pos1_val > pos2_val:
            # Swap positions if pos1 is larger
            pos1_val, pos2_val = pos2_val, pos1_val
        processed_rows.append([chr_val, pos1_val, pos2_val] + row[3:])
    
    def alphanumeric_key(chr_value):
        # Try converting to an integer; if not possible, keep it as a string
        try:
            return (int(chr_value),)  # Numeric chromosomes are sorted as numbers
        except ValueError:
            return (float('inf'), chr_value)  # Non-numeric chromosomes are sorted after numbers

    # Sort processed rows by chromosome (alphanumerically) and then by position
    sorted_rows = sorted(processed_rows, key=lambda x: (alphanumeric_key(x[0]), int(x[1])))


    # # Sort processed rows by chr and pos1
    # sorted_rows = sorted(processed_rows, key=lambda x: (int(x[0]), int(x[1])))
    # Write to file
    with open(file_path, mode='w', newline='', encoding='utf-8') as bed_file:
        # Write header
        bed_file.write("#CHR\tPOS1\tPOS2\tPHENE\tPHENE_CATEGORY\tSINGLE_GENE_TRAIT_OR_DISORDER\tDISEASE_RELATED\tGENE_SYMBOL\tGENE_DESCRIPTION\tPHENE_URL\tGENE_DETAILS_URL\tBREEDS\n")

        for row in sorted_rows:
            print(row)
            print(len(row))
            for el in row:
                print(el)
            # Ensure each row contains exactly 12 fields
            if len(row) != 12:
                raise ValueError("Each row must contain exactly 12 fields.")
            # Encapsulate fields 4 to 8 in quotes
            for i in range(3, 9):
                row[i] = f'"{row[i]}"' if row[i] else '""'
            # Set empty field 11 to "Unspecified"
            # row[-1] = f'"{row[-1]}" if row[-1] else '"Unspecified"
            row[-1] = f'"{row[-1]}"' if row[-1] else '"Unspecified"'
            # Write the row to the file
            bed_file.write('\t'.join(map(str, row)) + '\n')



"""
 #     #                    
 ##   ##    ##    #  #    # 
 # # # #   #  #   #  ##   # 
 #  #  #  #    #  #  # #  # 
 #     #  ######  #  #  # # 
 #     #  #    #  #  #   ## 
 #     #  #    #  #  #    #                            
"""
# Define species to scrape phenotype information from.
species = "dog"
# species = "gray wolf"
# species = "cat"
# species = "chicken"
# species = "taurine cattle"
# species = "pig"

# Get the path of the script
script_path = Path(__file__).resolve()
print(f"script_path={script_path}")
# Get the parent of the parent directory (i.e., two levels up), to get the path of the repository
repository_path = script_path.parent.parent.parent
print(f"repository_path={repository_path}")

# Define the input folder path relative to the determined main path
input_folder_path = repository_path / "data/raw/empirical/omia_scraped_phene_data"

# Specifying the input file
# input_folder_path = r"./data/raw/empirical/omia_scraped_phene_data"
input_filename = f"OMIA_{species}_phenotype_data_raw.csv"
input_file_path = os.path.join(input_folder_path, input_filename)

# Specifying the output file
# output_folder_path = r"./data/preprocessed/empirical/omia_phenotype_data"
output_folder_path = repository_path / "data/preprocessed/empirical/omia_phenotype_data"

# Option for setting whether the output .bed-file should include phenotypes labelled as "defect" (disease-related) (TRUE/FALSE)
allow_defects = True 

# Option for setting wheter the .bed file should only contain phenotypes associated with a particular breed, or contain all phenotypes associated with the species.
allow_all_breeds = True # True/False
breed = ""

if allow_defects == True and allow_all_breeds == True:
    output_filename = f"All_{species}_phenotypes.bed"
elif allow_defects == True and allow_all_breeds == False:
    output_filename = f"All_phenotypes_{breed}.bed"
elif allow_defects == False and allow_all_breeds == False:
    output_filename = f"All_non_defect_phenotypes_{breed}.bed"
elif allow_defects == False and allow_all_breeds == True:
    output_filename = f"All_non_defect_{species}_phenotypes.bed"

output_bed_file_path = os.path.join(output_folder_path, output_filename)
# Ensure the directory exists
os.makedirs(output_folder_path, exist_ok=True)

# To allow the user to remove recorded phenotypes entries which, for any reason, are deemed irrelevant, a .csv-file called "pruned_entries.csv" has been created. 
# Load not relevant genes
pruned_entries_path = "pruned_entries.csv"
pruned_entries = load_pruned_entries(pruned_entries_path)

"""
¤¤¤ Vertebrate Breed Ontology ID:s ¤¤¤
* If the user wants the bed-file to only include phenotypes belonging to a specific breed/breeds, enter the VBO ID in Vertebrate_breed_ontology_dict below.
Note: For the final analysis in the main pipeline (run_pipeline.sh), there is no requirement to perform any filtering based on breeds or defect-status, since the final step of filtering of the phenotypes
is done in pipeline_results.Rmd.
"""

Vertebrate_breed_ontology_dict  = {
        'german shepherd dog': "VBO_0200577",
        'german shepherd dog, double coat': "VBO_0200578",
        'german shepherd dog, long and harsh outer coat': "VBO_0200579",
        'german shepherd dog, non-white': "VBO_0200580",
        'german shepherd dog, old': "VBO_0200581",
        'german shepherd dog, white': "VBO_0200582",
    }
# # Initialize list to store rows for manual inspection
# manual_inspection_rows = []
output_rows = []

# Open the output bed file for writing
with open(output_bed_file_path, mode='w', newline='', encoding='utf-8') as output_bed_file:
    bed_writer = csv.writer(output_bed_file, delimiter='\t')
    header_row=['CHR', 'POS1', 'POS2', 'PHENE', 'PHENE_CATEGORY','SINGLE_GENE_TRAIT_OR_DISORDER','DISEASE_RELATED', 'GENE_SYMBOL', 'GENE_DESCRIPTION', 'PHENE_URL', 'GENE_DETAILS_URL', 'BREEDS']
    # Write the header row to the BED file
    bed_writer.writerow(header_row)
    # Process data from the first input file
    with open(input_file_path, mode='r', newline='', encoding='utf-8') as input_file:
        csv_reader = csv.reader(input_file)
        next(csv_reader)  # Skip the header row
        for row in csv_reader:
            phenotype_url, gene_details_url_val, breeds = row[8:11]
            if (phenotype_url, gene_details_url_val) in pruned_entries:
                print(phenotype_url, gene_details_url_val)
                # manual_inspection_rows.append(row)
                continue
            else:
                if should_exclude_row(row,Vertebrate_breed_ontology_dict,allow_defects,allow_all_breeds) == False:
                    output_rows.append(row)

write_to_sorted_bed_file(output_bed_file_path, output_rows)

print(f"Filtered .bed file created successfully: {output_bed_file_path}")
