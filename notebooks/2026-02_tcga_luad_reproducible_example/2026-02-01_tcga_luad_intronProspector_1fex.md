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
    -v /mnt/data/intron_prospector_runs/output:/opt/data/output/ \
    splicedice-tools:latest /bin/bash
```

4. Inside the container, generate index for the reference genome. This is required by intronProspector.
```bash
samtools faidx /opt/data/ref/ref.fa
```

5. Run intronProspector on the sample BAM file.
```bash
intronProspector -S --genome-fasta=/opt/data/ref/ref.fa --intron-bed6=/opt/data/output/IP_0a26152a_wt_juncs.bed /opt/data/tcga/0a26152a-462f-4895-8fe8-15fcdcc56e16/alns.bam
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
    -v /mnt/data/intron_prospector_runs/output:/opt/data/output/ \
    splicedice-tools:latest /bin/bash
```

4. Inside the container, generate index for the reference genome. This is required by intronProspector.
```bash
samtools faidx /opt/data/ref/ref.fa
```

5. Run intronProspector on the sample BAM file.
```bash
intronProspector -S --genome-fasta=/opt/data/ref/ref.fa --intron-bed6=/opt/data/output/IP_0ebf5cc5_mut_juncs.bed /opt/data/tcga/0ebf5cc5-f242-45ef-821a-939b51dc95a2/alns.bam
```

# Format intronProspector output for SpliceDICE

1. Move the generated junction BED files from intronProspector into a similair format that bam_to_junc_bed outputs.

```bash
cd /mnt/data/intron_prospector_runs/"$TS"
mkdir _junction_beds
mv 0a26152a-462f-4895-8fe8-15fcdcc56e16/ _junction_beds/
mv 0ebf5cc5-f242-45ef-821a-939b51dc95a2/ _junction_beds/
```

2. Create _manifest.tsv

Make sure that there are tab separators between columns.
These paths are relative to mounts in a container.

```
TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16    opt/data/_junction_beds/0a26152a-462f-4895-8fe8-15fcdcc56e16/juncs.bed u2af1-wt        u2af1-wt
TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2    opt/data/_junction_beds/0ebf5cc5-f242-45ef-821a-939b51dc95a2/juncs.bed u2af1-s34f      u2af1-s34f
```

2. run SpliceDICE quant to quantify splice junciton usage.

```bash
docker run --rm \
    -v /mnt/data/intron_prospector_runs/"$TS"/:/opt/data \
    splicedice-tools:latest splicedice quant -m /opt/data/_manifest.tsv -o /opt/data/
```

std_out:
```
/usr/local/lib/python3.8/site-packages/splicedice/SPLICEDICE.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 2 files...
        Done [0:00:1.41]
Finding clusters from 243675 junctions...
        Done [0:00:1.88]
Writing cluster file...
        Done [0:00:1.88]
Writing junction bed file...
        Done [0:00:1.33]
Gathering junction counts...
        Done [0:00:2.42]
Writing inclusion counts...
        Done [0:00:2.26]
Calculating PS values...
        Done [0:00:4.00]
Writing PS values...
        Done [0:00:2.09]
All done [0:00:17.26]
```

output:
```
_allPS.tsv
_inclusionCounts.tsv
_junctions.bed
_allClusters.tsv
```

# Signature analysis

1. Create sig_manifest.tsv in `/mnt/data/intron_prospector_runs/"$TS"/`

```bash
cat _manifest.tsv | cut -f1,3 > sig_manifest.tsv
```

2. compare two conditions. This will require splicedice source code because signature.py is not exposed in the splcieDICE build. Make sure to use commit SHA=`da045c486e314e6f7db253998d886a163172295b`.
```bash
docker run --rm \
    -v /mnt/Repos/splicedice:/opt/splicedice/ \
    -v /mnt/data/intron_prospector_runs/2026-02-03_23-47-43/:/opt/data/ \
    splicedice-tools:latest \
    python3 /opt/splicedice/scripts/signature.py compare \
        -p /opt/data/_allPS.tsv \
        -m /opt/data/sig_manifest.tsv \
        -o /opt/data/
```

See /mnt/data/intron_prospector_runs/2026-02-03_23-47-43
