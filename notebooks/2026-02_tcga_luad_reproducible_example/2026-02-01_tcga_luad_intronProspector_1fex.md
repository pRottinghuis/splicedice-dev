# Run intronProspector into SpliceDICE on 1 sample

Follow to get the ref genome and annotation setup: https://github.com/pRottinghuis/splicedice-dev/blob/develop/notebooks/setup/ref_genomes.md

# Instructions

1. If not already done, build the SpliceDICE and intronProspector docker image.
```bash
docker build -t splicedice-dev:latest .
```

2. Run the docker container with the appropriate volume mounts.
```bash
docker run -it --rm \
    -v /mnt/data/ref/GRCh38.primary_assembly.genome.fa:/opt/data/ref/GRCh38.primary_assembly.genome.fa \
    -v /mnt/data/tcga/0a26152a-462f-4895-8fe8-15fcdcc56e16/7a7440bf-1ca1-4c6b-80f8-7151a38e5d18.rna_seq.genomic.gdc_realn.bam:/opt/data/tcga/0a26152a-462f-4895-8fe8-15fcdcc56e16/7a7440bf-1ca1-4c6b-80f8-7151a38e5d18.rna_seq.genomic.gdc_realn.bam \
    -v /mnt/data/intron_prospector_runs:/opt/data/intron_prospector_runs \
    splicedice-tools:latest /bin/bash
```



