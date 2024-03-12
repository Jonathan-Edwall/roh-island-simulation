# Chromosome lengths of Dogs in Mb, derived from Table 1 in this article:
# https://www-ncbi-nlm-nih-gov.ezproxy.its.uu.se/pmc/articles/PMC2564286/

# Chromosome lengths in Mb derived from the genome assembly
chromosome_lengths_mb = {
    "chr1": 125, "chr2": 88, "chr3": 94, "chr4": 91, "chr5": 91,
    "chr6": 80, "chr7": 83, "chr8": 77, "chr9": 64, "chr10": 72,
    "chr11": 77, "chr12": 75, "chr13": 66, "chr14": 63, "chr15": 67,
    "chr16": 62, "chr17": 67, "chr18": 58, "chr19": 56, "chr20": 61,
    "chr21": 54, "chr22": 64, "chr23": 55, "chr24": 50, "chr25": 54,
    "chr26": 42, "chr27": 48, "chr28": 44, "chr29": 44, "chr30": 43,
    "chr31": 42, "chr32": 41, "chr33": 34, "chr34": 45, "chr35": 29,
    "chr36": 33, "chr37": 33, "chr38": 26
}

"""
Defining Maximum window size in base pairs.
Since German Shepherd had smallest ROH-segment of 2207.226 kBP (2,2 Mb)
1 Mb seems like a fitting window size.
"""
# Window size in base pairs
#window_size_bp = 1 * 10**6  # 1MB as window size
# window_size_bp = 0.5 * 10**6  # 0.5MB as window size
window_size_bp = 1 * 10**5  # 100kB as window size


# Chromosome of interest
chrom = "chr1"

# Get chromosome length in base pairs
length_bp = chromosome_lengths_mb[chrom] * 10**6

# Generate windows for the specified chromosome
bed_lines = []
window_start = 1
while window_start <= length_bp:
    window_end = min(window_start + window_size_bp - 1, length_bp)
    bed_lines.append(f"{chrom[3:]}\t{window_start}\t{window_end}")
    window_start += window_size_bp

# Output the generated windows in BED format
with open(f"{chrom}_windows_MB_window_sizes.bed", "w") as bed_file:
    bed_file.write("\n".join(bed_lines))

print(f" done! Output saved as {chrom}_windows.bed ")
print(f" window size = {window_size_bp/(10**6)} Mb")