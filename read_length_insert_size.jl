using BioSequences
using FASTX
using Glob

infiles = glob("*_R1_001.fastq.gz")
for infile in infiles
    println(infile)
end 