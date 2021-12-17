struct FwdRev{T}
    forward::T
    reverse::T
end

struct Feature
    path::String
    strand::Char
    start::Int32
    length::Int32
end

const EMPTY_FEATURE = Feature("",' ',0,0)

function Base.isequal(f1::Feature, f2::Feature)
    return isequal(f1.path, f2.path) && isequal(f1.strand, f2.strand) && isequal(f1.start, f2.start) && isequal(f1.length, f2.length)
end

function Base.string(f::Feature)
    join([f.path, f.strand, string(f.start), string(f.length)], "\t")
end

function Base.write(io::IO, f::Feature)
    write(io, string(f))
end

AFeature = Vector{Feature}
AAFeature = Vector{AFeature}

function readFeatures(file::String)::Tuple{String, Int32, FwdRev{AFeature}}
    open(file) do f
        header = split(readline(f), '\t')
        genome_id = header[1]
        genome_length = parse(Int32, header[2])
        r_features = AFeature()
        f_features = AFeature()
        while !eof(f)
            fields = split(readline(f), '\t')
            startswith(fields[1],"IR") && continue
            startswith(fields[1],"unassigned") && continue
            pathbits = split(fields[1], '/')
            feature = Feature(join(pathbits[[1,3,4]], "/"), fields[2][1], parse(Int32, fields[3]), parse(Int32, fields[4]))
            if fields[2][1] == '+'
                push!(f_features, feature)
            else
                push!(r_features, feature)
            end
        end
        return genome_id, genome_length, FwdRev(f_features, r_features)
    end
end

function check_other_strand_for_match(singletons::Vector{Feature}, other_strand_features::Vector{Feature}, genome_length::Int32, rev=false)
    diffs = Set{Tuple{Feature,Feature}}()
    todelete = Set{Feature}()
    for f in singletons
        revf = Feature(f.path, '.', revcomppos(f.start, f.length, genome_length), f.length)
        for f2 in other_strand_features
            overlap_length = overlap(revf, f2)
            if overlap_length > 0 && revf.path == f2.path
                #println("found wrong strand gene: ", f.path)
                rev ? push!(diffs,(f2,f)) : push!(diffs,(f,f2))
                push!(todelete,f)
            end
        end
    end
    setdiff!(singletons, todelete)
    return diffs, singletons
end

function compare_sff_files()
    if isdir(ARGS[1])
        files1 = filter(endswith(".sff"), readdir(ARGS[1], join=true))
    else
        files1 = Vector{String}()
        push!(files1,ARGS[1])
    end
    if isdir(ARGS[2])
        files2 = filter(endswith(".sff"), readdir(ARGS[2], join=true))
    else
        files2 = Vector{String}()
        push!(files2,ARGS[2])
    end
    open(ARGS[3], "w") do outfile
        for (file1, file2) in zip(files1,files2)
            println(split(file1, ".")[1], " vs ", split(file2, ".")[1])
            id1, gl1, fr1 = readFeatures(file1)
            id2, gl2, fr2 = readFeatures(file2)
            @assert id1 == id2
            diffs, fo, so = collectdiffs(fr1.forward,fr2.forward)
            # for fo features, check they aren't on the other strand in the other annotation set
            morediffs, fo = check_other_strand_for_match(fo, fr2.reverse, gl1, false)
            union!(diffs, morediffs)
            # for so features, check they aren't on the other strand in the other annotation set
            morediffs, so = check_other_strand_for_match(so, fr1.reverse, gl2, true)
            union!(diffs, morediffs)
            morediffs, rfo, rso = collectdiffs(fr1.reverse,fr2.reverse)
            union!(diffs, morediffs)
            # for fo features, check they aren't on the other strand in the other annotation set
            morediffs, rfo = check_other_strand_for_match(rfo, fr2.forward, gl1, false)
            union!(diffs, morediffs)
            # for so features, check they aren't on the other strand in the other annotation set
            morediffs, rso = check_other_strand_for_match(rso, fr1.forward, gl2, true)
            union!(diffs, morediffs)
            union!(fo, rfo)
            union!(so, rso)
            for (f1, f2) in diffs
                write(outfile, id1, "\t", f1, "\t", f2, "\n")
            end
            for f in fo
                write(outfile, id1, "\t", f, "\t", EMPTY_FEATURE, "\n")
            end
            for f in so
                write(outfile, id1, "\t", EMPTY_FEATURE, "\t", f, "\n")
            end
        end
    end
end

function collectdiffs(fa1::AFeature, fa2::AFeature)::Tuple{Vector{Tuple{Feature,Feature}}, Vector{Feature}, Vector{Feature}}
    diffs = Vector{Tuple{Feature,Feature}}()
    first_only = Vector{Feature}()
    second_only = Vector{Feature}()
    for f1 in fa1
        max_overlap = 0
        overlapped_feature = EMPTY_FEATURE
        for f2 in fa2
            overlap_length = overlap(f1, f2)
            if overlap_length > max_overlap
                overlapped_feature = f2
                max_overlap = overlap_length
            end
        end
        if max_overlap == 0
            push!(first_only,f1)
        elseif f1.path ≠ overlapped_feature.path || f1.start ≠ overlapped_feature.start || f1.length ≠ overlapped_feature.length
            push!(diffs,(f1, overlapped_feature))
        end
    end
    for f2 in fa2
        max_overlap = 0
        for f1 in fa1
            overlap_length = overlap(f1, f2)
            if overlap_length > max_overlap
                max_overlap = overlap_length
            end
        end
        if max_overlap == 0
            push!(second_only,f2)
        end
    end
    return (diffs, first_only, second_only)
end

function overlap(f1::Feature, f2::Feature)
    if f1.start >= f2.start + f2.length || f2.start >= f1.start + f1.length
        return 0
    else
        return min(f1.start + f1.length, f2.start + f2.length) - max(f1.start, f2.start)
    end
end

function revcomppos(pos::Int32, flength::Int32, genome_length::Int32)
    return genome_length - pos - flength + 2
end

compare_sff_files()