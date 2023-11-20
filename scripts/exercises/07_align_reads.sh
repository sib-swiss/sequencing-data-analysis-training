#!/usr/bin/env bash

TRIMMED_DIR=~/project/results/trimmed
REFERENCE_DIR=~/project/ref_genome/
ALIGNED_DIR=~/project/results/alignments

mkdir -p $ALIGNED_DIR

bowtie2 \
-x $REFERENCE_DIR/ecoli-strK12-MG1655.fasta \
-1 $TRIMMED_DIR/trimmed_SRR519926_1.fastq \
-2 $TRIMMED_DIR/trimmed_SRR519926_2.fastq \
> $ALIGNED_DIR/SRR519926.sam
