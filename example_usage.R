#' SubCellViz 亚细胞定位可视化示例脚本
#' 
#' 本脚本旨在展示如何使用 SubCellViz 包来可视化基因在不同细胞类型中的亚细胞定位。
#' 教程涵盖了从基础绘图到自定义配色的核心功能。

# 1. 环境准备 ----
# 如果尚未安装，请取消下面代码的注释进行安装：
# install.packages("remotes")
# remotes::install_github("CangmingDing/SubCellViz")

library(SubCellViz)

# --- 首次使用需激活 ---
# 运行以下命令获取您的机器码，并联系作者获取激活码：
# get_machine_code()
# 
# 拿到激活码后，运行一次即可永久激活：
# activate_subcellviz("您的激活码")
# --------------------

# 2. 基础用法：默认设置 ----
# 目标：可视化 TP53 在上皮细胞 (epithelial) 中的定位，使用默认配色 "fire"
# 结果：将在当前工作目录下生成 TP53_epithelial.png 和 TP53_epithelial.pdf
message("正在运行基础示例：TP53 在上皮细胞中的定位...")
SubCellViz::visualize_gene_localization(
  gene = "TP53", 
  cell_type = "epithelial", 
  out_dir = getwd()
)

# 3. 探索不同的细胞类型 ----
# SubCellViz 支持四种内置细胞模板：
# "human" (通用人体细胞), "muscle" (肌肉细胞), "neuron" (神经元), "epithelial" (上皮细胞)

message("正在运行多细胞类型示例：神经元...")
SubCellViz::visualize_gene_localization(
  gene = "CANX",       # 内质网标记基因
  cell_type = "neuron", 
  palette = "ocean"    # 使用内置的 "ocean" 海洋色系
)

# 4. 配色方案定制 ----
# 4.1 查看所有内置预设
# SubCellViz 提供了 20 种精心挑选的配色方案
all_palettes <- SubCellViz::subcellviz_list_palettes()
print("可用的配色预设：")
print(all_palettes)

# 4.2 使用感知均匀色板（推荐用于学术出版）
# 例如 "viridis"（色盲友好）或 "magma"
message("正在运行学术配色示例：使用 viridis...")
SubCellViz::visualize_gene_localization(
  gene = "GAPDH", 
  cell_type = "human", 
  palette = "viridis"
)

# 4.3 使用自定义双色渐变
# 格式为 "低值颜色,高值颜色"（十六进制代码）
message("正在运行自定义配色示例：紫绿渐变...")
SubCellViz::visualize_gene_localization(
  gene = "MT-CO1", 
  cell_type = "muscle", 
  palette = "#E1BEE7,#2E7D32"  # 浅紫到深绿
)

# 5. 高级：批量生成示例 ----
# 假设你有一组感兴趣的基因
my_genes <- c("TP53", "GAPDH", "MT-CO1")
output_folder <- "SubCellViz_Results"

# 创建输出目录
if (!dir.exists(output_folder)) dir.create(output_folder)

message("正在批量生成图表...")
for (g in my_genes) {
  SubCellViz::visualize_gene_localization(
    gene = g,
    cell_type = "human",
    palette = "nebula",
    out_dir = output_folder
  )
}

message("所有任务已完成！请在目录中查看生成的 PNG 和 PDF 文件。")
