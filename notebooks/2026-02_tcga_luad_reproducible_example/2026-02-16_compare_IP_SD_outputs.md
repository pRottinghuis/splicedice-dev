# Copmpare SD and IP output

Identify the differences in output content between SD and IP. The goal is to understand what needs to happen to get IP to work with the SD pipeline.

The following steps will be generating output using wildtype sample TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16

## Data generation

manifest.tsv content:
```tsv
TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16    /opt/data/0a26152a_wt.bam       u2af1-wt        u2af1-wt
```

Launch container:
```bash
docker run -it --rm \
    -v /mnt/data/ref/GRCh38.primary_assembly.genome.fa:/opt/data/ref/ref.fa \
    -v /mnt/data/ref/GRCh38.primary_assembly.genome.fa.fai:/opt/data/ref/ref.fa.fai \
    -v /mnt/data/tcga/0a26152a-462f-4895-8fe8-15fcdcc56e16/7a7440bf-1ca1-4c6b-80f8-7151a38e5d18.rna_seq.genomic.gdc_realn.bam:/opt/data/0a26152a_wt.bam \
    -v /mnt/data/intron_prospector_runs/run_input/manifest.tsv:/opt/data/manifest.tsv \
    -v /mnt/data/intron_prospector_runs/output:/opt/output/ \
    splicedice-tools:latest /bin/bash
```

Run splicedice bam_to_junc_bed to generate the SD output for the sample.
```bash
cd output
intronProspector -S --genome-fasta=/opt/data/ref/ref.fa \
    -c IP_metadata_0a26152a_wt.tsv \
    -j IP_B12_0a26152a_wt.bed \
    -n IP_B9_0a26152a_wt.bed \
    -b IP_B6_0a26152a_wt.bed \
    /opt/data/0a26152a_wt.bam
```

see `/mnt/data/intron_prospector_runs/2026-02-17_02-25-15`