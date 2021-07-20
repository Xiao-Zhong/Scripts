using FASTX
using BioSequences
using CodecZlib

barcode_sample_dict = Dict{String,String}()
f = open(ARGS[1], "r")
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
dplxr = Demultiplexer(barcodes, n_max_errors=parse.(Int8, ARGS[3]), distance=:hamming)

#reader = open(FASTQ.Reader, "R1.fastq")
reader = FASTQ.Reader(GzipDecompressorStream(open(ARGS[2])))
for record in reader
    dual_index = last(split(FASTQ.description(record),":"))
    index = split(dual_index, "+")[1]
    #println(index)
    check = demultiplex(dplxr, LongDNASeq(index))
    #println(check)
    if check[1] != 0
        #@show FASTQ.description(record)
        #println("yes ", FASTQ.description(record))
        #println(check)
        #println(keys_as_vector[check[1]])
        barcode = keys_as_vector[check[1]]
        #println(barcode)
        #ßprintln(barcode_sample_dict[keys_as_vector[check[1]]])
        sample = barcode_sample_dict[barcode]
        #println(record)
        w = GzipCompressorStream(open("$sample.fq.gz", "a"));
        write(w, record,"\n");
        close(w);
    else
        #println("no ", FASTQ.description(record))
    end
end
close(reader)
