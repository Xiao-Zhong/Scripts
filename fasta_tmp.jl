using FASTX
using BioSequences
using DataStructures

seq_dict = Dict{String,String}()
function fasta_read(fasta_input)
    reader = open(FASTA.Reader, fasta_input)
    for record in reader
        sequence = FASTA.sequence(record)
        id = FASTA.identifier(record)
        #println(id)
        #println(sequence)
        #println(length(sequence))
        seq_dict[id] = sequence
    end
    close(reader)
end

gene_dict = DefaultDict(Dict)
function gene_read(gene_input)
    f = open(gene_input, "r")
    lines = readlines(f)
    for line in lines
        #println(line)
        columns = split(line)
        (columns[3], columns[4]) = (columns[3] < columns[4]) ? (columns[3], columns[4]) : (columns[4], columns[3])
        # if haskey(seq_dict, columns[1])
        #     println(columns[1])
        # else
        #     println("no\t", columns[1])
        # end
        # if columns[2] == "gene"
        #     #println("yes\t", columns[6])
        #     gene_dict[columns[6]]["gene"] = columns
        # end

        #if columns[2] == "exon"
            #push!(gene_dict[columns[6]["exon"]], columns)
            current = [columns]
            if haskey(gene_dict, columns[6])
                if haskey(gene_dict[columns[6]], columns[2])
                    #println(columns[6], ": has the key")
                    current = gene_dict[columns[6]][columns[2]]
                    push!(current, columns)
                end
                #gene_dict[columns[6]] = current
            end
            gene_dict[columns[6]][columns[2]] = current
        #end
    end
end

function fasta_output()
    for gene in keys(gene_dict)
        #println(gene)
        for feature in keys(gene_dict[gene])
            #println(feature)
            seq_id = gene_dict[gene][feature][1][1]
            strand = gene_dict[gene][feature][1][5]

            seq = ""
            for feature_line in gene_dict[gene][feature]
                #println(feature_line)
                start_exon = parse.(Int64, feature_line[3])
                stop_exon = parse.(Int64, feature_line[4])
                #println(SubString(seq_dict[seq_id], start_exon, stop_exon))
                seq *= SubString(seq_dict[seq_id], start_exon, stop_exon)
            end
            if strand == "-"
                seq = reverse_complement(LongDNASeq(seq))
            end

            if (feature == "gene")
                start_gene = parse.(Int64, gene_dict[gene][feature][1][3])
                stop_gene = parse.(Int64, gene_dict[gene][feature][end][4])
                println(">$gene\t[gene]\t$seq_id|$start_gene..$stop_gene|$strand\n$seq")
            else
                println(">$gene\t[exon]\t$seq_id|$strand\n$seq")
            end
        end
    end
end

function extract_seq(a, b)
    fasta_read(a)
    gene_read(b)
    fasta_output()
end

extract_seq(ARGS[1], ARGS[2])
