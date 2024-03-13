#This file explains all of the variables in each of the datasets for UK German Shepherd dogs that accompany: 
#Genome-wide association studies for canine hip dysplasia in single and multiple populations – implications and potential novel risk loci.
# S Wang, E Strandberg, P Arvelius, DN Clements, P Wiener, J Friedrich

# the genotypes (Wang_HDGenetDogs_Genotypes_100621_UK.ped) and map (Wang_HDGenetDogs_Genotypes_100621_UK.map) files are in PLINK format
# genotype and map files contain information on the 78,088 autosomal SNPs that passed quality control described in the paper in the UK and Swedish data set

dataset: Wang_HDGenetDogs_Genotypes_100621_UK.ped
column 1	=	Family ID
column 2	=	Dog ID
column 3	=	Sire ID (set to missing "-9")
column 4	=	Dam ID (set to missing "-9")
column 5	=	Gender
column 6	=	Phenotype (set to missing "-9")
columns 7 - 156182	=	Genotypes (nucleotide coding)


dataset: Wang_HDGenetDogs_Genotypes_100621_UK.map 
column 1	=	Chromosome
column 2	=	SNP ID
column 3	= 	Genetic map position
column 4	=	Position in bp

dataset: Wang_HDGenetDogs_Phenotypes_commonSNPlist_100621_UK.txt
column 1 	= SNP ID for 62,089 common variants between UK, Swedish and Finnish data sets


dataset: Wang_HDGenetDogs_Phenotypes_Covariates_100621_UK.csv
# missing values are coded by "-9"
ID				= Dog ID
UK_HS			= Total hip score 
UK_casecontrol	= Cases (BVA/KC scores >=11) vs. controls (scores 0-10)
UK_FCI			= Total hip scores converted to FCI (Conversion from BVA/KC scores to FCI grades: 0-10=A, 11-25=B, 26-35=C, 36-50=D, 51-106=E)
Sex				= Sex of the dog (1: male, 2: female)
Birth_Year		= Year of birth
Birth_Month		= Month of birth
HD_Year			= Year of hip dysplasia scoring
HD_Age			= Age at hip dysplasia scoring
PC1				= Score for principal component 1 in PCA on genotypes in UK dogs
PC2				= Score for principal component 2 in PCA on genotypes in UK dogs
Group			= Population group (1 = UK)


