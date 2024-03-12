

input_file = "38_chr_sorted_population_coverage.bed" # header: "Chr"    "POS1"  "POS2"  "Count" "Frequency"
output_file = "merged_38_chr_sorted_population_coverage.bed"


with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
    prev_line = ""
    for line in infile:
        current_row = line.strip().split("\t")
        print(f"")
        if prev_line and len(current_row) >= 4 and len(prev_line) >= 4 and current_row[0] == prev_line[0] and current_row[3] == prev_line[3]: # If same Chr & same Count
            if int(current_row[1]) == int(prev_line[2]) + 1: # If POS2 of the first (previous row) line is 1 less than POS1 of the second line (current row)
                prev_line[2] = current_row[2]
            else:
                outfile.write("\t".join(prev_line) + "\n")
                prev_line = current_row # Since the window won't get merged, go on with the search
        else:
            if prev_line:
                outfile.write("\t".join(prev_line) + "\n")
            prev_line = current_row
    if prev_line:
        outfile.write("\t".join(prev_line) + "\n")


# with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
#     counter = 0
#     prev_line = ""
#     for line in infile:
#         if counter == 4:
#             break
#         current_row = line.strip().split("\t")
#         print(current_row)
#         print(f"chr={current_row[0]}]\tpos1={current_row[1]} \t pos2={current_row[2]} \t count={current_row[3]} \t Frequency={current_row[4]} ")
#         counter +=1
