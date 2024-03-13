import time

# Function to format time in minutes and seconds
def format_time(seconds):
    minutes = seconds // 60
    seconds %= 60
    return f"{minutes}m, {seconds} s"
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


start_time = time.time()  # Start the timer

# Generate windows for the specified chromosome
bed_windows_list = []
for chrom, length_mb in chromosome_lengths_mb.items():
    length_bp = length_mb * 10**6 # Get chromosome length in bp (base pairs)
    window_start = 1
    while window_start <= length_bp:
        window_end = min(window_start + window_size_bp - 1, length_bp)
        bed_windows_list.append(f"{chrom[3:]}\t{window_start}\t{window_end}")
        window_start += window_size_bp
    # Print elapsed time whenever a chromosome is done 
    elapsed_time = time.time() - start_time
    print(f"Done processing {chrom}, Elapsed time: {format_time(elapsed_time)}")

window_file_name = "all_autosomes_windows_100kB_window_sizes.bed"
# Output the generated windows in BED format
with open(window_file_name, "w") as bed_file:
    bed_file.write("# Chromosome\tStart\tEnd\n")
    bed_file.write("\n".join(bed_windows_list))


# Print elapsed time whenever a chromosome is done 
elapsed_time = time.time() - start_time

print(f" done! Output saved as {window_file_name}")
print(f" window size = {round(window_size_bp/(10**6),5)} Mb")
print(f" Script Runtime: {format_time(elapsed_time)}")