rm(list=ls())
setwd("C:\\Users\\t-trchi\\Desktop\\arc_d3\\")
read.table("eQTL_analysis_clinical.txt", sep="\t", header=T, stringsAsFactors=F) -> eqtl
eqtl <- subset(eqtl, FDR > 1e-50 & FDR <= 0.05)

bin_locations <- strsplit(eqtl$SNP, split=":|-")
do.call(rbind, bin_locations) -> bin_locations
temp <- apply(bin_locations,1,function(r) {
	mean(c(as.numeric(gsub("K","000",r[2])),
	as.numeric(gsub("K","000",r[3]))))
})
bin_locations <- data.frame(bin_chr=bin_locations[,1],pos=temp)
cbind(eqtl, bin_locations) -> eqtl

readRDS("gene_locations.Rds") -> gene_locations
mid = (gene_locations$start_position + gene_locations$end_position)/2
gene_locations <- data.frame(geneid = gene_locations$hgnc_symbol, gene_chr = gene_locations$chromosome_name, mid = mid)
eqtl <- merge(eqtl, gene_locations, by.x = "gene", by.y = "geneid")



library(rjson)

for(chr in unique(eqtl$gene_chr)) {
	chr_eqtl <- subset(eqtl, gene_chr == chr)
	elements1 <- chr_eqtl[,c("gene", "mid")]; colnames(elements1) <- c("element", "position")
	elements2 <- chr_eqtl[,c("SNP", "pos")]; colnames(elements2) <- c("element", "position")
	rbind(elements1, elements2) -> elements
	unique(elements) -> elements
	ord <- order(elements$position, decreasing = F)
	elements <- elements[ord,]

	edgelist = cbind(chr_eqtl$gene, chr_eqtl$SNP)
	edgelist[,1] <- match(edgelist[,1], elements[,1])
	edgelist[,2] <- match(edgelist[,2], elements[,1])
	colnames(edgelist) <- c('source', 'target')
	class(edgelist) <- "numeric"
	edgelist[] <- edgelist - 1

	labels = elements[,1]
	group = sapply(labels, function(l) {ifelse(grepl("^chr",l,perl=T),1,2)})
	output <- list()
	output[["name"]] <- labels
	output[["group"]] <- unname(group)
	output[["source"]] <- edgelist[,"source"]
	output[["target"]] <- edgelist[,"target"]
	output[["n_nodes"]] <- length(labels)
	output[["n_edges"]] <- nrow(edgelist)
	output[["plot_label"]] <- paste("Chromosome",sub("chr","",chr))
	writeLines(toJSON(output), paste0(chr,"_data.json"))
}

