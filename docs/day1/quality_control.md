## Material

[:fontawesome-solid-file-pdf: Download the presentation](../assets/pdf/quality_control.pdf){: .md-button }

* `fastqc` command line [documentation](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/INSTALL.txt)
* `trimmomatic` [manual](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf)
* Unix command line [E-utilities documentation](https://www.ncbi.nlm.nih.gov/books/NBK179288/)

## Exercises

### 1. Download and evaluate an E. coli dataset

>:fontawesome-regular-clock: 30 minutes

**Exercise:** Create a directory called `workdir` in your home directory and make the directory your current directory.

!!! note "If working with Docker"
    If you have mounted your local directory to `/root/workdir`, this directory should already exist.

??? done "Answer"
    ```sh
    cd ~
    mkdir workdir
    cd workdir
    ```

Check out the dataset at [SRA](https://www.ncbi.nlm.nih.gov/sra/?term=SRR519926).

**Exercise:** Browse around the SRA entry and answer these questions:

**A.** Is the dataset paired-end or single end?

**B.** Which instrument was used for sequencing?

**C.** What is the read length?

**D.** How many reads do we have?

??? done "Answers"
    A. paired-end

    B. Illumina MiSeq

    C. 2 x 252 bp

    D. 400596

Make a directory `reads` in `~/workdir` and download the reads from the SRA database using `prefetch` and `fastq-dump` from [SRA-Tools](https://ncbi.github.io/sra-tools/) into the `reads` directory:

```sh
mkdir reads
cd reads
prefetch SRR519926
fastq-dump --split-files SRR519926
```

**Exercise:** Check whether the download was successful by counting the number of reads in the fastq files and compare it to the SRA entry.

!!! tip "Tip"
    A read in a fastq file consists of four lines (more on that at [file types](../day2/file_types.md)). Use Google to figure out how to count the number of reads in a fastq file.

??? done "Answer"
    e.g. from [this](https://www.biostars.org/p/139006/) thread on Biostars:

    ```sh
    ## forward read
    echo $(cat SRR519926_1.fastq | wc -l)/4 | bc

    ## reverse read
    echo $(cat SRR519926_2.fastq | wc -l)/4 | bc
    ```

### 2. Run fastqc

>:fontawesome-regular-clock: 20 minutes

**Exercise:** Run fastqc on the fastq files.

!!! tip "Tip"
    `fastqc` accepts multiple files as input, so you can use a [wildcard](https://en.wikipedia.org/wiki/Glob_(programming)) to run `fastqc` on all the files in one line of code. Use it like this: `*.fastq`.  

??? done "Answer"
    ```sh
    fastqc *.fastq
    ```

**Exercise:** Download the html files to your local computer, and view the results. How is the quality? Where are the problems?

??? done "Answer"
    There seems to be:

    * Low quality towards the 3' end (per base sequence quality)
    * Full sequence reads with low quality (per sequence quality scores)
    * Adapters in the sequences (adapter content)

    We can probably fix most of these issues by trimming.

### 3. Trim the reads

>:fontawesome-regular-clock: 20 minutes

We will use [trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) for trimming low quality and spurious bases from our reads. For paired-end data it generates four different trimmed `fastq` files. If one of the paired-end reads doesn't meet the quality thresholds, it will be discarded, but the other read might be kept. Therefore, trimmomatic outputs contains files with unpaired reads as well. Usually those files are very small compared to the paired reads, and are often ignored for downstream analyses.

Trimmomatic syntax is rather complicated and different from most tools. Refer to the [manual](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf) if you want to go deeper into this.

**Exercise:** The script below will trim the sequence reads in a sensible manner. Execute the script to trim the data (note that the script is slightly different if you're working in the docker container):

=== "AWS"

    ```sh
    ##!/usr/bin/env bash

    TRIMMED_DIR=~/workdir/trimmed_data
    READS_DIR=~/workdir/reads
    ADAPTERS=/opt/miniconda3/pkgs/trimmomatic-0.39-1/share/trimmomatic/adapters/TruSeq3-PE.fa

    mkdir $TRIMMED_DIR

    trimmomatic \
    PE \
    -threads 1 \
    -phred33 \
    $READS_DIR/SRR519926_1.fastq \
    $READS_DIR/SRR519926_2.fastq \
    $TRIMMED_DIR/paired_trimmed_SRR519926_1.fastq \
    $TRIMMED_DIR/unpaired_trimmed_SRR519926_1.fastq \
    $TRIMMED_DIR/paired_trimmed_SRR519926_2.fastq \
    $TRIMMED_DIR/unpaired_trimmed_SRR519926_2.fastq \
    ILLUMINACLIP:$ADAPTERS:2:30:10 \
    SLIDINGWINDOW:4:5 \
    LEADING:5 \
    TRAILING:5 \
    MINLEN:25
    ```

=== "Docker"

    ```sh
    ##!/usr/bin/env bash

    TRIMMED_DIR=~/workdir/trimmed_data
    READS_DIR=~/workdir/reads
    ADAPTERS=/opt/conda/pkgs/trimmomatic-0.39-1/share/trimmomatic/adapters/TruSeq3-PE.fa

    mkdir $TRIMMED_DIR

    trimmomatic \
    PE \
    -threads 1 \
    -phred33 \
    $READS_DIR/SRR519926_1.fastq \
    $READS_DIR/SRR519926_2.fastq \
    $TRIMMED_DIR/paired_trimmed_SRR519926_1.fastq \
    $TRIMMED_DIR/unpaired_trimmed_SRR519926_1.fastq \
    $TRIMMED_DIR/paired_trimmed_SRR519926_2.fastq \
    $TRIMMED_DIR/unpaired_trimmed_SRR519926_2.fastq \
    ILLUMINACLIP:$ADAPTERS:2:30:10 \
    SLIDINGWINDOW:4:5 \
    LEADING:5 \
    TRAILING:5 \
    MINLEN:25
    ```

!!! note "The use of `\`"
    In the script above you see that we're using `\` at the end of many lines. We use it to tell bash to ignore the newlines. If we would not do it, the `trimmomatic` command would become a very long line, and the script would become very difficult to read. It is in general good practice to put every option of a long command on a newline in your script and use `\` to ignore the newlines when executing.

**Exercise:** Run `fastqc` on the trimmed fastq files and answer these questions:

**A.** Has the quality improved?

**B.** How many reads do we have left?

**C.** There are more unpaired forward reads compared to reverse reads. Does this make sense?

??? done "Answers"
    Running `fastqc`:
    ```
    cd ~/workdir/trimmed_data
    fastqc paired_trimmed*.fastq
    ```

    A. Yes, low quality 3' end, per sequence quality and adapter sequences have improved.

    B. 264781

    C. Again, [Google to the rescue](https://www.biostars.org/p/325174/#325193)
