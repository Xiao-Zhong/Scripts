# Open the file for reading
file_path <- "L1-1-10_S1_L001 counts.csv"
con <- file(file_path, "r")

# Define the pattern to match
pattern <- "^.{8}GGATTATTTG.{11}ATTGACACAT"
# Read the file line by line
while (length(line <- readLines(con, n = 1)) > 0) {
  # Check if the line matches the pattern
  if (grepl(pattern, line)) {
    # Print the line
    cat(line, "\n")
  }
}

# Close the file
close(con)