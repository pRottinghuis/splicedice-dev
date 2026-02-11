# Compare the intron calls of IntronProspector using --junc-bed6 and SpliceDICE's bam_to_junc_bed output.

Move the SD output files into the same directory as the intronProspector output for easier comparison.

Pull bedtools container
```bash
docker pull staphb/bedtools:latest
```

Spin up contianer and mount the output dir with IP and SD output files.
```bash
docker run --it --rm \
    -v /mnt/data//output:/opt/data/ \
    staphb/bedtools:latest /bin/bash
```

Use bedtools to find identical introns

-s: same strand only
-f 1.0: require 100% overlap of the intron coordinates
-r: require reciprocal overlap (both A in B and B in A)
-wa -wb: write the original A and B entries for each overlap

```bash
bedtools intersect \
  -a IP_0a26152a_wt_juncs.bed \
  -b SD_0a26152a_wt_juncs.bed \
  -s -f 1.0 -r -wa -wb > IP_SD_0a26152a_wt_juncs_overlap.bed

bedtools intersect \
  -a IP_0ebf5cc5_mut_juncs.bed \
  -b SD_0ebf5cc5_mut_juncs.bed \
  -s -f 1.0 -r -wa -wb > IP_SD_0ebf5cc5_mut_juncs_overlap.bed
```

Count lines using wordcount

See /mnt/data/intron_prospector_runs/2026-02-11_18-48-05.