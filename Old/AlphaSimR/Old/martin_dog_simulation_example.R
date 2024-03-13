library(AlphaSimR)
library(dplyr)
library(ggplot2)
library(patchwork)
library(purrr)
library(tibble)


founders <- runMacs2(nInd = 100,
                     nChr = 1,
                     Ne = 2500,
                     histNe = NULL,
                     histGen = NULL)

simparam <- SimParam$new(founders)

simparam$addTraitA(nQtlPerChr = 10)
simparam$setSexes("yes_sys")
simparam$setVarE(h2 = 0.2)

simparam$addSnpChip(nSnpPerChr = 1000)

simparam$setTrackRec(TRUE)

founderpop <- newPop(founders, simParam = simparam)

breed1_founders <- founderpop[1:50]
breed2_founders <- founderpop[51:100]


## 10 generations of bottleneck

random_mating <- function(pop, simparam, n_gen) {
    n_ind <- pop@nInd 
    generations <- vector(length = n_gen + 1,
                          mode = "list")
    generations[[1]] <- pop
    for (gen_ix in 2:(n_gen + 1)) {
        generations[[gen_ix]] <- randCross(generations[[gen_ix - 1]], nCrosses = n_ind, nProgeny = 1,
                                           simParam = simparam)
    }
    generations[-1]
}


breed1_bottleneck <- random_mating(breed1_founders, simparam, 5)

breed2_bottleneck <- random_mating(breed2_founders, simparam, 5)


breeding <- function(pop, simparam, n_gen, n_sires, size) {
    generations <- vector(length = n_gen + 1,
                          mode = "list")
    generations[[1]] <- pop
    for (gen_ix in 2:(n_gen + 1)) {
        n_females <- generations[[gen_ix - 1]]@nInd/2
        generations[[gen_ix]] <- selectCross(generations[[gen_ix - 1]], 
                                             nMale = n_sires,
                                             nFemale = n_females,
                                             nCrosses = size,
                                             use = "pheno",
                                             nProgeny = 1,
                                             simParam = simparam)
    }
    generations[-1]
    
}


breed1_selection <- breeding(breed1_bottleneck[[5]],
                             simparam = simparam,
                             n_gen = 20,
                             n_sires = 20,
                             size = 200)

breed2_selection <- breeding(breed2_bottleneck[[5]], 
                             simparam = simparam,
                             n_gen = 20,
                             n_sires = 20,
                             size = 200)