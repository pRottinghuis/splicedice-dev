# Investigate Using Intron Prospector in place of SpliceDICE bam_to_junc_bed

The first step in the SpliceDICE pipeline is to convert input BAM RNA-seq alignments into a junction BED file. SpliceDICE has a script called bam_to_junc_bed that performs this conversion.
However, we are not confident that bam_to_junc_bed reliably calls junctions. The junctions that are called, get called on both strands, and the junctions are not filtered before they are written
to a file. It relies on downstream processing of the junction bed to actually "call" junctions. This leads to redundant bed entries and unecessarily large bed files. From a design standpoint,
the junction calling component should also call the junctions and not require junction filtering downstream.

We are interested in using intronProspector (IP) in place of bam_to_junc_bed to generate the junction bed file for SpliceDICE. IP is a more robust junction caller with test validation and junction
filtering. The purpose of the notebooks in this directory is to compare the outputs of IP and bam_to_junc_bed to plan how to refactor SpliceDICE to use IP input instead of bam_to_junc_bed.

Example data for this work comes from TCGA and is part of a dataset to study a rare splice defect in U2AF1. Data includes WT samples without the splice defect and mutant samples with the splice defect.
Samples are RNA-seq .bam files aligned to GRCh38. Each sample has ~180k splice junctions.