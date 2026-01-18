subcellviz_resolve_extdata_dir <- function(data_dir = NULL) {
  if (!is.null(data_dir) && nzchar(data_dir) && dir.exists(data_dir)) {
    return(normalizePath(data_dir, winslash = "/", mustWork = TRUE))
  }

  pkg_dir <- system.file("extdata", package = "SubCellViz")
  if (nzchar(pkg_dir) && dir.exists(pkg_dir)) {
    return(pkg_dir)
  }

  wd_dir <- file.path(getwd(), "inst", "extdata")
  if (dir.exists(wd_dir)) {
    return(normalizePath(wd_dir, winslash = "/", mustWork = TRUE))
  }

  wd_root <- getwd()
  if (file.exists(file.path(wd_root, "mapping.txt")) && (file.exists(file.path(wd_root, "human_compartment_integrated_full.tsv")) || file.exists(file.path(wd_root, "human_compartment_integrated_full.tsv.gz")) || file.exists(file.path(wd_root, "human_compartment_integrated_full.tsv.bz2")))) {
    return(normalizePath(wd_root, winslash = "/", mustWork = TRUE))
  }

  stop("未找到 extdata 目录。请安装 SubCellViz 包，或通过 data_dir 参数指定资源目录。")
}

subcellviz_read_gene_rows <- function(tsv_path, target_gene) {
  use_gz <- grepl("\\.gz$", tsv_path)
  use_bz <- grepl("\\.bz2$", tsv_path)
  grep_bin <- "grep"
  if (use_gz && nzchar(Sys.which("zgrep"))) grep_bin <- "zgrep"
  if (use_bz && nzchar(Sys.which("bzgrep"))) grep_bin <- "bzgrep"
  out <- tryCatch(
    system2(grep_bin, c("-w", target_gene, tsv_path), stdout = TRUE, stderr = FALSE),
    error = function(e) character(0)
  )

  if (length(out) == 0) {
    con <- if (use_gz) gzfile(tsv_path, open = "rt") else if (use_bz) bzfile(tsv_path, open = "rt") else tsv_path
    gene_data_raw <- utils::read.delim(
      con,
      header = FALSE,
      sep = "\t",
      stringsAsFactors = FALSE,
      quote = "",
      comment.char = ""
    )
    colnames(gene_data_raw) <- c("Gene_ID", "Gene_Name", "GO_ID", "Location", "Score")
    gene_data_raw <- gene_data_raw[gene_data_raw$Gene_Name == target_gene, , drop = FALSE]
    if (nrow(gene_data_raw) == 0) {
      stop(sprintf("在数据库中未找到基因: %s", target_gene))
    }
    gene_data_raw$Score <- as.numeric(gene_data_raw$Score)
    return(gene_data_raw)
  }

  gene_data_raw <- utils::read.table(text = out, sep = "\t", stringsAsFactors = FALSE, quote = "", comment.char = "")
  colnames(gene_data_raw) <- c("Gene_ID", "Gene_Name", "GO_ID", "Location", "Score")
  gene_data_raw$Score <- as.numeric(gene_data_raw$Score)
  gene_data_raw
}

subcellviz_get_color_and_opacity <- function(score, min_score, max_score, palette, is_background = FALSE) {
  if (max_score == min_score) {
    idx <- 100
  } else {
    idx <- round((score - min_score) / (max_score - min_score) * 99) + 1
  }
  idx <- max(1, min(100, idx))
  color <- palette[idx]
  opacity <- if (is_background) 0.15 else 0.75
  list(color = color, opacity = opacity)
}

#' 生成亚细胞定位上色图（PNG 与 PDF）
#'
#' @param gene 基因名，例如 "TP53"
#' @param cell_type 细胞类型：animal/muscle/neuron/epithelial
#' @param palette 配色方案：预设名（如 "viridis"）或自定义双色（如 "#FF00FF,#00FFFF"）
#' @param out_dir 输出目录
#' @param data_dir 资源目录（可选）。不填时优先使用包内 extdata
#' @return 一个列表，包含 png 和 pdf 的输出路径
#' @export
visualize_gene_localization <- function(
  gene,
  cell_type,
  palette = "fire",
  out_dir = getwd(),
  data_dir = NULL
) {
  cell_type <- tolower(cell_type)
  if (!(cell_type %in% c("animal", "muscle", "neuron", "epithelial"))) {
    stop("无效的细胞类型。请选择: animal, muscle, neuron, epithelial")
  }
  if (is.null(gene) || !nzchar(gene)) {
    stop("gene 不能为空")
  }

  ext_dir <- subcellviz_resolve_extdata_dir(data_dir)
  tsv_bz <- file.path(ext_dir, "human_compartment_integrated_full.tsv.bz2")
  tsv_gz <- file.path(ext_dir, "human_compartment_integrated_full.tsv.gz")
  tsv_plain <- file.path(ext_dir, "human_compartment_integrated_full.tsv")
  tsv_path <- if (file.exists(tsv_bz)) tsv_bz else if (file.exists(tsv_gz)) tsv_gz else tsv_plain
  mapping_path <- file.path(ext_dir, "mapping.txt")
  svg_map <- list(
    animal = file.path(ext_dir, "Animal_cells.svg"),
    muscle = file.path(ext_dir, "Muscle_cells.svg"),
    neuron = file.path(ext_dir, "Neuron_cells.svg"),
    epithelial = file.path(ext_dir, "Epithelial_cells.svg")
  )
  svg_path <- svg_map[[cell_type]]

  if (!file.exists(tsv_path)) stop(sprintf("缺少 TSV 文件: %s", tsv_path))
  if (!file.exists(mapping_path)) stop(sprintf("缺少 mapping 文件: %s", mapping_path))
  if (!file.exists(svg_path)) stop(sprintf("缺少 SVG 模板: %s", svg_path))
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

  message(sprintf("正在为基因 [%s] 在 [%s] 细胞中生成可视化 (配色: %s)...", gene, cell_type, palette))
  current_palette <- subcellviz_get_palette_100(palette)

  exclude_components <- c("Extracellular space", "Extracellular matrix", "Secreted", "Basement membrane")
  bg_components <- c("Cytoplasm", "Cytosol")

  gene_data_raw <- subcellviz_read_gene_rows(tsv_path, gene)

  mapping <- utils::read.table(mapping_path, sep = "\t", header = FALSE, stringsAsFactors = FALSE, quote = "", comment.char = "")
  colnames(mapping) <- c("Raw_Location", "SVG_Label")

  gene_data <- gene_data_raw |>
    dplyr::filter(.data$Gene_Name == gene) |>
    dplyr::inner_join(mapping, by = c("Location" = "Raw_Location")) |>
    dplyr::group_by(.data$SVG_Label) |>
    dplyr::summarize(Score = max(.data$Score, na.rm = TRUE), .groups = "drop") |>
    dplyr::filter(!is.na(.data$Score))

  if (nrow(gene_data) == 0) {
    stop("该基因的定位术语未能映射到任何 SVG 标签，请检查 mapping.txt")
  }

  min_s <- 0
  max_s <- max(gene_data$Score, 5)

  svg <- xml2::read_xml(svg_path)
  ns <- xml2::xml_ns(svg)

  for (i in seq_len(nrow(gene_data))) {
    loc_name <- gene_data$SVG_Label[i]
    score <- gene_data$Score[i]

    if (loc_name %in% exclude_components) {
      next
    }

    is_bg <- loc_name %in% bg_components
    res <- subcellviz_get_color_and_opacity(score, min_s, max_s, current_palette, is_bg)

    xpath <- sprintf("//d1:g[d1:text[@class='subcell_name' and text()='%s']]", loc_name)
    target_gs <- xml2::xml_find_all(svg, xpath, ns)
    if (length(target_gs) == 0) next

    for (g in target_gs) {
      colored_elements <- xml2::xml_find_all(g, ".//*[contains(@class, ' coloured')]", ns)
      for (elem in colored_elements) {
        xml2::xml_set_attr(elem, "fill", res$color)
        xml2::xml_set_attr(elem, "fill-opacity", as.character(res$opacity))
      }
    }
  }

  watermark_ids <- c("SwissBioPics_logo", "sib_logo")
  for (wid in watermark_ids) {
    wm <- xml2::xml_find_all(svg, sprintf("//*[@id='%s']", wid), ns)
    if (length(wm) > 0) xml2::xml_remove(wm)
  }

  legend_w <- 45
  legend_h <- 600
  legend_font_size <- 30
  legend_title_size <- 36

  viewbox_attr <- xml2::xml_attr(svg, "viewBox")
  if (!is.na(viewbox_attr)) {
    vb_expanded <- as.numeric(strsplit(viewbox_attr, "\\s+")[[1]])
    title_text <- sprintf("Subcellular localization of %s in %s cells", gene, cell_type)
    title_x <- vb_expanded[1] + (vb_expanded[3] / 2)
    title_y <- vb_expanded[2] + 60
    title_node <- xml2::xml_add_child(
      svg,
      "text",
      x = as.character(title_x),
      y = as.character(title_y),
      `font-family` = "Helvetica, Arial",
      `font-size` = "40",
      `font-weight` = "bold",
      fill = "black",
      `text-anchor` = "middle"
    )
    xml2::xml_text(title_node) <- title_text

    legend_x <- vb_expanded[1] + vb_expanded[3] - 250
    legend_y <- vb_expanded[2] + (vb_expanded[4] - legend_h) / 2 + 50
  } else {
    legend_x <- 1000
    legend_y <- 100
  }

  defs <- xml2::xml_find_first(svg, "//d1:defs", ns)
  if (inherits(defs, "xml_missing")) {
    defs <- xml2::xml_add_child(svg, "defs", .where = 0)
  }

  grad_id <- "scoreGradient"
  xml2::xml_remove(xml2::xml_find_all(defs, sprintf(".//*[@id='%s']", grad_id), ns))
  lg <- xml2::xml_add_child(defs, "linearGradient", id = grad_id, x1 = "0%", y1 = "100%", x2 = "0%", y2 = "0%")

  palette_colors <- current_palette[seq(1, 100, length.out = 5)]
  for (j in seq_len(5)) {
    xml2::xml_add_child(
      lg,
      "stop",
      offset = sprintf("%d%%", (j - 1) * 25),
      `stop-color` = palette_colors[j],
      `stop-opacity` = "0.8"
    )
  }

  legend_g <- xml2::xml_add_child(svg, "g", transform = sprintf("translate(%.2f, %.2f)", legend_x, legend_y))
  xml2::xml_add_child(
    legend_g,
    "rect",
    x = "0",
    y = "0",
    width = as.character(legend_w),
    height = as.character(legend_h),
    fill = sprintf("url(#%s)", grad_id),
    stroke = "#333333",
    `stroke-width` = "1"
  )

  xml2::xml_add_child(
    legend_g,
    "text",
    x = "0",
    y = "-25",
    `font-family` = "Helvetica, Arial",
    `font-size` = as.character(legend_title_size),
    `font-weight` = "bold",
    fill = "black",
    text = "Score"
  )

  ticks <- seq(min_s, max_s, length.out = 5)
  for (k in seq_along(ticks)) {
    y_pos <- legend_h - (k - 1) * (legend_h / (length(ticks) - 1))
    txt_node <- xml2::xml_add_child(
      legend_g,
      "text",
      x = as.character(legend_w + 15),
      y = as.character(y_pos + 10),
      `font-family` = "Helvetica, Arial",
      `font-size` = as.character(legend_font_size),
      fill = "black"
    )
    xml2::xml_text(txt_node) <- sprintf("%.1f", ticks[k])
  }

  out_prefix <- file.path(out_dir, sprintf("%s_%s_localization", gene, cell_type))
  svg_text <- as.character(svg)
  svg_raw <- charToRaw(svg_text)

  png_path <- paste0(out_prefix, ".png")
  pdf_path <- paste0(out_prefix, ".pdf")
  rsvg::rsvg_png(svg_raw, png_path)
  rsvg::rsvg_pdf(svg_raw, pdf_path)
  list(png = png_path, pdf = pdf_path)
}
