library("heatmaply")

dist_taxon <- read.table("./dist_taxon.txt", header=FALSE, sep = "\t", row.names = 1)
#dist_taxon <- dist_taxon[order(dist_taxon$V3),]

overlap <- read.table("./compare2_v0714_sum.txt", header=TRUE, row.names = 1)
#overlap_test <- head(overlap, 500)
# heatmaply(overlap_test, 
#           seriate = "mean",
#           showticklabels = c(FALSE, FALSE),
#           #row_dend_left = TRUE,
#           plot_method = "plotly",
#           dendrogram = "row"
#)

mat <- overlap
mat[] <- paste("Taxon:", dist_taxon$V6)
mat[] <- lapply(colnames(mat), function(colname) {
  paste0(mat[, colname])
})

heatmaply(
  overlap,
  custom_hovertext = mat,
  seriate = "mean",
  showticklabels = c(FALSE, FALSE),
  Colv = FALSE,
  #plot_method = "plotly",
  file = "diff_heatmap.html"
)
