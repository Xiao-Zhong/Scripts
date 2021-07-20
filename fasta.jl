using FASTX
using BioSequences
using DataStructures
using ArgParse
#import ArgParse: ArgParseSettings, @add_arg_table!, parse_args

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
        tmp = split(line)
        columns = [tmp[1], tmp[2], parse.(Int64,tmp[3]), parse.(Int64,tmp[4]), tmp[5], tmp[6]]
        #println(columns[3])
        #println(typeof(columns[3]))
        #println(columns)
        (columns[3], columns[4]) = (columns[3] < columns[4]) ? (columns[3], columns[4]) : (columns[4], columns[3])
        #println(columns)
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
            #(gene_dict[gene][feature]) = sort!(gene_dict[gene][feature], by=x->x[3], alg=QuickSort)
            #println("before: ", gene_dict[gene][feature])
            sort!(gene_dict[gene][feature], by=x->x[3], alg=QuickSort)
            #println("after: ", gene_dict[gene][feature])
            seq_id = gene_dict[gene][feature][1][1]
            start_gene = gene_dict[gene][feature][1][3]
            stop_gene = gene_dict[gene][feature][end][4]
            strand = gene_dict[gene][feature][1][5]
            seq = ""
            for feature_line in gene_dict[gene][feature]
                #println(feature_line)
                seq *= SubString(seq_dict[seq_id], feature_line[3], feature_line[4])
            end
            if strand == "-"
                seq = reverse_complement(LongDNASeq(seq))
            end

            if (feature == "gene")
                println(">$gene\t[gene]\t$seq_id|$start_gene..$stop_gene|$strand\t$(length(seq))\n$seq")
            else
                println(">$gene\t[cds]\t$seq_id|$strand\t$(length(seq))\n$seq")
            end
        end
    end
end

function extract_seq(input_fasta, input_gene)
    fasta_read(input_fasta)
    gene_read(input_gene)
    fasta_output()
end

#extract_seq(ARGS[1], ARGS[2])

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "-t"
            help = "extract gene or cds sequences (gene|cds)"
            default = "gene"
        # "--flag1"
        #     help = "an option without argument, i.e. a flag"
        #     action = :store_true
        "<sequence_input>"
            help = "sequence file"
            required = true
        "<gene_input>"
            help = "gene position file"
            required = true
        # "<type>"
        #     help = "extract gene or cds sequences (gene|cds)"
        #     #arg_type = Int
        #     default = "gene"
        #     required = true
    end
    println(parse_args(s))
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    #println(parsed_args)
    # println("Parsed args:")
    # for (arg,val) in parsed_args
    #     println("  $arg  =>  $val")
    # end
    #println(values(parsed_args))
    #println(values(parsed_args)[2])
    #println(values(parsed_args)[3])
    println(ARGS[1], "\t", ARGS[2], "\t", ARGS[3])
    extract_seq(ARGS[1], ARGS[2])
end

main()
