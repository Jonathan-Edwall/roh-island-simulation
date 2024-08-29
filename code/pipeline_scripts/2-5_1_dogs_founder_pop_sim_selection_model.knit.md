---
title: "Selection Scenario simulation for Dogs in AlphaSimR"
output:
  html_document:
    toc: true
    toc_depth: 3  
date: "2024-06-30"
editor_options: 
  markdown: 
    wrap: 72
---

# 0: Preparation

## Defining the output directory & the chromosome to be simulated


```r
# Clean the working environment
rm(list = ls())

knitr::opts_chunk$set(echo = TRUE)

#################################### 
# Defining Input parameters
#################################### 

chromosome_end_margin <- 0.15 # The chosen causative variant must be positioned at least within  15 % of the chromosome ends
s <- as.numeric(Sys.getenv("selection_coefficient")) # using as.numeric, otherwise class(s) = "character"
# Print the value of selection_coefficient
cat("Selection Coefficient:", s, "\n")
```

```
## Selection Coefficient: 0.8
```

```r
allele_copies_threshold <- 5 # 10 default (candidate_variants = less than 10)
# min_allowed_gen_before_variant_lost <- 10 # Pruning replicates where the causative variant gets lost within this timespan
fixation_threshold_causative_variant <- as.numeric(Sys.getenv("fixation_threshold_causative_variant"))
# fixation_threshold_causative_variant <- 0.99
disappearance_threshold_value_to_terminate_script <- as.numeric(Sys.getenv("disappearance_threshold_value_to_terminate_script"))



# min_MAF <- 0.05 #(minimum allowed Minor Allele Frequency for each SNP)
chr_simulated <- Sys.getenv("chr_simulated")
chr_simulated
```

```
## [1] "chr3"
```

```r
# Extract the chromosome number and convert and convert it to numeric
chr_number <- as.numeric(sub("chr", "", chr_simulated))

# N_e_burn_in <- 2500 # Ancestral population
N_e_burn_in <- as.numeric(Sys.getenv("Ne_burn_in")) # Ancestral population

nInd_founder_population <- as.numeric(Sys.getenv("nInd_founder_population")) # Founder population

Inbred_ancestral_population <- as.logical(Sys.getenv("Inbred_ancestral_population"))

# N_e_bottleneck <- 50
N_e_bottleneck <- as.numeric(Sys.getenv("N_e_bottleneck"))

n_generations_bottleneck <- as.numeric(Sys.getenv("n_generations_bottleneck")) # 5 default


n_generations_mate_selection <-  as.numeric(Sys.getenv("n_simulated_generations_breed_formation"))  # The number of generations to simulate during the mate selection scenario of modern dog breeds
n_generations_mate_selection
```

```
## [1] 94
```

```r
n_indv_breed_formation <- as.numeric(Sys.getenv("n_individuals_breed_formation")) # using as.numeric, otherwise class(n_indv_breed_formation) = "character"
n_indv_breed_formation
```

```
## [1] 370
```

```r
Ref_pop_snp_chip <- Sys.getenv("reference_population_for_snp_chip")

# introduce_mutations <- as.logical("FALSE")
introduce_mutations <- as.logical("TRUE")

snp_density_Mb <- as.numeric(Sys.getenv("selected_chr_snp_density_mb")) 
snp_density_Mb
```

```
## [1] 88.37
```

```r
#################################### 
# Defining the output files
#################################### 
output_sim_files_basename <- Sys.getenv("output_sim_files_basename")

# Define the output directory based on the variable passed from the Bash script
output_dir_simulation <- Sys.getenv("output_dir_selection_simulation")
output_dir_simulation
```

```
## [1] "/home/jonathan/data/raw/simulated/selection_model"
```

```r
# Ensure that output_dir_simulation is defined
if (is.null(output_dir_simulation)) {
  stop("output_dir_simulation is not provided.")
}

simulation_prune_count_file <- Sys.getenv("simulation_prune_count_file")
variant_positions_file <- Sys.getenv("variant_positions_file")

image_output_dir <- paste0(output_dir_simulation, "/variant_freq_plots")


Sys.getenv()
```

```
## _CE_CONDA               
## _CE_M                   
## _R_CHECK_COMPILATION_FLAGS_KNOWN_
##                         -Wformat -Werror=format-security -Wdate-time
## chr_simulated           chr3
## CONDA_DEFAULT_ENV       plink
## CONDA_EXE               /home/martin/anaconda3/bin/conda
## CONDA_PREFIX            /home/martin/anaconda3/envs/plink
## CONDA_PREFIX_1          /home/martin/anaconda3
## CONDA_PROMPT_MODIFIER   (plink)
## CONDA_PYTHON_EXE        /home/martin/anaconda3/bin/python
## CONDA_SHLVL             2
## data_dir                /home/jonathan/data
## DBUS_SESSION_BUS_ADDRESS
##                         unix:path=/run/user/1008/bus
## disappearance_threshold_value_to_terminate_script
##                         20
## DISPLAY                 localhost:12.0
## EDITOR                  vi
## empirical_dog_breed     labrador_retriever
## empirical_preprocessed_data_basename
##                         labrador_retriever_filtered
## empirical_processing    TRUE
## fixation_threshold_causative_variant
##                         0.99
## HOME                    /home/jonathan
## Inbred_ancestral_population
##                         FALSE
## Introduce_mutations     FALSE
## LANG                    en_US.UTF-8
## LD_LIBRARY_PATH         /usr/lib/R/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/default-java/lib/server
## LESSCLOSE               /usr/bin/lesspipe %s %s
## LESSOPEN                | /usr/bin/lesspipe %s
## LN_S                    ln -s
## LOGNAME                 jonathan
## LS_COLORS               rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:
## MAKE                    make
## max_parallel_jobs_selection_sim
##                         2
## MOTD_SHOWN              pam
## N_e_bottleneck          5
## n_generations_bottleneck
##                         2
## n_individuals_breed_formation
##                         370
## n_simulated_generations_breed_formation
##                         94
## n_simulation_replicates
##                         20
## Ne_burn_in              3700
## nInd_founder_population
##                         5
## num_markers_preprocessed_empirical_dataset
##                         201850
## num_markers_raw_empirical_dataset
##                         220853
## OLDPWD                  /home/jonathan/data/raw/simulated/selection_model
## output_dir_selection_simulation
##                         /home/jonathan/data/raw/simulated/selection_model
## output_sim_files_basename
##                         sim_20_selection_model_s08_chr3
## PAGER                   /usr/bin/pager
## PATH                    /home/martin/anaconda3/envs/plink/bin:/home/martin/anaconda3/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
## PWD                     /home/jonathan/data/raw/simulated/selection_model
## R_ARCH                  
## R_BROWSER               xdg-open
## R_BZIPCMD               /bin/bzip2
## R_DOC_DIR               /usr/share/R/doc
## R_GZIPCMD               /bin/gzip -n
## R_HOME                  /usr/lib/R
## R_INCLUDE_DIR           /usr/share/R/include
## R_LIBS_SITE             /usr/local/lib/R/site-library/:/usr/lib/R/site-library:/usr/lib/R/library
## R_LIBS_USER             /home/jonathan/R/x86_64-pc-linux-gnu-library/4.2
## R_PAPERSIZE             letter
## R_PAPERSIZE_USER        letter
## R_PDFVIEWER             /usr/bin/xdg-open
## R_PLATFORM              x86_64-pc-linux-gnu
## R_PRINTCMD              /usr/bin/lpr
## R_RD4PDF                times,inconsolata,hyper
## R_SESSION_TMPDIR        /tmp/RtmpmO7ere
## R_SHARE_DIR             /usr/share/R/share
## R_STRIP_SHARED_LIB      strip --strip-unneeded
## R_STRIP_STATIC_LIB      strip --strip-debug
## R_SYSTEM_ABI            linux,gcc,gxx,gfortran,gfortran
## R_TEXI2DVICMD           /usr/bin/texi2dvi
## R_UNZIPCMD              /usr/bin/unzip
## R_ZIPCMD                /usr/bin/zip
## reference_population_for_snp_chip
##                         last_breed_formation_generation
## results_dir             /home/jonathan/results
## SED                     /bin/sed
## selected_chr_preprocessed_snp_density_mb
##                         88.37
## selected_chr_snp_density_mb
##                         88.37
## selection_coefficient   0.8
## selection_simulation    TRUE
## SHELL                   /bin/bash
## SHLVL                   2
## simulation_prune_count_file
##                         /home/jonathan/data/raw/simulated/selection_model/pruned_counts/pruned_replicates_count_s08_chr3.tsv
## SSH_CLIENT              172.21.30.174 51346 22
## SSH_CONNECTION          172.21.30.174 51346 77.235.253.16 22
## SSH_TTY                 /dev/pts/3
## TAR                     /bin/tar
## TERM                    xterm-256color
## USER                    jonathan
## variant_positions_file
##                         /home/jonathan/data/raw/simulated/selection_model/variant_position/variant_position_s08_chr3.tsv
## XDG_DATA_DIRS           /usr/local/share:/usr/share:/var/lib/snapd/desktop
## XDG_RUNTIME_DIR         /run/user/1008
## XDG_SESSION_CLASS       user
## XDG_SESSION_ID          6910
## XDG_SESSION_TYPE        tty
```

```r
# # Verify the current working directory
#getwd()
```

## Loading libraries


```r
library(AlphaSimR)
```

```
## Loading required package: R6
```

```r
library(knitr)
```

```
## Warning: package 'knitr' was built under R version 4.3.2
```

# 1: Creating founder Haplotypes

## 1.0: Defining chromosome lengths of model species


```r
# Chromosome lengths of the dog autosome, derived from the canine reference assembly UU_Cfam_GSD_1.0,
# which can be found through this link:
# https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_011100685.1/

chromosome_lengths_bp <- c(
"chr1" = 123556469, "chr2" = 84979418, "chr3" = 92479059, "chr4" = 89535178	, "chr5" = 89562946, 
"chr6" = 78113029	, "chr7" = 81081596, "chr8" = 76405709, "chr9" = 61171909, "chr10" = 70643054, 
"chr11" = 74805798, "chr12" = 72970719, "chr13" = 64299765, "chr14" = 61112200, "chr15" = 64676183, 
"chr16" = 60362399, "chr17" = 65088165, "chr18" = 56472973, "chr19" = 55516201, "chr20" = 58627490, 
"chr21" = 51742555, "chr22" = 61573679, "chr23" = 53134997, "chr24" = 48566227, "chr25" = 51730745, 
"chr26" = 39257614, "chr27" = 46662488, "chr28" = 41733330, "chr29" = 42517134, "chr30" = 40643782, 
"chr31" = 39901454, "chr32" = 40225481, "chr33" = 32139216, "chr34" = 42397973, "chr35" = 28051305, 
"chr36" = 31223415, "chr37" = 30785915, "chr38" = 24803098	
)
```

## 1.1: runMacs2() - Generating founder population

`runMacs2` Parameters:

-   nInd = 100: 100 individuals in the founder population

-   nChr = 1: Haplotypes are created for 1 chromosome per individual

-   Ne = 2500: Effective population size: 2500 (Ne)

-   bp: base pair length of chromosome

-   genLen = 1: Genetic length of chromosome in Morgans, set as 1.

-   HistNe = NULL: No effective population size defined from previous
    generations (histNe = NULL)

-   histGen = NULL: If HistNe was defined, this parameter would define
    the number of generations ago we had the Ne defined in HistNe


```r
#help(runMacs2)

model_chromosome_bp_length <- chromosome_lengths_bp[chr_simulated] 


founderGenomes <- runMacs2(nInd = nInd_founder_population ,
                     nChr = 1,
                     Ne = N_e_burn_in,
                     bp = model_chromosome_bp_length,
                     inbred = Inbred_ancestral_population,
                     genLen = 1,
                     histNe = NULL,
                     histGen = NULL)


# Inspecting the founderGenomes object
founderGenomes
```

```
## An object of class "MapPop" 
## Ploidy: 2 
## Individuals: 5 
## Chromosomes: 1 
## Loci: 98045
```

## 1.2: SimParam() - Setting Global Simulation Parameters


```r
#help(SimParam)

# Creating a new Simparam object & Assigning the founder population population to it
SP <- SimParam$new(founderGenomes)
# SP
```

### 1.2.1: \$setTrackRec() - Setting on recombination tracking for the simulation

Sets recombination tracking for the simulation. By default recombination
tracking is turned off. **When turned on recombination tracking will
also turn on pedigree tracking.**

**Recombination tracking keeps records of all individuals created,**
except those created by hybridCross, because their pedigree is not
tracked.


```r
SP$setTrackRec(TRUE)
```

## 1.3: newPop() - Creating two separate populations for bottleneck event


```r
# Generate the initial founder population
founderpop <- newPop(founderGenomes, simParam = SP)
# # Set misc used for setting years of birth for the first individuals
# current_generation <- 0
# founderpop <- setMisc(x = founderpop,
#                    node = "generation",
#                    value = current_generation)
# head(getMisc(x = founderpop, node = "generation"))
# 
# Split the founder population into two breeding groups
breed1_founders <- founderpop[1:N_e_bottleneck] # 1:50
cat("Population 1:\n")
```

```
## Population 1:
```

```r
breed1_founders
```

```
## An object of class "Pop" 
## Ploidy: 2 
## Individuals: 5 
## Chromosomes: 1 
## Loci: 98045 
## Traits: 0
```

```r
# breed2_founders <- founderpop[(N_e_bottleneck + 1):(2 * N_e_bottleneck)] # 51:100
# cat("Population 2:\n")
# breed2_founders
```

# 2: Forward in time simulation

## 2.0: Defining Random Mating function (random_mating) - randCross()

`randCross()` simulates random mating.

-   **nCrosses**-argument specifies how many times an individual in the
    population can be a parent. In this case, an individual can only be
    a parent once (random mating)

-   **nProgeny**-argument specifies how many progeny's each mating pair
    can have. In this case, this parameter is set at 1 progeny per
    mating pair.

-   **simParam**-argument specifies the global simulation parameters


```r
random_mating <- function(pop, SP, n_gen, introduce_mutations) {
    n_ind <- pop@nInd # Extracting number of individuals in the current population
    generations <- vector(length = n_gen + 1,
                          mode = "list") 
    generations[[1]] <- pop # The initial breeding group population gets stored as the first element
    
    # Simulating random mating to perform simulation of the 2nd until the n+1:th generation
    # Each mating Progenys are generated using randcross
    for (gen_ix in 2:(n_gen + 1)) {
        generations[[gen_ix]] <- randCross(pop=generations[[gen_ix - 1]], nCrosses = n_ind, nProgeny = 1,
                                           simParam = SP)
        # Introducing mutations
        if (introduce_mutations == TRUE) {
          generations[[gen_ix]] <- AlphaSimR::mutate(generations[[gen_ix]], simParam = SP)
        }

        
    }
     random_mating_generations <- generations[-1] #all generations except for the founder population gets returned (the simulated generations derived from the bottleneck)
    
    return(random_mating_generations)
}
```
## 2.1: Bottleneck Simulation 

### 2.1.1 Simulating 5 generations of bottleneck (Random Mating)


```r
# Simulating random mating within each breeding group for 5 generations
breed1_bottleneck <- random_mating(breed1_founders, SP, n_generations_bottleneck,introduce_mutations)
```


### 2.1.2 Extracting the final bottleneck generation


```r
# Viewing the output

# founders
founderpop
```

```
## An object of class "Pop" 
## Ploidy: 2 
## Individuals: 5 
## Chromosomes: 1 
## Loci: 98045 
## Traits: 0
```

```r
breed1_bottleneck
```

```
## [[1]]
## An object of class "Pop" 
## Ploidy: 2 
## Individuals: 5 
## Chromosomes: 1 
## Loci: 98045 
## Traits: 0 
## 
## [[2]]
## An object of class "Pop" 
## Ploidy: 2 
## Individuals: 5 
## Chromosomes: 1 
## Loci: 98045 
## Traits: 0
```

```r
# Extracting final generation:
last_bottleneck_generation <- breed1_bottleneck[[n_generations_bottleneck]]

cat("Extracting the final generation from the Bottleneck Scenario")
```

```
## Extracting the final generation from the Bottleneck Scenario
```

```r
last_bottleneck_generation
```

```
## An object of class "Pop" 
## Ploidy: 2 
## Individuals: 5 
## Chromosomes: 1 
## Loci: 98045 
## Traits: 0
```
## 2.2: Adding SNPs to the last bottleneck generation - SimParam\$addSnpChip() 
`SP$addSnpChip()` Randomly assigns eligible SNPs to a SNP chip.

**nSnpPerChr**-argument that assigns for each individuals n SNPs for
each chromsome, where n is the user-specified number.

**minSnpFreq**-argument sets the Minimum Allele Frequency (MAF) allowed
for each marker. For instance, setting minSnpFreq = 0.05 ensures that
all markers will have MAF \>= 0.05

**refPop**-argument specifies which population will be genotyped. In
this case, it will be the last_bottleneck_generation after the simulated population
bottleneck scenario.


```r
model_chromosome_Mb_length <- model_chromosome_bp_length / (10^6)

num_snp_markers_simulated_chromosome <- snp_density_Mb * model_chromosome_Mb_length


if (num_snp_markers_simulated_chromosome > founderGenomes@nLoci) {
  cat("Reference amount of SNP markers for ",chr_simulated, ": ",num_snp_markers_simulated_chromosome)
  cat("\n",num_snp_markers_simulated_chromosome," > ",founderGenomes@nLoci)
  cat("\n Burn in N_e: ", N_e_burn_in,"\n")

  
  num_snp_markers_simulated_chromosome <- founderGenomes@nLoci
  
  new_SNP_density <- num_snp_markers_simulated_chromosome / model_chromosome_Mb_length
  cat("\n Old SNP density: ",snp_density_Mb," markers/Mb")
  cat("\n New SNP density: ",new_SNP_density," markers/Mb")


} else {
  cat("Reference amount of SNP markers for ",chr_simulated, ": ",num_snp_markers_simulated_chromosome)
  cat("\n",num_snp_markers_simulated_chromosome," < ",founderGenomes@nLoci)
  cat("\n Burn in N_e: ", N_e_burn_in,"\n")

}
```

```
## Reference amount of SNP markers for  chr3 :  8172.374
##  8172.374  <  98045
##  Burn in N_e:  3700
```

```r
# SP$addSnpChip(
#   nSnpPerChr = num_snp_markers_simulated_chromosome,
#   minSnpFreq = min_MAF,
#   refPop = last_bottleneck_generation
#   )

# Check if Ref_pop_snp_chip is equal to last_bottleneck_generation
if (Ref_pop_snp_chip == "last_bottleneck_generation") {
  SP$addSnpChip(
    nSnpPerChr = num_snp_markers_simulated_chromosome,
    refPop = last_bottleneck_generation
  )
}
```

## 2.3 Simulating the selection scenario - makeCross()

`makeCross()` Parameters:

### 2.3.1 find_causative_variant() - Function for finding the causative variant


```r
find_causative_variant <- function(population,SP, allele_copies_threshold,chromosome_end_margin,model_chromosome_bp_length) {
  minimum_position_buffer_from_chromosome_end <- 100001
  
  upper_boundary_position_margin <- model_chromosome_bp_length - minimum_position_buffer_from_chromosome_end
  lower_boundary_position_margin <- minimum_position_buffer_from_chromosome_end

  # # Boundaries based out of relative position
  # upper_boundary_chromosome_margin <- 1 - chromosome_end_margin
  # lower_boundary_chromosome_margin <- chromosome_end_margin
  
  # Extract the genetic map 
  gen_map <- getGenMap(founderGenomes)
  
  # Count occurrences of each variant
  count <- colSums(pullSegSiteGeno(last_bottleneck_generation, simParam = SP))
  
  # Find candidate variants (less than or equal to the threshold)
  candidate_variants <- which(count <= allele_copies_threshold)
  
  # Find a candidate variant within 
  success <- FALSE
  while (!success) {
    # Randomly pick one of the candidate variants as the causative variant
    variant <- candidate_variants[sample(1:length(candidate_variants), 1)]
    variant_SNP_ID <- names(variant)
    
    # Determine the position of the variant on the genetic map 
    variant_relative_SNP_POS <- gen_map[gen_map$id == variant_SNP_ID, ]
    variant_SNP_POS <- round(variant_relative_SNP_POS$pos * (model_chromosome_bp_length))
    
    # True Position: Check if the causative variant has been fixated  
    if (variant_SNP_POS >= lower_boundary_position_margin &&  variant_SNP_POS <= upper_boundary_position_margin) {
      success <- TRUE
      causative_variant <- variant
    }    

  
  
    # # Relative position: Check if the causative variant has been fixated  
    # if (variant_relative_SNP_POS$pos >= lower_boundary_chromosome_margin &&  variant_relative_SNP_POS$pos <= upper_boundary_chromosome_margin) {
    #   success <- TRUE
    #   causative_variant <- variant
    # }    
    
  }

  
  

  return(causative_variant)
}
```


### 2.3.2 Defining the Mate selection function - Mate_Selection_scenario()


```r
Mate_Selection_scenario <- function(selection_scenario_pop,SP, n_generations_mate_selection,n_indv_breed_formation,introduce_mutations, causative_variant,s) {
  
    # Creating a vector to store the allele frequency of the causative variant over the selection simulation generations
    f_causative <- numeric(n_generations_mate_selection)
    
    generations <- vector(length = n_generations_mate_selection + 1,
                          mode = "list") 
  
    
    generations[[1]] <- selection_scenario_pop # The initial breeding group population gets stored as the first element
      
    # Simulating random mating to perform simulation of the 2nd until the n+1:th generation
    # Each mating Progenys are generated using randcross
    for (gen_ix in 2:(n_generations_mate_selection + 1)) {
      
        # Retrieves the genotype of the causative variant for each individual in the population  
        geno <- pullSegSiteGeno(generations[[gen_ix - 1]], simParam = SP)[, causative_variant]
        # cat("\nGeneration", gen, "Geno:",geno)  
        
        #     # Print out the genotype of each individual
        # for (i in 1:length(geno)) {
        #   if (geno[i] == 2) {
        #     cat("Generation", gen, "- Individual", i, "is homozygous for the causative variant (AA)\n")
        #   } else if (geno[i] == 1) {
        #     cat("Generation", gen, "- Individual", i, "is heterozygous (Aa)\n")
        #   } else if (geno[i] == 0) {
        #     cat("Generation", gen, "- Individual", i, "is homozygous for the non-causative variant (aa)\n")
        #   }
        # }
        
        # Set fitness based on genotype
        fitness <- rep(1-s, length(geno))
        fitness[geno == 1] <- 1 - (s/2)
        fitness[geno == 2] <- 1
        
        # Initialize vectors for parents
        parent1 <- integer(n_indv_breed_formation)
        parent2 <- integer(n_indv_breed_formation)
        
        # Biased sampling of parents based on fitness
        # Create mating pairs
        for (i in 1:n_indv_breed_formation) {
            # Sample parent1
            parent1[i] <- sample(1:generations[[gen_ix - 1]]@nInd, 1, replace = TRUE, prob = fitness)
            # Ensure parent2 is different from parent1
            repeat {
                parent2[i] <- sample(1:generations[[gen_ix - 1]]@nInd,1, replace = TRUE, prob = fitness)
                if (parent2[i] != parent1[i]) break
            }
        }
        
        # Crossing parents to create next generation
        generations[[gen_ix]] <- makeCross(generations[[gen_ix - 1]],
                                            cbind(parent1, parent2),
                                            nProgeny = 1,
                                            simParam = SP)
        
        # Introducing mutations
        if (introduce_mutations == TRUE) {
          generations[[gen_ix]] <- AlphaSimR::mutate(generations[[gen_ix]], simParam = SP)
        }
  
        # Calculate allele frequency of the causative variant
        f_causative[gen_ix] <- sum(geno) / length(geno) / 2
  }
    
  selection_scenario_pop_final_generation <- generations[[n_generations_mate_selection+1]] # Final generation extracted
  
  return(list(f_causative,selection_scenario_pop_final_generation))
  
}
```
### 2.3.3 Simulating the selection scenario - makeCross()

```r
# Create a counter for tracking the amount of pruned replicates 
# due to the causatative variant getting lost within min_allowed_gen_before_variant_lost generations
disappearance_counter <- 0

# # Extract the highest IID in the population from the post bottleneck scenario
# last_bottleneck_IID <- max(last_bottleneck_generation@id)

# Define the rerun mechanism
success <- FALSE
while (!success) {
  
  # Function to randomly pick out a causative variant to be studied
  causative_variant <- find_causative_variant(last_bottleneck_generation, SP, allele_copies_threshold,chromosome_end_margin,model_chromosome_bp_length)
  # Print the chosen causative variant
  cat("Variant chosen:", causative_variant)

  # Sets the initial population for the selection scenario to the last generation of the bottleneck simulation.
  selection_scenario_pop <- last_bottleneck_generation
  
  # Run the simulation, starting with the last generation of the bottleneck simulation as 
  # The initial population for the selection scenario
  result <- Mate_Selection_scenario(selection_scenario_pop,SP, n_generations_mate_selection,n_indv_breed_formation,introduce_mutations,causative_variant,s)

  f_causative <- result[[1]]
  
  fixation_threshold_causative_variant 
    
  # Check if the causative variant has been fixated  
  if (max(f_causative) >= fixation_threshold_causative_variant) {
    success <- TRUE
    last_mate_selection_generation <- result[[2]]
    causative_variant_SNP_ID <- names(causative_variant)
    #SP$addSnpChipByName(causative_variant_SNP_ID) # Creating a SNP chip only consisting of this causative variant
    # Future change?: create a new snp chip that includes the markers from the original snp chip + this causative variant SNPdes the causative variant

  } else { 
    # Increment the pruned replicates counter
    disappearance_counter <- disappearance_counter + 1
    #SP$resetPed(lastId = last_bottleneck_IID)
    #SP$resetPed()

    if  (disappearance_counter >= disappearance_threshold_value_to_terminate_script ) {  
      # knitr::knit_exit(fully = TRUE) 
      quit(status=1) # Terminate the script if the condition is met
      } 
    else {
    cat("Causative variant disappeared, rerunning simulation...\n")
    cat("f_causative:", f_causative, "\n")
    
    }
    
    
    
  }
  
}
```

```
## Variant chosen: 8129
```


```r
#last_mate_selection_generation <- selection_scenario_pop[[n_generations_mate_selection]]

cat("Population before the selection scenario simulation:\n")
```

```
## Population before the selection scenario simulation:
```

```r
last_bottleneck_generation
```

```
## An object of class "Pop" 
## Ploidy: 2 
## Individuals: 5 
## Chromosomes: 1 
## Loci: 98045 
## Traits: 0
```

```r
cat("\nPopulation after",n_generations_mate_selection,"generations of selection scenario simulation:\n")
```

```
## 
## Population after 94 generations of selection scenario simulation:
```

```r
last_mate_selection_generation
```

```
## An object of class "Pop" 
## Ploidy: 2 
## Individuals: 370 
## Chromosomes: 1 
## Loci: 98045 
## Traits: 0
```

```r
# Check if Ref_pop_snp_chip is equal to "last_breed_formation_generation"
if (Ref_pop_snp_chip == "last_breed_formation_generation") {
  SP$addSnpChip(
  nSnpPerChr = num_snp_markers_simulated_chromosome,

  refPop = last_mate_selection_generation

  )
  
}



# 

# SP$addSnpChip(
# 
# nSnpPerChr = num_snp_markers_simulated_chromosome,
# 
#  minSnpFreq = min_MAF,
# 
# refPop = last_mate_selection_generation
# 
#  )
```


# 3: Export files

## 3.1: Export to PLINK (Extracting data to PLINK)

### 3.1.0.1: Optional: pullSnpGeno() - Retrieves a list of the existing marker id:s (SNP id:s) -->

Function that retrieves SNP genotype data & returns a matrix of SNPgenotypes



### 3.1.0.2: Optional: getSnPMap() - Retrieves a table of the genetic map for the SNP chip

Function that retrieves the genetic map for a given SNP chip & returns a
data.frame with:

-   **id:** Unique identifier for the marker (SNP)

-   **chr:** Chromosome containing the SNP

-   **site:** Segregating site on the chromosome

-   **pos:** Genetic map position


```r
snp_chip_map <- getSnpMap(simParam=SP)
# View(snp_chip_map)

cat("First 10 markers of the SNP chip and their genetic map positions:\n")
```

```
## First 10 markers of the SNP chip and their genetic map positions:
```

```r
kable(head(snp_chip_map,10))
```



|      |id    |chr | site|       pos|
|:-----|:-----|:---|----:|---------:|
|1_19  |1_19  |1   |   19| 0.0001608|
|1_21  |1_21  |1   |   21| 0.0001833|
|1_22  |1_22  |1   |   22| 0.0001976|
|1_50  |1_50  |1   |   50| 0.0005447|
|1_51  |1_51  |1   |   51| 0.0005721|
|1_54  |1_54  |1   |   54| 0.0005932|
|1_72  |1_72  |1   |   72| 0.0008248|
|1_83  |1_83  |1   |   83| 0.0011180|
|1_107 |1_107 |1   |  107| 0.0015537|
|1_120 |1_120 |1   |  120| 0.0016373|


### 3.1.1: writePlink()

**Description** Function that inputs a Pop-class & exports it to PLINK
PED and MAP files.

The arguments for this function were chosen for consistency with
RRBLUP2. **The base pair coordinate will the locus position as stored in
AlphaSimR** & not an actual base pair position, because AlphaSimR
doesn’t track base pair positions, **only relative positions for the
loci used in the simulation**.

\*\* Usage \*\* writePlink( pop, baseName, traits = 1, use = "pheno",
snpChip = 1, useQtl = FALSE, simParam = NULL, ... )

**Arguments:**

-   **pop** an object of Pop-class

-   **baseName** basename for PED and MAP files.

-   **traits** an integer indicating the trait to write, a trait name,
    or a function of the traits returning a single value.

-   **use** what to use for PLINK’s phenotype field. Either phenotypes
    "pheno", genetic values "gv", estimated breeding values "ebv",
    breeding values "bv", or random values "rand".

-   **snpChip** an integer indicating which SNP chip genotype to use
    useQtl should QTL genotypes be used instead of a SNP chip.

    
       -    If TRUE, snpChip specifies which trait’s QTL to use, and thus these QTL may not match the QTL underlying the phenotype supplied in traits.
  

-   **simParam** an object of SimParam ... additional arguments if using
    a function for traits


```r
# Setting the directory where the .map and .ped files will be stored in
setwd(output_dir_simulation)

writePlink(last_mate_selection_generation,snpChip = 1,simParam=SP, baseName=output_sim_files_basename,

            traits = 1,
           use = "rand"

           )


# writePlink(last_mate_selection_generation,snpChip = 2, baseName=output_sim_files_basename,
# 
#             traits = 1,
#            use = "rand"
# 
# 
#            )



# writePlink(last_mate_selection_generation,simParam=SP, baseName=output_sim_files_basename,
# 
#             traits = 1,
#            use = "rand"
# 
# 
#            )
```
### 3.1.2: Convert distances to basepair in the .map file


```r
# Setting the working directory as the output directory
setwd(output_dir_simulation)

# Read PLINK files into R objects
ped_file <- paste0(output_sim_files_basename, '.ped')
map_file <- paste0(output_sim_files_basename, '.map')
ped_data <- read.table(ped_file)
map_data <- read.table(map_file)
 
# ¤¤¤¤¤ .map-file Column 1: Changing to correct chromosome ¤¤¤¤¤
# Change the first column of the .map file to ensure that the correct chromosome number is used
map_data$V1 <- chr_number

# ¤¤¤¤¤ .map-file Column 2: Changing the SNP IDs to refer to correct chromosome ¤¤¤¤¤
# Changing the SNP_Ids (second column) so their prefix indicate the correct chromosome number, otherwise 
# It  will seem like they all belong to chromosome 1, like "1_21".
# (will be useful if you would simulate more chromosomes in the future)
map_data$V2 <- gsub("^\\d+_", paste0(chr_number, "_"), map_data$V2)
# ¤¤¤¤¤ .map-file Column 4: Mapping correct bp-positions for the markers ¤¤¤¤¤
genetic_distance_morgan_column <- map_data$V3 # Extracting the genetic distance column of map_data (3rd column)
base_pair_position_column <- round(genetic_distance_morgan_column * (model_chromosome_bp_length / 100))
# Redefining the physical position column (4th column) with the new values defined in base_pair_position_column
map_data$V4 <- base_pair_position_column




#col.names = FALSE: Removes the header.
#quote = FALSE: Removes quotation marks from values.
write.table(map_data, file = map_file, sep = "\t", row.names = FALSE, col.names = FALSE,quote = FALSE)

cat("Showing the first 10 rows of the new .map file:\n")
```

```
## Showing the first 10 rows of the new .map file:
```

```r
kable(head(map_data, 10))
```



| V1|V2    |        V3|     V4|
|--:|:-----|---------:|------:|
|  3|3_19  | 0.0160841|  14874|
|  3|3_21  | 0.0183309|  16952|
|  3|3_22  | 0.0197603|  18274|
|  3|3_50  | 0.0544672|  50371|
|  3|3_51  | 0.0572104|  52908|
|  3|3_54  | 0.0593159|  54855|
|  3|3_72  | 0.0824779|  76275|
|  3|3_83  | 0.1118017| 103393|
|  3|3_107 | 0.1553676| 143682|
|  3|3_120 | 0.1637265| 151413|
# 3.2 Causative variant
## 3.2.1 Export information about the location of the causative variant

```r
# setwd(variant_position_dir)
#selection_scenario_pop
gen_map <- getGenMap(founderGenomes)
#View(gen_map)
causative_variant_relative_SNP_POS <- gen_map[gen_map$id == causative_variant_SNP_ID, ]
cat("Causative variant:\n",causative_variant_SNP_ID)
```

```
## Causative variant:
##  1_8129
```

```r
causative_variant_relative_SNP_POS
```

```
##          id chr        pos
## 8129 1_8129   1 0.08230083
```

```r
cat("\n Relative postions of the causative variant:\n",causative_variant_relative_SNP_POS$pos)
```

```
## 
##  Relative postions of the causative variant:
##  0.08230083
```

```r
causative_variant_SNP_pos_in_bp <- round(causative_variant_relative_SNP_POS$pos * (model_chromosome_bp_length))
cat("\n BP position of the causative variant:\n",causative_variant_SNP_pos_in_bp)
```

```
## 
##  BP position of the causative variant:
##  7611103
```

```r
# Check if the file exists
if (file.exists(variant_positions_file)) {
    # Read the existing data from the file
    causative_variant_positions_table <- read.table(variant_positions_file, header = FALSE, sep = "\t")
} else {
    # Create an empty data frame if the file does not exist
    causative_variant_positions_table <- data.frame(V1 = character(), V2 = integer())
}

# Check if the output_sim_files_basename already exists in the file
existing_row_index <- which(causative_variant_positions_table$V1 == output_sim_files_basename)

if (length(existing_row_index) > 0) {
    causative_variant_positions_table$V2[existing_row_index] <- causative_variant_SNP_pos_in_bp
} else {
    # Create a new row with the output_sim_files_basename and disappearance_counter
    new_row <- data.frame(V1 = output_sim_files_basename, V2 = causative_variant_SNP_pos_in_bp)
    # Append the new row to the existing data
    causative_variant_positions_table <- rbind(causative_variant_positions_table, new_row)
}

# Write the updated data back to the file
write.table(causative_variant_positions_table, file = variant_positions_file, sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
```
## 3.3: Export an allele frequency plot for the causative variant

```r
setwd(image_output_dir)

# Format the bp position nicely
formatted_bp_pos <- format(causative_variant_SNP_pos_in_bp, big.mark = " ")

#f_causative

# Plotting the allele frequency of the causative variant during the mate selection scenario

# Open a PNG graphics device with the desired filename
png(paste0(output_sim_files_basename, '.png'))

# Set the plot title
plot_title <- sprintf("Causative-Variant Frequency Plot - s=%g (%d replicates pruned) ", s, disappearance_counter)


# Plot with customized axes labels and title
plot(f_causative,
     type = "p",
     xlab = "Generation",
     ylab = "Allele Frequency ",
     main = plot_title,
     ylim = c(0, 1)
     )

# Add text for the bp position of the studied marker inside the plot
text(x = max(seq_along(f_causative)), y = 0.05, labels = paste("SNP Pos on", chr_simulated, "(bp):", formatted_bp_pos, "bp"), adj = c(1, 0))


# # Save the plot
dev.off()
```

```
## png 
##   2
```

```r
# Saving the plot-data as a .txtfile
write.table(f_causative, file = paste0(output_sim_files_basename, '.txt'), sep = "\t", row.names = FALSE, col.names = FALSE,quote = FALSE)
```

## 3.2: Export pruned replicates information

```r
# setwd(pruned_counts_dir)

# Print the number of times the causative variant disappeared
cat("Number of times the causative variant disappeared:\n")
```

```
## Number of times the causative variant disappeared:
```

```r
cat("Disappearance Counter:", disappearance_counter, "\n")  # Print disappearance_counter value to standard output
```

```
## Disappearance Counter: 0
```

```r
# Check if the file exists
if (file.exists(simulation_prune_count_file)) {
    # Read the existing data from the file
    prune_count_data <- read.table(simulation_prune_count_file, header = FALSE, sep = "\t")
} else {
    # Create an empty data frame if the file does not exist
    prune_count_data <- data.frame(V1 = character(), V2 = integer())
}

# Check if the output_sim_files_basename already exists in the file
existing_row_index <- which(prune_count_data$V1 == output_sim_files_basename)

if (length(existing_row_index) > 0) {
    # Update the existing row by adding the total disappearance_counter to V2
    disappearance_counter <- disappearance_counter + prune_count_data$V2[existing_row_index]
    prune_count_data$V2[existing_row_index] <- disappearance_counter
} else {
    # Create a new row with the output_sim_files_basename and disappearance_counter
    new_row <- data.frame(V1 = output_sim_files_basename, V2 = disappearance_counter)
    # Append the new row to the existing data
    prune_count_data <- rbind(prune_count_data, new_row)
}

# Write the updated data back to the file
write.table(prune_count_data, file = simulation_prune_count_file, sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
```
