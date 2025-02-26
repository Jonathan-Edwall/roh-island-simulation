import os
import time
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.edge.service import Service
from webdriver_manager.microsoft import EdgeChromiumDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import WebDriverException
from selenium.common.exceptions import NoSuchElementException
import time
import csv
import sys
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



def load_existing_rows(csv_file_path):
    """
    Function that loads the phenotype file which have been recorded previously, to skip these and optimize the run.

    Args:
    - csv_file_path: Path to the phenotype CSV file. Default: ./code/OMIA_scraping/omia_phenotype_data_raw.csv
    """
    existing_rows = set()
    visited_phenotype_urls = set()
    if not os.path.isfile(csv_file_path):
        return existing_rows,visited_phenotype_urls  # Return empty set if file doesn't exist
    with open(csv_file_path, mode='r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader, None)  # Skip the header row
        for row in reader:
            # Extracting the relevant fields to create a unique identifier for each row
            phene_url, gene_details_url = row[9:11]
            existing_rows.add((phene_url, gene_details_url))
            visited_phenotype_urls.add(phene_url)
    return existing_rows,visited_phenotype_urls



def write_phenotype_info_to_csv(csv_writer, existing_rows, phenotype_info_dict, gene_info_dict):
    """
    Write phenotype information to the CSV file.

    Args:
    - csv_writer: CSV writer object
    - existing_rows: Set containing existing (phenotype_url, gene_details_url) tuples
    - phenotype_info_dict: Dictionary containing phenotype information
    - gene_info_dict: Dictionary containing gene information    
    """
    # Extract phenotype information
    phene = phenotype_info_dict.get('phene', '')
    category_val = phenotype_info_dict.get('category_val', '')
    single_gene_val = phenotype_info_dict.get('single_gene_val', '')
    disease_related_val = phenotype_info_dict.get('disease_related_val', '')
    phenotype_url = phenotype_info_dict.get('phenotype_url', '')
    breeds_val = ', '.join(phenotype_info_dict.get('breeds_val', []))
    # Extract gene-related information
    chr_val = gene_info_dict.get('chr','')
    pos1_val = gene_info_dict.get('pos1', '')
    pos2_val = gene_info_dict.get('pos2', '')
    gene_symbol_val = gene_info_dict.get('symbol', '')
    gene_description_val = gene_info_dict.get('description', '')
    gene_details_url_val = gene_info_dict.get('gene_details_url', '')

    row_key = (phenotype_url, gene_details_url_val)  # Tuple key for duplicate checking
    if row_key in existing_rows:
        print(f"Skipping duplicate row with phenotype_url: {phenotype_url} & gene: {gene_symbol_val}")
    else:
        # Write the row to the CSV file
        csv_writer.writerow([
            chr_val, pos1_val, pos2_val, phene, category_val, single_gene_val,
            disease_related_val, gene_symbol_val, gene_description_val,
            phenotype_url, gene_details_url_val, breeds_val
        ])
        # Add the row key to existing_rows to avoid future duplicates
        existing_rows.add(row_key)



def extract_gene_info_from_table(csv_writer, existing_rows, phenotype_info_dict,gene_info_dict,table,base_url):
    headers = None
    rows = table.find_all('tr')
    for i, row in enumerate(rows):
        row_data_dict = gene_info_dict.copy()
        # Skip the first row as it contains headers
        if i == 0:
            headers = [header.text.strip() for header in row.find_all('th')]
            continue
        cells = row.find_all('td')
        if len(cells) != len(headers):
            # Skip rows with incorrect number of cells
            continue
        for header, cell in zip(headers, cells):
            header = header.lower()  # Normalize header text
            if header == 'chr':
                row_data_dict['chr'] = cell.text.strip()
            elif header == 'location':
                # Extract pos1 and pos2 from the location string
                location_text = cell.text.strip()
                start, end = location_text.split('(')[1].split(')')[0].split('..')
                pos1 = start.split()[0]  # Extract the first part as pos1
                pos2 = end.split()[0]    # Extract the second part as pos2
                row_data_dict['pos1'] = pos1.strip()
                row_data_dict['pos2'] = pos2.strip()
            elif header == 'symbol':
                row_data_dict['symbol'] = cell.text.strip()
            elif header == 'description':
                row_data_dict['description'] = cell.text.strip()
            elif header == 'omia gene details page':
                # Extract gene details href
                gene_details_href = cell.find('a')['href'].strip()
                gene_details_url = f"{base_url}{gene_details_href}"
                row_data_dict['gene_details_url'] = gene_details_url
        # Writing the genetic information to the csv
        write_phenotype_info_to_csv(csv_writer, existing_rows, phenotype_info_dict, row_data_dict)



def extract_phenotype_specific_info(driver, phenotype_url, csv_writer, existing_rows, phene, base_url):
    pheno_page_loading_time = 10
    sleep_debugging = 500

    driver.get(phenotype_url)
    time.sleep(pheno_page_loading_time)
    page_source = driver.page_source
    soup = BeautifulSoup(page_source, 'html.parser')
    body = soup.find('body')
    record_details_div = body.find('div', class_='record_details')
    phenotype_info_dict = {
        'phene': phene,
        'phenotype_url': phenotype_url,
        'category_val': '',
        'single_gene_val': '',
        'disease_related_val': '',
        'breeds_val': []
    }
    # Preallocating a dictionary with empty values, for storing genetic information of each phenotype
    gene_info_dict = {
        'chr': '',
        'pos1': '',
        'pos2': '',
        'symbol': '',
        'description': '',
        'gene_details_url': ''
    }
    # If record_details_div is found on the page
    if record_details_div:
        # Iterate through each element
        for p_element in record_details_div.find_all('p'):
            # Find all elements with class "record_details_heading"
            detail_header_element = p_element.find('span', class_='record_details_heading')
            if detail_header_element:
                detail_header = detail_header_element.text.strip()
            else:
                #  Skip the iteration when the p-element is empty (like: <p></p> )
                continue
            detail_value = p_element.find('span').next_sibling.strip()
            if "categories" in detail_header.lower():
                phenotype_info_dict['category_val'] = p_element.find('a').text.strip()
            elif "single-gene trait/disorder" in detail_header.lower():
                phenotype_info_dict['single_gene_val'] = detail_value
            elif "disease-related" in detail_header.lower():
                phenotype_info_dict['disease_related_val'] = detail_value
            elif "breed" in detail_header.lower():
                breed_tags = p_element.find_all('a')
                phenotype_info_dict['breeds_val'].extend([tag.text.strip().split('(')[0].strip() for tag in breed_tags])
    print(f" {phenotype_info_dict}")   
    gene_table = False    
    tables = body.find_all('table')
    for table in tables:
        # Get all table headers
        headers = table.find_all('th')
        header_texts = [header.text.strip() for header in headers]
        # Check if the required headers are present
        if 'Symbol' in header_texts and 'Description' in header_texts and 'Location' in header_texts:
            extract_gene_info_from_table(csv_writer, existing_rows, phenotype_info_dict,gene_info_dict,table,base_url)
            gene_table = True
    if not gene_table: 
        write_phenotype_info_to_csv(csv_writer, existing_rows, phenotype_info_dict, gene_info_dict)
        # time.sleep(sleep_debugging)




def scrape_phenotype_data(driver, csv_writer, existing_rows,visited_phenotype_urls,species_id):
    # Time configurations
    search_pheno_loading_time = 10
    sleep_time_after_url_visited = 1
    sleep_debugging = 500
    base_url = "https://www.omia.org"
    search_pheno_url = f"{base_url}/results/?gb_species_id={species_id}&search_type=advanced"
    try:
        counter = 0
        driver.get(search_pheno_url)
        time.sleep(search_pheno_loading_time)
        page_source = driver.page_source
        soup = BeautifulSoup(page_source, 'html.parser')
        body = soup.find('body')
        table_div = body.find('div', class_='dataTables_scroll')
        table = table_div.find('table', id='PheneTable')
        table_body = table.find('tbody') #<tbody>
        phenotype_entries_discovered = table_body.find_all('tr', role='row')
        num_phenotypes = len(phenotype_entries_discovered)
        counter = 0


        # Iterate over each data entry in the table
        for row in phenotype_entries_discovered:
            counter +=1
            # Extract data from each column in the row
            columns = row.find_all('td')
            # Assuming there are 7 columns in each row
            if len(columns) == 7:
                omia_id = columns[0].text.strip()
                phene = columns[1].text.strip()
                species_scientific_name = columns[2].text.strip()
                species_common_name = columns[3].text.strip()
                gene = columns[4].text.strip()
                year_key_mutation_first_reported = columns[5].text.strip()
                date_last_modified = columns[6].text.strip()

                # Extracting phene_entry_id for accessing the URL of the entry                            
                phene_entry_id = omia_id.split(":")[1].split("-")[0] # Split the omia_id based on the delimiter "-"
                phenotype_url = f"{base_url}/OMIA{phene_entry_id}/{species_id}/"
                
                """
                Optimizing the script by skipping accessing phenotype pages that already has entries 
                * If you think phenotype pages might have new information you want to add, then avoid this check
                by commenting it away.                        
                """
                if (phenotype_url) in visited_phenotype_urls:
                    print(f"Skipping previously visited phenotype url page: {phenotype_url}")                
                    continue
                extract_phenotype_specific_info(driver,phenotype_url,csv_writer,existing_rows,phene,base_url)
            
            """
            Progressbar styling
            """
            progress = counter / num_phenotypes
            bar_length = 30
            filled_length = int(bar_length * progress)
            bar = "█" * filled_length + "-" * (bar_length - filled_length)

            # print(f"Scraped data for {counter}/{num_phenotypes} phenotypes)")
            sys.stdout.write(f"\rScraping phenotypes: [{bar}] {counter}/{num_phenotypes} ({progress*100:.1f}%)\n")
            sys.stdout.flush()
    except Exception as e:
        print(f"Error accessing omia.org: {e}") 



"""
 #     #                    
 ##   ##    ##    #  #    # 
 # # # #   #  #   #  ##   # 
 #  #  #  #    #  #  # #  # 
 #     #  ######  #  #  # # 
 #     #  #    #  #  #   ## 
 #     #  #    #  #  #    #                            
"""

# Record the start time
start_time = time.time()
"""
¤¤¤¤¤¤¤¤¤¤¤¤
GUI driver (Open Selenium driver)
¤¤¤¤¤¤¤¤¤¤¤¤¤¤
"""

# Create EdgeOptions and configure settings
options = webdriver.EdgeOptions()
options.add_argument('--ignore-certificate-errors')
options.add_argument('log-level=3')  # This sets the console log level to SEVERE

service = Service(EdgeChromiumDriverManager().install())

# Create an instance of the Edge WebDriver.
# The version and location is automatically managed and options are applied
driver = webdriver.Edge(service=service, options=options)
########################################
OMIA_Species_ID_dict = {'dog': 9615, 'taurine cattle': 9913, 'cat': 9685, 'pig': 9823, 'sheep': 9940, 'horse': 9796, 'chicken': 9031, 'rabbit': 9986, 'goat': 9925, 'japanese quail': 93934,
            'indicine cattle (zebu)': 9915, 'golden hamster': 10036, 'rhesus monkey': 9544, 'crab-eating macaque': 9541, 'water buffalo': 89462, 'turkey': 9103, 'guinea pig': 10141,
            'ass (donkey)': 9793, 'llama': 9844, 'american mink': 452646, 'rock pigeon': 8932, 'alpaca': 30538, 'mallard': 8839, 'japanese medaka': 8090, 'white-tufted-ear marmoset': 9483,
            'lion': 9689, 'arabian camel': 9838, 'ferret': 9669, 'north american deer mouse': 10042, 'chimpanzee': 9598, 'yak': 30521, 'tiger': 9694, 'gray wolf': 9612, 'mouflon': 9938,
            'mule': 319699, 'atlantic salmon': 8030, 'nile tilapia':8128, 'goldfish': 7957, 'red fox': 9627, 'ducks': 8835, 'aoudad': 9899, 'meadow voles': 10053, 'common canary': 9135,
            'mongolian gerbil': 10047, 'rainbow trout': 8022, 'cheetah': 32536,'Western roe deer': 9858, 'raccoon dog': 34880, 'snow leopard': 29064, 'goose': 8843}


# Define species to scrape phenotype information from.
# The options of species to select from can be seen from the keys of OMIA_Species_ID_dict {OMIA_Species_ID_dict.keys()} 

species = "dog"
# species = "gray wolf"
# species = "cat"
# species = "chicken"
# species = "taurine cattle"
# species = "pig"

print(f"Searching for species: {species}, with OMIA Species ID: {OMIA_Species_ID_dict[species.lower()]}\n")


# Get the path of the script
script_path = Path(__file__).resolve()
# Get the parent of the parent directory (i.e., two levels up), to get the path of the repository
repository_path = script_path.parent.parent.parent

# Define the input folder path relative to the determined main path
output_folder_path = repository_path / "data/raw/empirical/omia_scraped_phene_data"
# input_folder_path = r"./data/raw/empirical/omia_scraped_phene_data"

output_filename = f"OMIA_{species}_phenotype_data_raw.csv"
csv_file_path = os.path.join(output_folder_path, output_filename)
# Ensure the directory exists
os.makedirs(output_folder_path, exist_ok=True)

# Load existing rows from the CSV file 
existing_rows,visited_phenotype_urls = load_existing_rows(csv_file_path)

# Open CSV file in append mode (mode='a') with UTF-8 encoding
with open(csv_file_path, mode='a', newline='', encoding='utf-8', buffering=1) as file:
    csv_writer = csv.writer(file)
    if file.tell() == 0:
        header_row=['CHR', 'POS1', 'POS2', 'PHENE', 'PHENE_CATEGORY','SINGLE_GENE_TRAIT_OR_DISORDER','DISEASE_RELATED', 'GENE_SYMBOL', 'GENE_DESCRIPTION', 'PHENE_URL', 'GENE_DETAILS_URL', 'BREEDS']
        csv_writer.writerow(header_row)

    species_id = OMIA_Species_ID_dict[species.lower()]
    scrape_phenotype_data(driver, csv_writer, existing_rows,visited_phenotype_urls, species_id)
    # Flush the file buffer to ensure immediate write
    file.flush()
# Calculate the elapsed time
end_time = time.time()
elapsed_time_seconds = end_time - start_time
# Convert seconds to minutes and seconds
elapsed_minutes, elapsed_seconds = divmod(elapsed_time_seconds, 60)
print(f"Script execution time: {int(elapsed_minutes)} minutes and {elapsed_seconds:.2f} seconds")