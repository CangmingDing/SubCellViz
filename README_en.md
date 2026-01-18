# SubCellViz · R Package

<p align="right">
  <a href="./README.md">中文版</a> | <b>English</b>
</p>

Visualize gene subcellular localization across cell types by mapping evidence scores onto curated SVG templates and exporting PNG/PDF (dual format, English figures).

## Installation

- From GitHub (recommended):

```r
install.packages('remotes')
remotes::install_github('CangmingDing/SubCellViz')
```

- From local tarball:

```r
install.packages('SubCellViz_0.1.0.tar.gz', repos = NULL)
```

### Activation

Activation is required for the first use. Run the following command in R to get your machine code, and contact the author (email: 20220123072@bucm.edu.cn) to obtain an activation code:

```r
library(SubCellViz)
get_machine_code()  # Copy and send your machine code to the author
activate_subcellviz('YOUR_ACTIVATION_CODE')  # Run after receiving the code
```

## Quick Start

For a detailed tutorial, please refer to [example_usage.R](./example_usage.R).

```r
# Perceptually uniform palette (colorblind friendly)
SubCellViz::visualize_gene_localization('TP53', 'epithelial', 'viridis', out_dir = getwd())

# Custom two-color gradient (comma-separated)
SubCellViz::visualize_gene_localization('TP53', 'neuron', '#FF00FF,#00FFFF', out_dir = getwd())

# List available presets
SubCellViz::subcellviz_list_palettes()
```

## Data Sources

- Janos X. Binder, Sune Pletscher-Frankild, Kalliopi Tsafou, Christian Stolte, Seán I. O’Donoghue, Reinhard Schneider, Lars Juhl Jensen, COMPARTMENTS: unification and visualization of protein subcellular localization evidence, Database, Volume 2014, 2014, bau012. DOI: https://doi.org/10.1093/database/bau012
- COMPARTMENTS official website: https://compartments.jensenlab.org/

## Resources & Compression

- Large dataset shipped as bzip2 (-9) single-file extreme compression: `inst/extdata/human_compartment_integrated_full.tsv.bz2` (~26MB).
- Functions automatically prefer `.tsv.bz2`, fall back to `.tsv.gz`, then `.tsv`.
- On macOS/Linux, `bzgrep`/`zgrep` will be used for efficient row filtering; otherwise R's `bzfile()`/`gzfile()` streaming readers are used.

## License

MIT License, see [LICENSE](./LICENSE).

## Acknowledgements

Thanks to Jensen Lab for providing COMPARTMENTS data and website resources.
