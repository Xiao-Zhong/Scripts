using FASTX
using BioSequences
using CodecZlib

function demux(sample_table, fastq_file, mismatch)
    barcode_sample_dict = Dict{String,String}()
    f = open(sample_table, "r")
    for line in readlines(f)
        array = split(line, ",")
        #barcode_sample = Dict(array[4] => array[2])
        barcode_sample_dict[array[4]] = array[2]
    end
    close(f)
    #println(barcode_sample_dict["GTAGAG"])
    #println(keys(barcode_sample_dict))
    #println(length(keys(barcode_sample_dict)))
    keys_as_vector = collect(keys(barcode_sample_dict))
    #println(keys_as_vector[15])

    barcodes = LongDNASeq.(keys(barcode_sample_dict))
    # barcodes = LongDNASeq.(["ATGAGC","CAAAAG","CAACTA","CACCGG","CACGAT","CACTCA",
    # "CAGGCG","CATGGC","CATTTT","CCAACA","CGGAAT","CTAGCT","CTATAC","CTCAGA","GCGCTA",
    # "GGTAGC","GTAGAG","TAATCG","TACAGC","TATAAT","TCATTC","TCCCGA","TCGAAG","TCGGCA"])
    dplxr = Demultiplexer(barcodes, n_max_errors=parse.(Int8, mismatch), distance=:hamming)

    function output(sample, record)
        writer = FASTQ.Writer(GzipCompressorStream(open("$sample.fastq", "a")))
        write(writer, record)
        close(writer)
    end
    
    output_dict = Dict{String, String}()
    #reader = open(FASTQ.Reader, "R1.fastq")
    reader = FASTQ.Reader(GzipDecompressorStream(open(fastq_file)))
    record = FASTQ.Record()
    while !eof(reader)
        read!(reader, record)
        #for record in reader
        index = last(split(FASTQ.description(record),":"))
        #println(demultiplex(dplxr, LongDNASeq(index)))
        check = demultiplex(dplxr, LongDNASeq(index))
        #println(check)
        if check[1] !== 0
            #@show FASTQ.description(record)
            #println("yes ", FASTQ.description(record))
            #println(check)
            #println(keys_as_vector[check[1]])
            barcode = keys_as_vector[check[1]]
            #println(barcode_sample_dict[keys_as_vector[check[1]]])
            sample = barcode_sample_dict[barcode]
            #println(record)
            #w = GzipCompressorStream(open("$sample.fq.gz", "a"))
            output(sample, record)

            # writer = FASTQ.Writer(open("$sample.fastq", "a"))
            # write(writer, FASTQ.Record(identifier, description, sequence, quality; offset=33))
            # close(writer)
            # if get(output_dict, sample, nothing) !== nothing
            #     push!(output_dict[sample], record)
            # else
            #     output_dict[sample] = record
            # end
        else
            #println("no ", FASTQ.description(record))
        end
    end
    close(reader)
    #record = eltype(w)()
end


@time demux(ARGS[1], ARGS[2], ARGS[3])
