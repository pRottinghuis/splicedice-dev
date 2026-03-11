# Compare Old Quant with Minimum Quant Refactor (Toy Data)

This example performs the same validation as the notebook `2026-03-03_test_new_old_quant.md` but uses a toy dataset

Use https://github.com/pRottinghuis/splicedice/tree/feat/quant-bed6-input feature in spliceDICE fork.
Compare to SpliceDICE sha=da045c486e314e6f7db253998d886a163172295b

Dockerfile https://github.com/pRottinghuis/splicedice-dev/blob/develop/Dockerfile

## Set Up Toy Data

Reuses the single exon skip event toy data from the SD repo. See: https://github.com/pRottinghuis/splicedice/tree/feat/quant-bed6-input/data/example_data/exon_skip#readme

In a working directory for this validation, create the following files:

`data/cntrl.bed`:
```
chr1    500 600 sj  120 +
```

`data/ps_0.bed`:
```
chr1	1000	1300	sj3	20	+
```

`data/ps_100.bed`:
```
chr1	1000	1100	sj1	20	+
chr1	1200	1300	sj2	20	+
```

`data/ps_50.bed`:
```
chr1	1000	1100	sj1	10	+
chr1	1200	1300	sj2	10	+
chr1	1000	1300	sj3	10	+
```

The manifest paths will be relative to the inside of the container.
`manifest`:
```tsv
ps_0	/opt/data/ps_0.bed	.	control
ps_50	/opt/data/ps_50.bed	.	mutant
ps_100	/opt/data/ps_100.bed	.	mutant
cntrl	/opt/data/cntrl.bed	.	control
```

## Build Docker Images for Each spliceDICE version

Build new SD quant image with the quant refactor:
``` Bash
docker build -t splicedice-dev:1.1.0 .
```

Change the Dockerfile by hand to build the old quant SD code:

This is how the splicedice section of the dockerfile should look to build old quant code:
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

Using the adjustment above, build the old SD quant image:
``` Bash
docker build -t splicedice-dev:1.0.0 .
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
splicedice quant -m /opt/manifest.tsv -o /opt/old_quant/ --maxLength 5000000000 --minLength 0 --minOverhang 0 --minUnique 0 --minEntropy 0 --drim
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
splicedice quant -m /opt/manifest.tsv -o /opt/new_quant/ --drim
```

## Compare outputs
If the refactor didn't change any behavior outside of the filters, then the outputs should be identical.
```Bash
for f in _allClusters.tsv _allPS.tsv _inclusionCounts.tsv _junctions.bed; do
  diff ~/work/old_quant/$f ~/work/new_quant/$f
done
```

Since there is no output the files are all identical and the refactor is not changing any behavior.

Find ~/work/ archive in /mnt/data/splicedice-dev/2026-03-11_07-03-56