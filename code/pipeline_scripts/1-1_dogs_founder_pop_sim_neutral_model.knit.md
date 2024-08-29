---
title: "Founder population simulation for Dogs (Neutral Model) in AlphaSimR"
output:
  html_document:
    toc: true
    toc_depth: 3  
date: "2024-06-07"
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

chr_simulated <- Sys.getenv("chr_simulated")
chr_simulated
```

```
## [1] "chr1"
```

```r
# Extract the chromosome number and convert and convert it to numeric
chr_number <- as.numeric(sub("chr", "", chr_simulated))


# N_e_burn_in <- 2500 # Ancestral population
N_e_burn_in <- as.numeric(Sys.getenv("Ne_burn_in")) # Ancestral population

nInd_founder_population <- as.numeric(Sys.getenv("nInd_founder_population")) # Founder population


Inbred_ancestral_population <- as.logical(Sys.getenv("Inbred_ancestral_population"))
introduce_mutations <- as.logical(Sys.getenv("Introduce_mutations"))

# N_e_bottleneck <- 50
N_e_bottleneck <- as.numeric(Sys.getenv("N_e_bottleneck"))
n_generations_bottleneck <- as.numeric(Sys.getenv("n_generations_bottleneck"))

n_generations_random_mating <- as.numeric(Sys.getenv("n_simulated_generations_breed_formation")) # The number of generations to simulate during the random mating scenario of modern dog breeds
n_generations_random_mating
```

```
## [1] 96
```

```r
n_indv_breed_formation <- as.numeric(Sys.getenv("n_individuals_breed_formation"))
n_indv_breed_formation
```

```
## [1] 405
```

```r
Ref_pop_snp_chip <- Sys.getenv("reference_population_for_snp_chip")


snp_density_Mb <- as.numeric(Sys.getenv("selected_chr_snp_density_mb")) 
snp_density_Mb
```

```
## [1] 91.23
```

```r
min_MAF <- 0.05 #(minimum allowed Minor Allele Frequency for each SNP)

Sys.getenv()
```

```
## _CE_CONDA               
## _CE_M                   
## _R_CHECK_COMPILATION_FLAGS_KNOWN_
##                         -Wformat -Werror=format-security -Wdate-time
## chr_simulated           chr1
## CONDA_DEFAULT_ENV       base
## CONDA_EXE               /home/martin/anaconda3/bin/conda
## CONDA_PREFIX            /home/martin/anaconda3
## CONDA_PROMPT_MODIFIER   (base)
## CONDA_PYTHON_EXE        /home/martin/anaconda3/bin/python
## CONDA_SHLVL             1
## data_dir                /home/jonathan/data_HO
## DBUS_SESSION_BUS_ADDRESS
##                         unix:path=/run/user/1008/bus
## DISPLAY                 localhost:11.0
## EDITOR                  vi
## empirical_data_basename
##                         LR_fs
## empirical_dog_breed     labrador_retriever
## empirical_processing    FALSE
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
## MOTD_SHOWN              pam
## N_e_bottleneck          6
## n_generations_bottleneck
##                         2
## n_individuals_breed_formation
##                         405
## n_simulated_generations_breed_formation
##                         96
## n_simulation_replicates
##                         20
## Ne_burn_in              3545
## nInd_founder_population
##                         6
## OLDPWD                  /home/jonathan
## output_dir_neutral_simulation
##                         /home/jonathan/data_HO/raw/simulated/neutral_model
## output_sim_files_basename
##                         sim_20_neutral_model_chr1
## PAGER                   /usr/bin/pager
## PATH                    /home/martin/anaconda3/bin:/home/martin/anaconda3/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
## PWD                     /home/jonathan/data_HO/raw/simulated/neutral_model
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
## R_SESSION_TMPDIR        /tmp/RtmpwSalyI
## R_SHARE_DIR             /usr/share/R/share
## R_STRIP_SHARED_LIB      strip --strip-unneeded
## R_STRIP_STATIC_LIB      strip --strip-debug
## R_SYSTEM_ABI            linux,gcc,gxx,gfortran,gfortran
## R_TEXI2DVICMD           /usr/bin/texi2dvi
## R_UNZIPCMD              /usr/bin/unzip
## R_ZIPCMD                /usr/bin/zip
## reference_population_for_snp_chip
##                         last_breed_formation_generation
## results_dir             /home/jonathan/results_HO
## SED                     /bin/sed
## selected_chr_snp_density_mb
##                         91.23
## selection_simulation    FALSE
## SHELL                   /bin/bash
## SHLVL                   2
## SSH_CLIENT              172.21.30.174 56047 22
## SSH_CONNECTION          172.21.30.174 56047 77.235.253.16 22
## SSH_TTY                 /dev/pts/2
## TAR                     /bin/tar
## TERM                    xterm-256color
## USER                    jonathan
## XDG_DATA_DIRS           /usr/local/share:/usr/share:/var/lib/snapd/desktop
## XDG_RUNTIME_DIR         /run/user/1008
## XDG_SESSION_CLASS       user
## XDG_SESSION_ID          6777
## XDG_SESSION_TYPE        tty
```

```r
#################################### 
# Defining the output files
#################################### 


# Define the output directory based on the variable passed from the Bash script
output_dir_simulation <- Sys.getenv("output_dir_neutral_simulation")
output_dir_simulation
```

```
## [1] "/home/jonathan/data_HO/raw/simulated/neutral_model"
```

```r
# Ensure that output_dir_simulation is defined
if (is.null(output_dir_simulation)) {
  stop("output_dir_simulation is not provided.")
}


# Define the base name for the output .map & .ped PLINK files (already defined outside)
output_sim_files_basename <- Sys.getenv("output_sim_files_basename")
output_sim_files_basename
```

```
## [1] "sim_20_neutral_model_chr1"
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
"chr1" = 123556469, "chr2" = 84979418, "chr3" = 92479059, "chr4" = 89535178, "chr5" = 89562946, 
"chr6" = 78113029, "chr7" = 81081596, "chr8" = 76405709, "chr9" = 61171909, "chr10" = 70643054, 
"chr11" = 74805798, "chr12" = 72970719, "chr13" = 64299765, "chr14" = 61112200, "chr15" = 64676183, 
"chr16" = 60362399, "chr17" = 65088165, "chr18" = 56472973, "chr19" = 55516201, "chr20" = 58627490, 
"chr21" = 51742555, "chr22" = 61573679, "chr23" = 53134997, "chr24" = 48566227, "chr25" = 51730745, 
"chr26" = 39257614, "chr27" = 46662488, "chr28" = 41733330, "chr29" = 42517134, "chr30" = 40643782, 
"chr31" = 39901454, "chr32" = 40225481, "chr33" = 32139216, "chr34" = 42397973, "chr35" = 28051305, 
"chr36" = 31223415, "chr37" = 30785915, "chr38" = 24803098)
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


# founderGenomes <- runMacs2(nInd = nInd_founder_population ,
#                      nChr = 1,
#                      Ne = N_e_burn_in,
#                      bp = model_chromosome_bp_length,
#                      genLen = 1,
#                      histNe = NULL,
#                      histGen = NULL)



# Inspecting the founderGenomes object
founderGenomes
```

```
## An object of class "MapPop" 
## Ploidy: 2 
## Individuals: 6 
## Chromosomes: 1 
## Loci: 132314
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
## Individuals: 6 
## Chromosomes: 1 
## Loci: 132314 
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
random_mating_bottleneck <- function(pop, SP, n_gen,introduce_mutations) {
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

random_mating_breed_formation <- function(pop, SP, n_gen,n_indv_breed_formation,introduce_mutations) {
    # n_indv_breed_formation <- pop@nInd # Extracting number of individuals in the current population    
    generations <- vector(length = n_gen + 1,
                          mode = "list") 
    generations[[1]] <- pop # The initial breeding group population gets stored as the first element
    
    # Simulating random mating to perform simulation of the 2nd until the n+1:th generation
    # Each mating Progenys are generated using randcross
    for (gen_ix in 2:(n_gen + 1)) {
        generations[[gen_ix]] <- randCross(pop=generations[[gen_ix - 1]], nCrosses = n_indv_breed_formation, nProgeny = 1,
                                           simParam = SP)
        # Introducing mutations
        if (introduce_mutations == TRUE) {
          generations[[gen_ix]] <- AlphaSimR::mutate(generations[[gen_ix]], simParam = SP)
        }

    }
    
     random_mating_generations <- generations[-1] #all generations except for the founder population gets returned (the simulated generations derived from the bottleneck)
     # return(random_mating_generations)
     
     final_generation <- generations[[n_gen + 1]] # Returning only the final generation

    
    return(final_generation)
}
```


## 2.1: Bottleneck Simulation 

### 2.1.1 Simulating 5 generations of bottleneck (Random Mating)


```r
# Simulating random mating within each breeding group for 5 generations
breed1_bottleneck <- random_mating_bottleneck(breed1_founders, SP, n_generations_bottleneck,introduce_mutations)
# breed2_bottleneck <- random_mating_bottleneck(breed2_founders, SP, n_generations_bottleneck)
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
## Individuals: 6 
## Chromosomes: 1 
## Loci: 132314 
## Traits: 0
```

```r
breed1_bottleneck
```

```
## [[1]]
## An object of class "Pop" 
## Ploidy: 2 
## Individuals: 6 
## Chromosomes: 1 
## Loci: 132314 
## Traits: 0 
## 
## [[2]]
## An object of class "Pop" 
## Ploidy: 2 
## Individuals: 6 
## Chromosomes: 1 
## Loci: 132314 
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
## Individuals: 6 
## Chromosomes: 1 
## Loci: 132314 
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

# SP$addSnpChip(
#   nSnpPerChr = num_snp_markers_simulated_chromosome,
#   minSnpFreq = min_MAF,
#   refPop = last_bottleneck_generation
#   )

if (num_snp_markers_simulated_chromosome > founderGenomes@nLoci) {
  cat("Reference amount of SNP markers for ",chr_simulated, ": ",num_snp_markers_simulated_chromosome)
  cat("\n",num_snp_markers_simulated_chromosome," > ",founderGenomes@nLoci)
  cat("\n Burn in N_e: ", N_e_burn_in,"\n")

  
  num_snp_markers_simulated_chromosome <- founderGenomes@nLoci
  
  new_SNP_density <- num_snp_markers_simulated_chromosome / model_chromosome_Mb_length
  cat("\n Old SNP density: ",snp_density_Mb," markers/Mb")
  cat("\n New SNP density: ",new_SNP_density," markers/Mb")


}



# Check if Ref_pop_snp_chip is equal to last_bottleneck_generation
if (Ref_pop_snp_chip == "last_bottleneck_generation") {
  SP$addSnpChip(
    nSnpPerChr = num_snp_markers_simulated_chromosome,
    refPop = last_bottleneck_generation
  )
}




# SP$addSnpChip(
#   nSnpPerChr = num_snp_markers_simulated_chromosome,
#   refPop = last_bottleneck_generation
#   )
```



## 2.3 Modern dog breed - Random Mating Simulation
### 2.3.1 Simulating 40 generations of Random Mating (Random Mating)

```r
# random_mating_generations <- random_mating_breed_formation(last_bottleneck_generation, SP, n_generations_random_mating,n_indv_breed_formation,introduce_mutations)
# 
# # Extracting the final random mating generation:
# last_random_mating_generation <- random_mating_generations[[n_generations_random_mating]]

last_random_mating_generation <- random_mating_breed_formation(last_bottleneck_generation, SP, n_generations_random_mating,n_indv_breed_formation,introduce_mutations)




# Check if Ref_pop_snp_chip is equal to "last_breed_formation_generation"
if (Ref_pop_snp_chip == "last_breed_formation_generation") {
  SP$addSnpChip(
  nSnpPerChr = num_snp_markers_simulated_chromosome,

  refPop = last_random_mating_generation

  )
  
}


# SP$addSnpChip(
#   nSnpPerChr = num_snp_markers_simulated_chromosome,
#   refPop = last_random_mating_generation
#   )

# SP$addSnpChip(
#   nSnpPerChr = num_snp_markers_simulated_chromosome,
#   minSnpFreq = min_MAF,
#   refPop = last_random_mating_generation
#   )
```

# 3: Export to PLINK Extracting data to PLINK

## 3.0.1: Optional: pullSnpGeno() - Retrieves a list of the existing marker id:s (SNP id:s)

Function that retrieves SNP genotype data & returns a matrix of SNP
genotypes



## 3.0.2: Optional: getSnPMap() - Retrieves a table of the genetic map

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
|1_5   |1_5   |1   |    5| 0.0000459|
|1_17  |1_17  |1   |   17| 0.0001432|
|1_26  |1_26  |1   |   26| 0.0002269|
|1_49  |1_49  |1   |   49| 0.0003266|
|1_85  |1_85  |1   |   85| 0.0006921|
|1_87  |1_87  |1   |   87| 0.0007212|
|1_112 |1_112 |1   |  112| 0.0008933|
|1_120 |1_120 |1   |  120| 0.0009467|
|1_127 |1_127 |1   |  127| 0.0010276|
|1_149 |1_149 |1   |  149| 0.0011873|

## 3.1: writePlink()

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

    ```         
       -    If TRUE, snpChip specifies which trait’s QTL to use, and thus these QTL may not match the QTL underlying the phenotype supplied in traits.
    ```

-   **simParam** an object of SimParam ... additional arguments if using
    a function for traits


```r
# Setting the directory where the .map and .ped files will be stored in
setwd(output_dir_simulation)

writePlink(last_random_mating_generation,simParam=SP, baseName=output_sim_files_basename,
           
            traits = 1,
           use = "rand"          
           
           )
```

# 4: Convert distances to basepair in the .map file


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



write.table(map_data, file = map_file, sep = "\t", row.names = FALSE, col.names = FALSE,quote = FALSE)

#col.names = FALSE: Removes the header.
#quote = FALSE: Removes quotation marks from values.


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
|  1|1_5   | 0.0045931|   5675|
|  1|1_17  | 0.0143207|  17694|
|  1|1_26  | 0.0226916|  28037|
|  1|1_49  | 0.0326551|  40348|
|  1|1_85  | 0.0692065|  85509|
|  1|1_87  | 0.0721162|  89104|
|  1|1_112 | 0.0893275| 110370|
|  1|1_120 | 0.0946701| 116971|
|  1|1_127 | 0.1027625| 126970|
|  1|1_149 | 0.1187322| 146701|
