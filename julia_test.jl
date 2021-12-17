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
println(keys(barcode_sample_dict))
#println(length(keys(barcode_sample_dict)))

barcodes = LongDNASeq.(keys(barcode_sample_dict))
# barcodes = LongDNASeq.(["ATGAGC","CAAAAG","CAACTA","CACCGG","CACGAT","CACTCA",
# "CAGGCG","CATGGC","CATTTT","CCAACA","CGGAAT","CTAGCT","CTATAC","CTCAGA","GCGCTA",
# "GGTAGC","GTAGAG","TAATCG","TACAGC","TATAAT","TCATTC","TCCCGA","TCGAAG","TCGGCA"])
dplxr = Demultiplexer(barcodes, n_max_errors=1, distance=:hamming)

#reader = open(FASTQ.Reader, "R1.fastq")
reader = FASTQ.Reader(GzipDecompressorStream(open(ARGS[2])))
for record in reader
    index = last(split(FASTQ.description(record),":"))
    #println(demultiplex(dplxr, LongDNASeq(index)))
    check = demultiplex(dplxr, LongDNASeq(index))
    #println(check)
    if check[1] != 0
        #@show FASTQ.description(record)
        #println("yes ", FASTQ.description(record))
        println(check)
        println(record)
    else
        #println("no ", FASTQ.description(record))
    end

end
close(reader)

a = 10
b = 5

println("first is $a; second is $b")
println("total is $(a+b)")

x = Dict("a" => 10, "b" => 20, "c" => 30)
println(x)
println(x["c"])
x["z"] = 1000
println(x)
x["phone"] = 911
x["phon2"] = "110"
println(x)
out = pop!(x, "c")
println(x)
println(out)

a_array = [10,100,1000]
out2 = pop!(a_array)
println(out2)
println(a_array)
