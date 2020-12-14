## Material

* `samtools` [documentation](http://www.htslib.org/doc/samtools.html)

## Exercises

### 1. Alignment statistics

>:fontawesome-regular-clock: 10 minutes

**Exercise:** Check out the statistics of the E. coli alignment by using `samtools flagstat`. Find the documentation [here](http://www.htslib.org/doc/samtools-flagstat.html). Anything that draws your attention?

??? done "Answer"
    Code:
    ```sh
    cd ~/workdir/alignment_output/
    samtools flagstat SRR519926.sam
    ```

    resulting in:

    ```
    529562 + 0 in total (QC-passed reads + QC-failed reads)
    0 + 0 secondary
    0 + 0 supplementary
    0 + 0 duplicates
    526159 + 0 mapped (99.36% : N/A)
    529562 + 0 paired in sequencing
    264781 + 0 read1
    264781 + 0 read2
    203576 + 0 properly paired (38.44% : N/A)
    523484 + 0 with itself and mate mapped
    2675 + 0 singletons (0.51% : N/A)
    0 + 0 with mate mapped to a different chr
    0 + 0 with mate mapped to a different chr (mapQ>=5)
    ```

    Of the reads, 38.44% is properly paired. The rest isn't. Proper pairing is quite hard to interpret. It usually means that the 0x2 flag (each segment properly aligned according to the aligner) is false. In this case it means that the insert size is high for a lot of sequences. That is because the insert size distribution is very wide. You can find info on insert size distribution like this:

    ```
    samtools stats SRR519926.sam | grep ^SN | cut -f 2,3
    ```

    Now look at `insert size average` and `insert size standard deviation`. You can see the standard deviation is higher than the average, suggesting a wide distribution.

### 2. Compression, sorting and indexing

>:fontawesome-regular-clock: 20 minutes

The command `samtools view` is very versatile. It takes an alignment file and writes a filtered or processed alignment to the output. You can for example use it to compress your SAM file into a BAM file. Let's start with that.

**Exercise**: compress our SAM file into a BAM file and include the header in the output. For this, use the `-b` and `-h` options. Find the required documentation [here](http://www.htslib.org/doc/samtools-view.html). How much was the disk space reduced by compressing the file?

!!! tip "Tip: Samtools writes to stdout"
    By default, samtools writes it's output to stdout. This means that you need to redirect your output to a file with `>` or use the the output option `-o`.

??? done "Answer"
    ```sh
    samtools view -bh SRR519926.sam > SRR519926.bam
    ```
    By using `ls -lh`, you can find out that `SRR519926.sam` has a size of 223 Mb, while `SRR519926.bam` is only 67 Mb.  

To look up specific alignments, it is convenient to have your alignment file indexed. An indexing can be compared to a kind of 'phonebook' of your sequence alignment file. Indexing can be done with `samtools` as well, but it first needs to be sorted on coordinate (i.e. the alignment location). You can do it like this:

```sh
samtools sort SRR519926.bam > SRR519926.sorted.bam
samtools index SRR519926.sorted.bam
```

### 3. Filtering

>:fontawesome-regular-clock: 30 minutes

With `samtools view` you can easily filter your alignment file based on flags. One thing that might be sensible to do at some point is to filter out unmapped reads.

**Exercise:** Check out the flag that you would need to filter for mapped reads. It's at page 7 of the [SAM documentation](https://samtools.github.io/hts-specs/SAMv1.pdf).

??? Done "Answer"
    You will need the 0x4 flag.

Filtering against unmapped reads (leaving only mapped reads) with `samtools view` would look like this:

```sh
samtools view -bh -F 0x4 SRR519926.sorted.bam > SRR519926.sorted.mapped.bam
```

or:

```sh
samtools view -bh -F 4 SRR519926.sorted.bam > SRR519926.sorted.mapped.bam
```

**Exercise:** Write a command that outputs only the unmapped reads (so the opposite of the example). How many reads are in there? Is that the same as what we expect based on the output of `samtools flagstat`?

!!! tip "Tip"
    Check out the `-f` and `-c` options of `samtools view`

??? Done "Answer"
    Filter like this:
    ```sh
    samtools view -bh -f 0x4 SRR519926.sorted.bam > SRR519926.sorted.unmapped.bam
    ```

    Counting like this:
    ```sh
    samtools view -c SRR519926.sorted.unmapped.bam
    ```
    This should correspond to the output of `samtools flagstat` (529562 - 526159 = 3403)

`samtools view` also enables you to filter alignments in a specific region. This can be convenient if you don't want to work with huge alignment files and if you're only interested in alignments in a particular region. Region filtering only works for sorted and indexed alignment files.

**Exercise:** Filter our sorted and indexed BAM file for the region between 2000 and 2500 kb, and output it as a BAM file with a header.

!!! tip "Tip: Specifying a region"
    Our E. coli genome has only one chromosome, because only one line starts with `>` in the fasta file

    ```sh
    cd ~/workdir/ref_genome
    grep ">" ecoli-strK12-MG1655.fasta
    ```

    gives:

    ```
    >U00096.3 Escherichia coli str. K-12 substr. MG1655, complete genome
    ```

    The part after the first space in the title is cut off for the alignment reference. So the code for specifying a region would be: `U00096.3:START-END`

??? done "Answer"
    ```
    cd ~/workdir/alignment_output
    samtools view -bh SRR519926.sorted.bam U00096.3:2000000-2500000 > SRR519926.sorted.region.bam
    ```

### 4. Redirection

>:fontawesome-regular-clock: 20 minutes

Samtools is easy to use in a pipe. In this case you can replace the input file with a `-`. For example, you can sort and compress the output of your alignment software in a pipe like this:

```sh
my_alignment_command \
| samtools sort - \
| samtools view -bh - \
> alignment.bam
```

!!! note "The use of `-`"
    In the modern versions of samtools, the use of `-` is not needed for most cases, so without an input file it reads from stdin. However, if you're not sure, it's better to be safe than sorry.

**Exercise:** Write a script that maps the reads with bowtie2 (see chapter 2 of [read alignment](../day1/read_alignment.md)), sorts them, takes only the mapped reads, and outputs them as a BAM file with a header.

??? done "Answer"
    ```
    ##!/usr/bin/env bash

    TRIMMED_DIR=~/workdir/trimmed_data
    REFERENCE_DIR=~/workdir/ref_genome
    ALIGNED_DIR=~/workdir/alignment_output

    bowtie2 \
    -x $REFERENCE_DIR/ecoli-strK12-MG1655.fasta \
    -1 $TRIMMED_DIR/paired_trimmed_SRR519926_1.fastq \
    -2 $TRIMMED_DIR/paired_trimmed_SRR519926_2.fastq \
    | samtools sort - \
    | samtools view -F 0x4 -bh - \
    > $ALIGNED_DIR/SRR519926.sorted.mapped.frompipe.bam
    ```
