using RCall

include("embl_taxonomy.jl")
taxonomies = readtaxonomy("embl_taxonomy.bin")
#println(taxonomies)
#println(taxonomies["MT879754"])

overlap_file = open(ARGS[1], "r")
head = readline(overlap_file)
# #println(head, "\t", "Taxon")
output = "$head\tTaxon\n"
#println(table)

lines2 = readlines(overlap_file)
for line in lines2
    id = split(line)[1]
    #println(line, "\t", taxonomies[id])
    #println(taxonomies[id][1], "\t", taxonomies[id][2])
    if ARGS[2] in taxonomies[id]
        position = findfirst(isequal(ARGS[2]), taxonomies[id])
        #println("yes", "\t", position, "\t", taxonomies[id][position:end])
        #println(line, "\t", taxonomies[id][position:end])
        taxon = join(taxonomies[id][position:end], ", ")
        #println(typeof(taxon))
        #global table *= "$line\t" * taxon * "\n"
        global output *= "$line\t$taxon\n"
    else
        #println(ARGS[2], " cannot be found in the taxon")
    end
end
#print(typeof(table))

w = open("tmp.txt", "w")
write(w, output)
close(w)

#print(R"rnorm(10)")
R"""
library("heatmaply")

table <- read.table("tmp.txt", header=TRUE, row.names = 1, sep = "\t")

text <- table$Taxon
table$Taxon <- NULL

mat <- table
mat[] <- paste("Taxon:", text)
mat[] <- lapply(colnames(mat), function(colname){
  paste0(mat[, colname])
})

heatmaply(
  table,
  custom_hovertext = mat,
  seriate = "mean",
  showticklabels = c(FALSE, FALSE),
  Colv = FALSE,
  #plot_method = "plotly",
  file = paste($(ARGS[2]), "diff_heatmap.html", sep="_")
)
"""

#rm("tmp.txt")