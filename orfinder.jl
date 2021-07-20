using FASTX
using BioSequences
using BioGenerics
using ArgParse
using Logging

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--logging", "-l"
            help = "logging level (Debug, Info, Warn, Error)"
            arg_type = String
            default = "Info"
        "--min_orf", "-m"
            help = "minimum length of ORFs in nucleotides"
            arg_type = Int
            default = 300
        "--strand", "-s"
            help = "which target strand(s) to search"
            arg_type = String
            default = "F"
        "--start_codon", "-M"
            help = "flag indicating whether ORFs must start with an ATG codon"
            action = :store_true
        "--stop_codon", "-Z"
            help = "flag indicating whether ORFs must end with a stop codon"
            action = :store_true
        "--outfile","-o"
            help = "path to results file"
            arg_type = String
        "input"
            help = "nucleotide sequence(s) in fasta format"
            required = true
    end
    return parse_args(s)
end

struct Frame
    strand::Char
    frame::Int64
    translation::LongAminoAcidSeq
end

struct ORF
    strand::Char
    start::Int64
    finish::Int64
    sequence::LongAminoAcidSeq
end

function threeframes(seq::LongDNASeq, strand::Char)::Vector{Frame}
    frames = Vector{Frame}(undef,3)
    Threads.@threads for frame in 1:3
        start = frame
        rflength = 3*div(length(seq)+1-frame,3)
        finish = start + rflength -1
        frames[frame] = Frame(strand,frame,translate(seq[start:finish]))
    end
    return frames
end

function sixframes(seq::LongDNASeq)::Vector{Frame}
    frames = threeframes(seq, 'F')
    return vcat(frames,threeframes(reverse_complement(seq), 'R'))
end

function findorfs(frames::Vector{Frame}, genome_length::Int, start_codon::Bool, stop_codon::Bool, min_orf::Int)::Vector{Vector{ORF}}
    allorfs = Vector{Vector{ORF}}(undef,length(frames))
    Threads.@threads for (i,frame) in collect(enumerate(frames))
        orfs = Vector{ORF}(undef,0)
        pointer = 1
        while pointer ≠ 0
            if start_codon
                pointer = findnext(AA_M, frame.translation, pointer)
                isnothing(pointer) && break
            end
            M = pointer
            pointer = findnext(AA_Term, frame.translation, pointer)
            if isnothing(pointer)
                stop_codon && break 
                pointer = length(frame.translation)
            end
            if (pointer - M) ≥ ceil(min_orf/3)
                orf_start = frame.frame+M*3-3
                orf_end = frame.frame-1+pointer*3
                if i ≥ 4 #reverse strand
                    tmp = orf_end
                    orf_end = genome_length - orf_start + 1
                    orf_start = genome_length - tmp + 1
                end
                push!(orfs,ORF(frame.strand, orf_start, orf_end, frame.translation[M:pointer]))
            end
            pointer += 1
            pointer > length(frame.translation) && break
        end
        allorfs[i] = orfs
    end
    return allorfs
end

function writeorfs(writer::FASTA.Writer, recordid::String, allorfs::Vector{Vector{ORF}})
    @info recordid
    for forfs in allorfs
        for orf in forfs
            @info orf
            rec = FASTA.Record(recordid*"_"*orf.strand*"_"*string(orf.start)*"-"*string(orf.finish), orf.sequence)
            write(writer, rec)
        end
    end
end

const FORWARD_STRAND = 0x02
const REVERSE_STRAND = 0x01

function requested_strand(strandarg::String)::UInt8
    strand = 0x00
    if length(strandarg) > 3
        if occursin(r"forward"i, strandarg); strand |= 0x02; end
        if occursin(r"reverse"i, strandarg); strand |= 0x01; end
        if occursin(r"both"i, strandarg); strand |= 0x03; end
    else
        if occursin(r"f|\+"i, strandarg); strand |= 0x02; end
        if occursin(r"r|-"i, strandarg); strand |= 0x01; end
    end
    return strand
end

function main()
    parsed_args = parse_commandline()
    global_logger = ConsoleLogger(stderr, Logging.Info)
    reader = open(FASTA.Reader, parsed_args["input"])
    strand = requested_strand(parsed_args["strand"])
    min_orf = parsed_args["min_orf"]
    start_codon = parsed_args["start_codon"]
    stop_codon = parsed_args["stop_codon"]
    outfile = parsed_args["outfile"]
    if isnothing(outfile)
        outfile = basename(parsed_args["input"])*".orfs.fasta"
    end
    writer = open(FASTA.Writer, outfile)
    for record in reader
        seq = FASTA.sequence(record)
        frames = nothing
        if strand & FORWARD_STRAND ≠ 0
            frames = threeframes(seq, 'F')
        end
        if strand & REVERSE_STRAND ≠ 0
            rframes = threeframes(reverse_complement(seq), 'R')
            frames = isnothing(frames) ? rframes : vcat(frames, rframes)
        end
        allorfs = findorfs(frames, length(seq), start_codon, stop_codon, min_orf)
        writeorfs(writer, FASTA.identifier(record), allorfs)
    end
    close(reader)
    close(writer)
end

main()
