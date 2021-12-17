module iansSuffixArrays

export GenomeWithSAs, makeSuffixArray, writeGenomeWithSAs, readGenomeWithSAs

struct GenomeWithSAs
    id::String
    sequence::String
    forwardSA::Vector{Int32}
    reverseSA::Vector{Int32}
end

function makeSuffixArray(source, circular)

    if circular
        seq = source * source[1:end-1]
    else
        seq = source
    end

    suffixes = Array{SubString}(undef, length(source))
    for offset = 1:length(source)
        suffixes[offset] = SubString(seq,offset)
    end

	suffixArray = Array{Int32}(undef,length(source))
    suffixArray = sortperm!(suffixArray,suffixes)

    return suffixArray

end

using JLD

function writeGenomeWithSAs(filename::String, genome::GenomeWithSAs)
    jldopen(filename, "w") do file
        write(file,genome.id,genome)
    end
end

function readGenomeWithSAs(filename::String, id::String)
    jldopen(filename, "r") do file
        return read(file,id)
    end
end

function readFasta(file)
    id = ""
    seq = ""
    open(file) do f
        header = readline(f)
        id = split(header," ")[1][2:end]
        while !eof(f)
            seq = seq * uppercase(readline(f))
        end
    end
    return id, seq
end

function revComp(dna)
	#println(dna)
    comp = Dict('A'=>'T', 'T'=>'A', 'G'=>'C', 'C'=>'G')
    reverse(map(x -> comp[x], dna))
end

for infile in ARGS
    #println(infile)
    seqid, seqf = readFasta(infile)
    seqr = revComp(seqf)

    saf = makeSuffixArray(seqf,true)
    sar = makeSuffixArray(seqr,true)

    gwsas = GenomeWithSAs(seqid,seqf,saf,sar)
    filename = gwsas.id * ".gwsas"
    writeGenomeWithSAs(filename,gwsas)
end

end
