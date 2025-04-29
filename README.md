# Transcriptomic profiling of the olfactory organs in mice
Bachelor thesis in Bioinformatics, Charles University  \
Gress Michal  2025

This repo contains main scripts used in data analysis in my bachelor thesis. However, this repo is not self-sufficient and only complements metodology and code snippets described in thesis. Original dataset was published [in 2018 in study](https://www.researchgate.net/publication/322935517_Transcriptomic_and_Proteomic_Profiling_Revealed_High_Proportions_of_Odorant_Binding_and_Antimicrobial_Defense_Proteins_in_Olfactory_Tissues_of_the_House_Mouse): doi 10.3389/fgene.2018.00026.

Among scripts are extraction and remapping of old fragments; API requests for STRING, PANTHER and clusterProfiler; DESeq2 analysis and FPKM normalization.

In `data/` list of input gene for each view is to be found. View were filtered from `data/deseq-results/` by constraints:
1. View1: padj < 0.1;
2. View2: abs(LFC) > 2 && pval < 0.05;
3. View3: tom 100 form sorted by FPKM

In `data/go-results`, all experiments are listed, BP - biological process and MF - molecular function. Each experiment contains `venn_summary.xls` table summarizing counts and ids of hits in particular Venn diagram regions. Additionally, for each non-empty region a coressponding `.txt` file exists with full name and description of the terms.

Finally `data/fpkm-results/` contains Ensemble id, name and *fragment per kilobase per millions* normalized expression level. This can be easily reproduced by `scripts/fpkm-routine.ipynb`.

Further questions refer to: gressm@natur.cuni.cz
