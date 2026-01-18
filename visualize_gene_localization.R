#!/usr/local/bin/Rscript

suppressPackageStartupMessages({
  library(xml2)
  library(dplyr)
  library(rsvg)
  library(RColorBrewer)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  cat("用法: /usr/local/bin/Rscript visualize_gene_localization.R <基因名> <细胞类型> [配色方案]\n")
  cat("细胞类型可选: animal, muscle, neuron, epithelial\n")
  cat("配色方案可选: 预设名(如 viridis, gfp) 或 自定义双色(如 '#FF0000,#0000FF')\n")
  q(status = 1)
}

gene <- args[1]
cell_type <- tolower(args[2])
palette <- if (length(args) >= 3) args[3] else "fire"

source(file.path(getwd(), "R", "palettes.R"))
source(file.path(getwd(), "R", "visualize_gene_localization.R"))

res <- visualize_gene_localization(
  gene = gene,
  cell_type = cell_type,
  palette = palette,
  out_dir = getwd(),
  data_dir = file.path(getwd(), "inst", "extdata")
)
message(sprintf("成功生成: %s, %s", res$png, res$pdf))
