using BioSequences
using FASTX
using Printf

# function fasta_format()
#     filter(x -> !isspace(x), )
# end

# function outputfmt(line)
#     columns = split(line , "\t")
#     println(columns[2:3])
#     #map(x -> @printf "%.2f" x, columns[3:4])
# end

function countgaps(seq::LongDNASeq)::Int
	lenseq = length(seq)
	nblocks = 0
	pointer = 1
	inblock = false
	while true
		pointer > lenseq && break
		if seq[pointer] == DNA_N
			if inblock
				# do nothing
			else
				nblocks += 1
				inblock = true
			end
		else
			inblock = false
		end
		pointer += 1
	end
	return nblocks
end

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

    # gcrate = length(collect(eachmatch(biore"[GC]"d, seq)))/seqlen*100
    gcrate = count(isGC, seq)/seqlen*100
    # comp = composition(seq)
    # gcrate = (comp[DNA_C] + comp[DNA_G])/seqlen*100
    @printf "\t%.2f" gcrate

    #gapnumber = length(collect(eachmatch(r"N+", string(seq))))
    gapnumber = countgaps(seq)
    print("\t", gapnumber)
	#A = `perl -le "$count = () = $seq =~ /N+/g"`
	#print("\t", run(A))

    #global output *= join([FASTA.identifier(record), seqlen, @printf "\t%.2f" gaprate, @printf "\t%.2f" gcrate, gapnumber], "\t") * "\n"
    println()
end
close(reader)
