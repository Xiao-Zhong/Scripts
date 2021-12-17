#using BioSequences
using FASTX

reader = open(FASTA.Reader, "test.fa")
for record in reader
    ## Do something
    # like showing the identifiers
    @show FASTA.identifier(record)
end
close(reader)
