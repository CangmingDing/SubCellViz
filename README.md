# SubCellViz · R Package

<p align="right">
  <b>中文版</b> | <a href="./README_en.md">English</a>
</p>

用于可视化基因在不同细胞类型的亚细胞定位，将定位证据分数映射到精修的 SVG 细胞模板，并输出 PNG/PDF（双格式，英文图表）。

## 安装

- 从 GitHub 安装（推荐）：

```r
install.packages('remotes')
remotes::install_github('CangmingDing/SubCellViz')
```

- 从本地 tarball 安装：

```r
install.packages('SubCellViz_0.1.0.tar.gz', repos = NULL)
```

## 快速上手

更详细的教程请参考 [example_usage.R](./example_usage.R)。

```r
# 使用感知均匀色板（色盲友好）
SubCellViz::visualize_gene_localization('TP53', 'epithelial', 'viridis', out_dir = getwd())

# 使用自定义两色渐变（逗号分隔）
SubCellViz::visualize_gene_localization('TP53', 'neuron', '#FF00FF,#00FFFF', out_dir = getwd())

# 查看所有预设配色名称
SubCellViz::subcellviz_list_palettes()
```

## 数据与来源

- 主要数据来源：
  - Janos X. Binder, Sune Pletscher-Frankild, Kalliopi Tsafou, Christian Stolte, Seán I. O’Donoghue, Reinhard Schneider, Lars Juhl Jensen, COMPARTMENTS: unification and visualization of protein subcellular localization evidence, Database, Volume 2014, 2014, bau012. DOI: https://doi.org/10.1093/database/bau012
  - COMPARTMENTS 官方网站：https://compartments.jensenlab.org/

## 资源压缩与读取

- 大型数据文件采用 bzip2（-9）单文件极致压缩：`inst/extdata/human_compartment_integrated_full.tsv.bz2`（约 26MB）。
- 包函数会自动优先读取 `.tsv.bz2`，若不存在则回退 `.tsv.gz`，最后回退 `.tsv`。
- 在 macOS/Linux 环境下若系统提供 `bzgrep`/`zgrep`，会用于高效行过滤；否则使用 R 的 `bzfile()`/`gzfile()` 流式读取。

## 许可证

MIT License，详见 [LICENSE](./LICENSE)。

## 致谢

感谢 Jensen Lab 提供 COMPARTMENTS 数据与网站资源。
