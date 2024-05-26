import time

# Function to format time in minutes and seconds
def format_time(seconds):
    minutes = seconds // 60
    seconds %= 60
    return f"{minutes}m, {seconds} s"
# Chromosome lengths of Dogs in Mb, derived from Table 1 in this article:
# https://www-ncbi-nlm-nih-gov.ezproxy.its.uu.se/pmc/articles/PMC2564286/

# # Chromosome lengths in Mb derived from the genome assembly
# chromosome_lengths_mb = {
#     "chr1": 125, "chr2": 88, "chr3": 94, "chr4": 91, "chr5": 91,
#     "chr6": 80, "chr7": 83, "chr8": 77, "chr9": 64, "chr10": 72,
#     "chr11": 77, "chr12": 75, "chr13": 66, "chr14": 63, "chr15": 67,
#     "chr16": 62, "chr17": 67, "chr18": 58, "chr19": 56, "chr20": 61,
#     "chr21": 54, "chr22": 64, "chr23": 55, "chr24": 50, "chr25": 54,
#     "chr26": 42, "chr27": 48, "chr28": 44, "chr29": 44, "chr30": 43,
#     "chr31": 42, "chr32": 41, "chr33": 34, "chr34": 45, "chr35": 29,
#     "chr36": 33, "chr37": 33, "chr38": 26
# }

# Chromosome lengths in Mb derived from genome assembly
# https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_011100685.1/

chromosome_lengths_bp={
"chr1":123556469, "chr2":84979418, "chr3":92479059, "chr4":89535178	, "chr5":89562946, 
"chr6":78113029	, "chr7":81081596, "chr8":76405709, "chr9":61171909, "chr10":70643054, 
"chr11":74805798, "chr12":72970719, "chr13":64299765, "chr14":61112200, "chr15":64676183, 
"chr16":60362399, "chr17":65088165, "chr18":56472973, "chr19":55516201, "chr20":58627490, 
"chr21":51742555, "chr22":61573679, "chr23":53134997, "chr24":48566227, "chr25":51730745, 
"chr26":39257614, "chr27":46662488, "chr28":41733330, "chr29":42517134, "chr30":40643782, 
"chr31":39901454, "chr32":40225481, "chr33":32139216, "chr34":42397973, "chr35":28051305, 
"chr36":31223415, "chr37":30785915, "chr38":24803098	
}



# # Chromosome lengths in Mb derived from genome assembly
# chromosome_lengths_bp = {
#     "chr1": 122244432, "chr2": 85006234, "chr3": 91857950, "chr4": 88025528, "chr5": 88720695,
#     "chr6": 77222727, "chr7": 80844934, "chr8": 73331251, "chr9": 61030064, "chr10": 68913302,
#     "chr11": 74127200, "chr12": 72428913, "chr13": 62987575, "chr14": 60761097, "chr15": 63553064,
#     "chr16": 58670957, "chr17": 63643600, "chr18": 55698296, "chr19": 53203435, "chr20": 58095605,
#     "chr21": 50622171, "chr22": 61255722, "chr23": 52091374, "chr24": 47579210, "chr25": 51374082,
#     "chr26": 38930817, "chr27": 45605868, "chr28": 40983861, "chr29": 41724766, "chr30": 40195241,
#     "chr31": 39499025, "chr32": 38405529, "chr33": 31361171, "chr34": 41914684, "chr35": 26425891,
#     "chr36": 30767778, "chr37": 30727317, "chr38": 23875669	
# }



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
for chrom, length_bp in chromosome_lengths_bp.items():
    window_start = 1
    while window_start <= length_bp:
        window_end = min(window_start + window_size_bp - 1, length_bp)
        bed_windows_list.append(f"{chrom[3:]}\t{window_start}\t{window_end}")
        window_start += window_size_bp
    # Print elapsed time whenever a chromosome is done 
    elapsed_time = time.time() - start_time
    print(f"Done processing {chrom}, Elapsed time: {format_time(elapsed_time)}")

window_file_name = "Autosome_windows_100kB_window_sizes.bed"
# Output the generated windows in BED format
with open(window_file_name, "w") as bed_file:
    bed_file.write("# Chromosome\tStart\tEnd\n")
    bed_file.write("\n".join(bed_windows_list))


# Print elapsed time whenever a chromosome is done 
elapsed_time = time.time() - start_time

print(f" done! Output saved as {window_file_name}")
print(f" window size = {round(window_size_bp/(10**6),5)} Mb")
print(f" Script Runtime: {format_time(elapsed_time)}")