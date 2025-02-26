# OMIA Scraping Scripts

This directory contains scripts for scraping and processing recorded phenotypes of a specific species from OMIA. These scripts are generalized to work for scraping phenotypes for any existing species on OMIA (such as dogs, cattle, chicken, etc.; for the full list of available species, see the keys of the dictionary *OMIA_Species_ID_dict* in `OMIA_phenotype_scraping.py`).
### Scripts

- **`OMIA_phenotype_scraping.py`**: Script for fetching all existing phenotypic data from OMIA for the specified species.
- **`create_phenotype_windows_bed.py`**: Script that creates a *.bed-file* of the fetched phenotypes linked to genes with specified genomic coordinates. 

**Note:** These scripts are not integrated into the main pipeline and the necessary libraries must be installed manually, as they are **not** included in the default conda environment. Additionally, these scripts have been developed for usage on Windows OS and macOS systems. They can also, in theory, be run on Linux, provided that Selenium has been correctly configured beforehand.    

## Prerequisites
The following programs/libraries are required to be installed before running the scripts:
- **Microsoft Edge** (Web browser)
- **Selenium** (Python library)
- **BeautifulSoup4** (Python library)
- **WebDriver Manager** (Python library)

---
## Set up instructions
Follow these steps to set up the environment and run the scripts:
| Step                     | Instructions                                                                                                                                                               |
|--------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **1. Install Libraries**  | Assuming Python is already installed, the required Python libraries can be installed with any of the following commands: **Via conda:** `conda install -c conda-forge selenium beautifulsoup4 webdriver-manager`. **Via pip:** `pip install selenium beautifulsoup4 webdriver-manager` (Windows) or `pip3 install selenium beautifulsoup4 webdriver-manager` (macOS).                                                                                       |
| **2. Install Edge Browser** | Install the Edge browser from [Microsoft's official page](https://www.microsoft.com/edge). **(Not required for Windows OS users, as Edge is already a pre-installed browser)** .                 |
| **3. Run the Script**      | After setting up the environment, **OMIA_phenotype_scraping.py** can be run from any IDE (e.g., Visual Studio Code) to scrape phenotypic data from OMIA for the species defined in the `species` parameter. **Note:** No EdgeDriver installation is necessary separately, as WebDriver-Manager will automatically handle the download and installation of EdgeDriver when the script is executed. |
