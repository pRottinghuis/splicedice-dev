# Compare Old Quant with Minimum Quant Refactor

Use https://github.com/pRottinghuis/splicedice/tree/feat/quant-bed6-input feature in spliceDICE fork.
Compare to SpliceDICE sha=da045c486e314e6f7db253998d886a163172295b

Dockerfile https://github.com/pRottinghuis/splicedice-dev/blob/develop/Dockerfile

## Build Docker Images for Each spliceDICE version

Build existing SD image with the old quant code:
``` Bash
docker build -t splicedice-dev:1.0.0 .
```

Update the Dockerfile to build the new SD image with the minimum quant refactor code:

This is the existing Dockerfile
``` Bash
ARG SHA=da045c486e314e6f7db253998d886a163172295b

RUN git init splicedice \
&& cd splicedice \
&& git remote add origin https://github.com/BrooksLabUCSC/splicedice.git \
&& git fetch --depth 1 origin "$SHA" \
&& git checkout FETCH_HEAD \
&& pip install --no-cache-dir pysam==0.23.3 . \
&& cd /opt \
&& rm -rf splicedice
```

Updated lines for SHA and remote repository to my fork.
```Bash
ARG SHA=a9747926c96e81531000143a7e3016c7917916b8

RUN git init splicedice \
&& cd splicedice \
&& git remote add origin https://github.com/pRottinghuis/splicedice.git \
&& git fetch --depth 1 origin "$SHA" \
&& git checkout FETCH_HEAD \
&& pip install --no-cache-dir pysam==0.23.3 . \
&& cd /opt \
&& rm -rf splicedice
```

Build updated SD image with the quant refactor:
``` Bash
docker build -t splicedice-dev:1.1.0 .
```

## Generate BED file with IP
Generate a junction bed file to use as input for the quant check. Can use either docker image because both build with the same IP version.
```Bash
docker run --rm -v /mnt/data/tcga/0a26152a-462f-4895-8fe8-15fcdcc56e16/7a7440bf-1ca1-4c6b-80f8-7151a38e5d18.rna_seq.genomic.gdc_realn.bam:/opt/data/input.bam \
-v /mnt/data/ref/GRCh38.primary_assembly.genome.fa:/opt/data/ref.fa \
-v /mnt/data/ref/GRCh38.primary_assembly.genome.fa.fai:/opt/data/ref.fa.fai \
-v ~/work/:/opt/output/ \
splicedice-dev:1.0.0 \
intronProspector -S --genome-fasta=/opt/data/ref.fa --intron-bed6=/opt/output/IP_0a26152a_wt_juncs.bed /opt/data/input.bam
```

Bed to use for proceeding steps will be in ~/work/

## Generate a manifest file for the quant check
Paths are relative to the container
`~/work/manifest.tsv`:
```tsv
TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16	/opt/data/IP_0a26152a_wt_juncs.bed	u2af1-wt	u2af1-wt
```

## Run Old Quant Code
Check that the old quant is built in the image. --help should show all the old options.
```Bash
docker run -it --rm splicedice-dev:1.0.0 /bin/bash
splicedice quant -h
```
Expected output should show the old quant options:
```
usage: splicedice quant [-h] --manifest MANIFEST --output_prefix OUTPUT_PREFIX [--maxLength MAXLENGTH] [--minLength MINLENGTH] [--minOverhang MINOVERHANG] [--drim] [--noMultimap] [--filter {gtag_only}] [--minUnique MINUNIQUE] [--lowCoverageNan] [--minEntropy MINENTROPY]

optional arguments:
  -h, --help            show this help message and exit
  --manifest MANIFEST, -m MANIFEST
                        tab-separated list of samples with file paths
  --output_prefix OUTPUT_PREFIX, -o OUTPUT_PREFIX
                        prefix for output filenames
  --maxLength MAXLENGTH
                        maximum splice junction size
  --minLength MINLENGTH
                        minimum splice junction size
  --minOverhang MINOVERHANG
                        minimum overlap on reads to support splice junction
  --drim                create table for use by DRIMSeq
  --noMultimap          use only reads that uniquely map to one location
  --filter {gtag_only}  donor and acceptor intron sequences to include.
  --minUnique MINUNIQUE
                        minimum number of unique reads to support splice junction
  --lowCoverageNan      Report NaN for splicing events with coverage below minUnique
  --minEntropy MINENTROPY
                        Shannon's diversity index associated with a junction, minumum required for inclusion [Default 1]
```

```bash
exit
```

Make a output directory for the quant results comparison:
```Bash
mkdir ~/work/old_quant
```

We will run quant and zero out all filters. This will prevent quant from calling any junctions which is the behavior we want in the quant refactor.
```Bash
docker run --rm \
-v ~/work/:/opt/ \
splicedice-dev:1.0.0 \
splicedice quant -m /opt/manifest.tsv -o /opt/old_quant/ --maxLength 5000000000 --minLength 0 --minOverhang 0 --minUnique 0 --minEntropy 0
```

Outputs will be in ~/work/old_quant/

## Run New Quant Refactor Code

Check that the new quant refactor is built in the image. --help should show all the new options.
```Bash
docker run -it --rm splicedice-dev:1.1.0 /bin/bash
splicedice quant -h
```

Expected output should show the new quant refactor which has less options:
```
usage: splicedice quant [-h] --manifest MANIFEST --output_prefix OUTPUT_PREFIX [--drim]

optional arguments:
  -h, --help            show this help message and exit
  --manifest MANIFEST, -m MANIFEST
                        tab-separated list of samples with file paths
  --output_prefix OUTPUT_PREFIX, -o OUTPUT_PREFIX
                        prefix for output filenames
  --drim                create table for use by DRIMSeq
```

```bash
exit
```

Make a output directory for the quant results comparison:
```Bash
mkdir ~/work/new_quant
```
Run quant with the new refactor.
```Bash
docker run --rm \
-v ~/work/:/opt/ \
splicedice-dev:1.1.0 \
splicedice quant -m /opt/manifest.tsv -o /opt/new_quant/
```

## Compare outputs
If the refactor didn't change any behavior outside of the filters, then the outputs should be identical.
```Bash
for f in _allClusters.tsv _allPS.tsv _inclusionCounts.tsv _junctions.bed; do
  diff ~/work/old_quant/$f ~/work/new_quant/$f
done
```

Since there is no output the files are all identical and the refactor is not changing any behavior.

Find ~/work/ archive in /mnt/data/splicedice-dev/2026-03-04_08-14-00