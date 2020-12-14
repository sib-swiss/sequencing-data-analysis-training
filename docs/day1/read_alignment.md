## Material

[:fontawesome-solid-file-pdf: Download the presentation](../assets/pdf/read_alignment.pdf){: .md-button }

* Unix command line [E-utilities documentation](https://www.ncbi.nlm.nih.gov/books/NBK179288/)
* `bowtie2` [manual](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#command-line)

## Exercises



### 1. Prepare the reference sequence

>:fontawesome-regular-clock: 10 minutes

Retrieve the reference sequence using `esearch` and `efetch`:

```sh
REFERENCE_DIR=~/workdir/ref_genome/

mkdir $REFERENCE_DIR
cd $REFERENCE_DIR

esearch -db nuccore -query 'U00096' \
| efetch -format fasta > ecoli-strK12-MG1655.fasta
```

**Exercise:** Check out the [documentation of `bowtie2-build`](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#the-bowtie2-build-indexer), and build a index for bowtie2 using default options.

??? done "Answer"
    ```sh
    bowtie2-build ecoli-strK12-MG1655.fasta ecoli-strK12-MG1655.fasta
    ```

### 2. Align the reads with bowtie2

>:fontawesome-regular-clock: 20 minutes

**Exercise:** Check out the bowtie2 manual [here](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#command-line). We are going to align the sequences in paired-end mode. What are the options we'll minimally need?

??? done "Answer"
    According to the usage of `bowtie2`:
    ```sh
    bowtie2 [options]* -x <bt2-idx> {-1 <m1> -2 <m2> | -U <r> | --interleaved <i> | --sra-acc <acc> | b <bam>}
    ```

    We'll need the options:

    * `-x` to point to our index
    * `-1` and `-2` to point to our forward and reverse reads

**Exercise:** Try to understand what the script below does, and run it.

```sh
##!/usr/bin/env bash

TRIMMED_DIR=~/workdir/trimmed_data
REFERENCE_DIR=~/workdir/ref_genome/
ALIGNED_DIR=~/workdir/alignment_output

mkdir $ALIGNED_DIR

bowtie2 \
-x $REFERENCE_DIR/workdir-strK12-MG1655.fasta \
-1 $TRIMMED_DIR/paired_trimmed_SRR519926_1.fastq \
-2 $TRIMMED_DIR/paired_trimmed_SRR519926_2.fastq \
> $ALIGNED_DIR/SRR519926.sam
```

We'll go deeper into alignment statistics tomorrow, but `bowtie2` writes already some statistics to stdout. General alignment rates seem okay, but there are quite some non-concordant alignments. That doesn't sound good. Check out the explanation about concordance at the [bowtie2 manual](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#concordant-pairs-match-pair-expectations-discordant-pairs-dont). Can you guess what the reason could be?
