using DataStructures
#count_dict = Dict{String, Array{String, Int64}}()
count_dict = Dict()

f = open(ARGS[1], "r")
lines = readlines(f)
#head = lines[1]
head = popfirst!(lines)
println(head)
samples = split(head)
popfirst!(samples)
#println(samples)
#println(lines)
for line in lines
    #println(line)
    array = split(line)
    #println(array[1], "\t", array[2])
    gene = popfirst!(array)
    #print(gene)
    for i in eachindex(samples)
        #print("\t", samples[i])
        # println(samples[i], "\t$gene\t", array[i])
        # if !haskey(count_dict, samples[i])
        #    count_dict[samples[i]] = [gene, array[i]]
        # else
        #    push!(count_dict, samples[i] => [gene, array[i]])
        # end
        #
        # vals = get!(Vector{String, Int64}, count_dict, samples[i])
        # push!(vals, [gene, array[i]])
        #println(typeof(gene), typeof(array[i]))
        #println(typeof(parse(Int64, array[i])))
        #count = parse.(Int64, array[i])
        #println(typeof(gene), typeof(count))
        #println(typeof(gene), typeof(parse(Int64, array[i])), "\tafter")
        current = [(gene, parse.(Int64, array[i]))]
        if haskey(count_dict, samples[i])
            current = count_dict[samples[i]]
            push!(current, (gene, parse.(Int64, array[i])))
        end
        count_dict[samples[i]] = current
    end
    #println()
end
close(f)

# println(count_dict)
# for sample in count_dict
#     #println(sample)
# end
rank_dict = DefaultDict(Dict)
for sample in keys(count_dict)
    #println(sample)
    (count_dict[sample]) = sort!(count_dict[sample], by=x->x[2], alg=QuickSort)
    #println(count_dict[sample])
    tmp = 0
    count = 1
    rank = 0
    for gene_and_count in count_dict[sample]
        #println(typeof(gene_count[1]), typeof(gene_count[2]))
        #println(sample, "\t", gene_count[1], "\t", gene_count[2])
        if gene_and_count[2] == tmp

        else
            tmp = gene_and_count[2]
            rank = count
        end
        #println(gene_and_count[1], "\t", gene_and_count[2], "\t",sample, "\t", rank, "\t", count)
        rank_dict[gene_and_count[1]][sample] = rank
        count += 1
    end
end

#sort(collect(rank_dict), by = x->x[1])
for gene in sort!(collect(keys(rank_dict)))
    print(gene)
    for sample in samples
        print("\t", rank_dict[gene][sample])
    end
    println()
end
