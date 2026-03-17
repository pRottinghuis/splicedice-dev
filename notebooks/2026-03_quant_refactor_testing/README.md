# SpliceDICE Quant Refactor Testing

SpliceDICE's `quant` script is intended to perform quantification of splice junctions and generate PS tables from junction BED files. However, `quant` currently contains code that functionally "calls" junctions from the input BED file and then quantifies PS values for those called junctions. It also supports multiple input formats (e.g., `bam_to_junc_bed` output, BED6, STAR, etc.), which makes the code complex, difficult to maintain, and challenging to test.

We aim to refactor `quant` to separate the responsibilities of junction calling and quantification, and to require a single input format (BED6). This will make the code significantly easier to maintain and test. The notebooks in this directory are used to validate that the refactor does not unintentionally change the behavior of `quant`.

The junction filtering and calling getting removed from `quant` will instead be handled by IntronProspector. This is a more robust junction caller that provides the desired BED6 input format for `quant`. See `notebooks/2026-02_tcga_luad_reproducible_example/README.md` for more details on transitioning to IntronProspector.

## Notebooks

### 2026-03-03_test_new_old_quant.md
This notebook runs both the pre-refactor and post-refactor versions of `quant` on a TCGA sample and compares the outputs. Both versions of `quant` are provided with the same input BED file. As expected, the outputs are identical (~180k junctions).

### 2026-03-10_test_quant_refactor_toy_data.md
This notebook performs the same comparison between pre-refactor and post-refactor versions of `quant`, but uses a toy dataset. This provides a more controlled comparison than the previous notebook. As expected, the outputs are identical (4 junctions).
