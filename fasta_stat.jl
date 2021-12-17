using BioSequences
using FASTX
using Printf

# function fasta_format()
#     filter(x -> !isspace(x), )
# end

println("ID\tlen\tN%\tGC%\tgap")
reader = open(FASTA.Reader, ARGS[1])
for record in reader
    #println(record)
    print(FASTA.identifier(record))

    seq = FASTA.sequence(record)
    #print("\t", seq)
    seqlen = length(seq)
    print("\t", seqlen)

    gaprate = count(isambiguous, seq)/seqlen*100
    @printf "\t%.2f" gaprate

    gcrate = length(collect(eachmatch(r"G|C", string(seq))))/seqlen*100
    @printf "\t%.2f" gcrate

    gapnumber = length(collect(eachmatch(r"N+", string(seq))))
    print("\t", gapnumber)

    gapnumber = count(isgap, seq)
    print("\t", gapnumber)
    println()
end
close(reader)

