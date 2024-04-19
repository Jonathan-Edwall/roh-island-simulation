
library(AlphaSimR)
library(tibble)


## Founder population -- set this to the start conditions for your simulation!

founders <- runMacs2(nInd = 100,
                     nChr = 1,
                     Ne = 2500,
                     histNe = NULL,
                     histGen = NULL)

simparam <- SimParam$new(founders)


pop <- newPop(founders, simparam)


## Pick a random causative variant that has relatively low allele frequency,
## here < 10 allele copies

count <- colSums(pullSegSiteGeno(pop, simParam = simparam))

candidate_variants <- which(count < 10)

causative_variant <- candidate_variants[sample(1:length(candidate_variants), 1)]


## Selection coefficient
s <- 0.05


## 500 generations of selection

## Your simulation of population history goes here

f_causative <- numeric(500)

for (gen in 1:500) {
    
    geno <- pullSegSiteGeno(pop, simParam = simparam)[, causative_variant]
    
    ## Set fitness
    fitness <- rep(1 - s, length(geno))
    fitness[geno == 2] <- 1
    fitness[geno == 1] <- 1 - s/2
    
    ## Biased sampling of parents based on fitness
    parent1 <- sample(1:pop@nInd, 1000, replace = TRUE, prob = fitness)
    parent2 <- sample(1:pop@nInd, 1000, replace = TRUE, prob = fitness)
    
    pop <- makeCross(pop,
                     cbind(parent1, parent2),
                     nProgeny = 1,
                     simParam = simparam)
    
    pop <- AlphaSimR::mutate(pop, simParam = simparam)
    
    f_causative[gen] <- sum(geno)/length(geno)/2
}

## Plot the resulting frequency trajectory for illustration

plot(f_causative)


