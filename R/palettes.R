COLOR_PRESETS <- list(
  "fire"      = c("#FFECB3", "#E65100"),
  "ocean"     = c("#E1F5FE", "#01579B"),
  "forest"    = c("#F1F8E9", "#1B5E20"),
  "royal"     = c("#F3E5F5", "#4A148C"),
  "viridis"   = c("#440154", "#FDE725"),
  "magma"     = c("#000004", "#FCFDBB"),
  "plasma"    = c("#0D0887", "#F0F921"),
  "cividis"   = c("#00224E", "#FEE838"),
  "gfp"       = c("#E8F5E9", "#2E7D32"),
  "he"        = c("#FCE4EC", "#880E4F"),
  "blood"     = c("#FFEBEE", "#B71C1C"),
  "cy3"       = c("#FFF3E0", "#E64A19"),
  "sakura"    = c("#FFF5F7", "#FF69B4"),
  "glacier"   = c("#E0F7FA", "#006064"),
  "gold"      = c("#FFF9C4", "#F9A825"),
  "earth"     = c("#EFEBE9", "#3E2723"),
  "neon"      = c("#00FFA3", "#DC00FF"),
  "cyber"     = c("#050505", "#00FF00"),
  "nebula"    = c("#240B36", "#C31432"),
  "midnight"  = c("#1A237E", "#FFD600")
)

#' 列出可用的预设配色名称
#' @return 字符向量，包含可用配色预设名
#' @export
subcellviz_list_palettes <- function() {
  names(COLOR_PRESETS)
}

subcellviz_get_palette_100 <- function(palette_name) {
  if (is.null(palette_name) || palette_name == "") {
    return(grDevices::colorRampPalette(RColorBrewer::brewer.pal(9, "YlOrRd"))(100))
  }

  if (tolower(palette_name) %in% names(COLOR_PRESETS)) {
    colors <- COLOR_PRESETS[[tolower(palette_name)]]
    return(grDevices::colorRampPalette(colors)(100))
  }

  if (grepl(",", palette_name, fixed = TRUE)) {
    colors <- unlist(strsplit(palette_name, ",", fixed = TRUE))
    return(tryCatch(
      grDevices::colorRampPalette(colors)(100),
      error = function(e) grDevices::colorRampPalette(RColorBrewer::brewer.pal(9, "YlOrRd"))(100)
    ))
  }

  grDevices::colorRampPalette(RColorBrewer::brewer.pal(9, "YlOrRd"))(100)
}
