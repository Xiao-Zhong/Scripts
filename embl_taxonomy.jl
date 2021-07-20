using Serialization

function taxonomyfromembl(infile::String)
    local accession::String = ""
    taxonomy = Vector{String}(undef, 0)
    open(infile, "r") do emblfile
        for line in eachline(emblfile)
            if startswith(line, "AC")
                if accession == ""
                    accession = split(line[6:end - 1], "; ")[1]
                end
            elseif startswith(line, "OC")
                append!(taxonomy, split(line[6:end - 1], "; "))
            end
        end
    end
    return accession, taxonomy
end

function createtaxonomy(embldir::String, outfile::String)
    if isdir(embldir)
        files = filter(endswith(".embl"), readdir(embldir, join=true))
    else
        files = Vector{String}()
        push!(files,embldir)
    end
    taxonomies = Dict{String, Vector{String}}()
    for file in files
        accession, taxonomy = taxonomyfromembl(file)
        taxonomies[accession] = taxonomy
    end
    serialize(outfile, taxonomies)
    return taxonomies
end

function readtaxonomy(taxfile::String)
    taxonomies = deserialize(taxfile)
end

function findtaxon(taxonomies::Dict{String, Vector{String}}, taxon::String)
    hits = Vector{String}(undef, 0)
    for (accession, taxa) in taxonomies
        if taxon in taxa
            push!(hits, accession)
        end
    end
    return hits
end