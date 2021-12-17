struct Feature
    path::String
    length::Int32
    relative_length::Float64
    stackdepth::Float64
    coverage::Float64
    feature_prob::Float32
    coding_prob::Float32
end

mutable struct FeatureStats
    count::Int
    mean_length::Float64
    m2_length::Float64
    mean_depth::Float64
    m2_depth::Float64
    mean_coverage::Float64
    m2_coverage::Float64
end

function readFeatures(file::String)::Vector{Feature}
    features = Vector{Feature}()
    open(file) do f
        header = split(readline(f), '\t')
        genome_id = header[1]
        genome_length = parse(Int32, header[2])
        
        while !eof(f)
            fields = split(readline(f), '\t', keepempty = false)
            startswith(fields[1], "unassigned") && continue
            path_components = split(fields[1], "/")
            path = join(path_components[[1, 3, 4]], "/")
            if length(fields) > 7 #Chloe annotations
                feature = Feature(path, parse(Int32, fields[4]), parse(Float64, fields[6]), parse(Float64, fields[7]), parse(Float64, fields[8]), parse(Float32, fields[9]), parse(Float32, fields[10]))
            else #EMBL annotations
                feature = Feature(path, parse(Int, fields[4]), parse(Float64, fields[6]), 0.0, 0.0, 0.0, 0.0)
            end
            push!(features, feature)
        end
    end
    return features
end

function analyse_sff_files()
    if isdir(ARGS[1])
        files = filter(endswith(".sff"), readdir(ARGS[1], join=true))
    else
        files = Vector{String}()
        append!(files,ARGS)
    end
    stats = Dict{String,FeatureStats}()
    for file in files
        features = readFeatures(file)
        for f in features
            fstats = get(stats, f.path, nothing)
            if isnothing(fstats)
                fstats = stats[f.path] = FeatureStats(0,0,0,0,0,0,0)
            end
            fstats.count += 1
            (fstats.mean_length, fstats.m2_length) = running_stats(f.relative_length, fstats.count, fstats.mean_length, fstats.m2_length)
            (fstats.mean_depth, fstats.m2_depth) = running_stats(f.stackdepth, fstats.count, fstats.mean_depth, fstats.m2_depth)
            (fstats.mean_coverage, fstats.m2_coverage) = running_stats(f.coverage, fstats.count, fstats.mean_coverage, fstats.m2_coverage)
        end
    end
    for (k, v) in stats
        println(join([k,v.count,v.mean_length,v.m2_length/(v.count-1),v.mean_depth,v.m2_depth/(v.count-1),v.mean_coverage,v.m2_coverage/(v.count-1)],'\t'))
    end
end

function running_stats(x, n::Int, running_mean::Float64, M2::Float64)
    delta = x - running_mean
    running_mean += delta/n
    M2 += delta*(x - running_mean)
    return (running_mean, M2)
end

analyse_sff_files()