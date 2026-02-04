# Run intronProspector into SpliceDICE on 1 sample

Follow to get the ref genome and annotation setup: https://github.com/pRottinghuis/splicedice-dev/blob/develop/notebooks/setup/ref_genomes.md

# Instructions for wt .bam File (TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16)

1. If not already done, build the SpliceDICE and intronProspector docker image.
```bash
docker build -t splicedice-dev:latest .
```

2. Create output directory for the run.
```bash
TS=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p /mnt/data/intron_prospector_runs/"$TS"/0a26152a-462f-4895-8fe8-15fcdcc56e16
```

3. Run the docker container with the appropriate volume mounts.
```bash
docker run -it --rm \
    -v /mnt/data/ref/GRCh38.primary_assembly.genome.fa:/opt/data/ref/ref.fa \
    -v /mnt/data/tcga/0a26152a-462f-4895-8fe8-15fcdcc56e16/7a7440bf-1ca1-4c6b-80f8-7151a38e5d18.rna_seq.genomic.gdc_realn.bam:/opt/data/tcga/0a26152a-462f-4895-8fe8-15fcdcc56e16/alns.bam \
    -v /mnt/data/intron_prospector_runs/"$TS"/0a26152a-462f-4895-8fe8-15fcdcc56e16/:/opt/data/output/0a26152a-462f-4895-8fe8-15fcdcc56e16/ \
    splicedice-tools:latest /bin/bash
```

4. Inside the container, generate index for the reference genome. This is required by intronProspector.
```bash
samtools faidx /opt/data/ref/ref.fa
```

5. Run intronProspector on the sample BAM file.
```bash
intronProspector -S --genome-fasta=/opt/data/ref/ref.fa --junction-bed=/opt/data/output/0a26152a-462f-4895-8fe8-15fcdcc56e16/juncs.bed /opt/data/tcga/0a26152a-462f-4895-8fe8-15fcdcc56e16/alns.bam
```

# Instructions for s34f .bam File (TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2)
1. If not already done, build the SpliceDICE and intronProspector docker image.
```bash
docker build -t splicedice-dev:latest .
```

2. Create output directory for the run. Consider using the same timestamp as above for easier tracking.
```bash
TS=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p /mnt/data/intron_prospector_runs/"$TS"/0ebf5cc5-f242-45ef-821a-939b51dc95a2
```

3. Run the docker container with the appropriate volume mounts.
```bash
docker run -it --rm \
    -v /mnt/data/ref/GRCh38.primary_assembly.genome.fa:/opt/data/ref/ref.fa \
    -v /mnt/data/tcga/0ebf5cc5-f242-45ef-821a-939b51dc95a2/330845b9-1d53-47af-8cb7-30ce5d30625d.rna_seq.genomic.gdc_realn.bam:/opt/data/tcga/0ebf5cc5-f242-45ef-821a-939b51dc95a2/alns.bam \
    -v /mnt/data/intron_prospector_runs/"$TS"/0ebf5cc5-f242-45ef-821a-939b51dc95a2/:/opt/data/output/0ebf5cc5-f242-45ef-821a-939b51dc95a2/ \
    splicedice-tools:latest /bin/bash
```

4. Inside the container, generate index for the reference genome. This is required by intronProspector.
```bash
samtools faidx /opt/data/ref/ref.fa
```

5. Run intronProspector on the sample BAM file.
```bash
intronProspector -S --genome-fasta=/opt/data/ref/ref.fa --junction-bed=/opt/data/output/0ebf5cc5-f242-45ef-821a-939b51dc95a2/juncs.bed /opt/data/tcga/0ebf5cc5-f242-45ef-821a-939b51dc95a2/alns.bam
```
