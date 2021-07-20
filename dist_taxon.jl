include("embl_taxonomy.jl")
taxonomies = readtaxonomy("embl_taxonomy.bin")
#println(taxonomies)
#println(taxonomies["MT879754"])

# taxon_file = open(ARGS[1], "r")
# lines = readlines(taxon_file)
# for line in lines
#     #println(line)
#     col = split(line)
#     id = split(col[1], ".")[1]
#     id2 = split(col[2], ".")[1]
#     print(id, "\t", id2, "\t", col[3], "\t", col[4], "\t", col[5], "\t")
#     println(taxonomies[id])
# end

overlap_file = open(ARGS[1], "r")
head = readline(overlap_file)
println(head, "\t", "Taxon")
lines2 = readlines(overlap_file)
for line in lines2
    id = split(line)[1]
    #println(line, "\t", taxonomies[id])
    #println(taxonomies[id][1], "\t", taxonomies[id][2])
    if ARGS[2] in taxonomies[id]
        position = findfirst(isequal(ARGS[2]), taxonomies[id])
        #println("yes", "\t", position, "\t", taxonomies[id][position:end])
        println(line, "\t", taxonomies[id][position:end])
    else
        #println(ARGS[2], " cannot be found in the taxon")
    end
end

#using RCall
