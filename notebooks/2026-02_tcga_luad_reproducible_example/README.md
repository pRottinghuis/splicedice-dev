# Investigating the Use of Intron Prospector in Place of SpliceDICE `bam_to_junc_bed`

The general workflow of SpliceDICE is:
1. Convert input BAM RNA-seq alignments into a junction BED file.
2. Quantify the junctions in the junction BED file to generate PS tables (script: `splicedice quant`).
3. Use the PS tables for downstream analysis.

The first step in the SpliceDICE (SD) pipeline is to convert input BAM RNA-seq alignments into a junction BED file. SpliceDICE provides a script called `bam_to_junc_bed` that performs this conversion.

However, we are not confident that `bam_to_junc_bed` reliably calls junctions. The junctions it identifies are reported on both strands, and they are not filtered before being written to file. Instead, it relies on downstream processing of the junction BED file to effectively "call" junctions. This results in redundant BED entries and unnecessarily large files. From a design perspective, the junction-calling component should perform both identification and filtering, rather than deferring filtering to later steps.

We are interested in using Intron Prospector (IP) in place of `bam_to_junc_bed` to generate the junction BED file for SpliceDICE. IP is a more robust junction caller, with test validation and built-in junction filtering. The purpose of the notebooks in this directory is to compare the outputs of IP and `bam_to_junc_bed`, and to plan how to refactor SpliceDICE to use IP-generated input instead.

Example data for this work comes from TCGA and is part of a dataset used to study a rare splice defect in U2AF1. The dataset includes wild-type (WT) samples without the splice defect and mutant samples with the defect. Samples are RNA-seq `.bam` files aligned to GRCh38. Each sample contains approximately 180,000 splice junctions.

## Notebooks

### `2026-02-01_tcga_luad_intronProspector_1fex.md`
This notebook attempts to use IP output directly in SpliceDICE without refactoring. SpliceDICE accepts the IP-generated BED file as input to the `quant` script. Because the format does not include an identifier in column 4 of the BED file, `splicedice quant` bypasses certain filtering steps, and the output proceeds as expected. This notebook serves as a proof of concept that IP output can be used as input to `splicedice quant`.

### `2026-02-05_tcga_luad_comp_IP_SD_bed6.md`
This notebook compares junction counts and intersections between SD and IP outputs. It provides insight into how `bam_to_junc_bed` produces redundant intron calls. It shows that IP calls a number of introns within a reasonable expected range (approximately half of SD, due to duplicated +/- strand calls in SD). It also demonstrates that the majority of junctions identified by IP are also detected by SD.

## `2026-02-16_compare_IP_SD_outputs.md`
This notebook generates all possible output formats from IP. It is used to see IP outputs and compare them to the inputs required by `splicedice quant`.

