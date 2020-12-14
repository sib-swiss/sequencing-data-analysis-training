
The last part of this course will consist of project-based-learning. This means that you will work in groups on a single question. We will split up into groups of five people.

!!! note "If working with Docker"
    If you are working with Docker, I assume you are working independently and therefore can not work in a group. However, you can test your skills with these real biological datasets. Realize that the datasets and calculations are (much) bigger compared to the exercises, so check if your computer is up for it. You'll probably need around 4 cores, 16G of RAM and 50G of harddisk. 

!!! note "If online"
    If the course takes place online, we will use break-out rooms to communicate within groups. Please stay in the break-out room during the day, also if you are working individually.

## Roles & organisation

Project based learning is about learning by doing, but also about *peer instruction*. This means that you will be both a learner and a teacher. There will be differences in levels among participants, but because of that, some will learn efficiently from people that have just learned, and others will teach and increase their understanding.

Each project has **tasks** and **questions**. By performing the tasks, you should be able to answer the questions. At the start of the project, make sure that each of you gets a task assigned. You should consider the tasks and questions as a guidance. If interesting questions pop up during the project, you are **encouraged** to work on those. Also, you don't have to perform all the tasks and answer all the questions.

In the afternoon of day 2, you will divide the initial tasks, and start on the project. On day 3, you can work on the project in the morning and in the first part of the afternoon. We will conclude the projects with a **10-minute presentation** of each group.

## :fontawesome-solid-disease: Project 1: Short-read RNA-seq of mice.

**Aim:** Compare `hisat2` (splice-aware) with `bwa mem` (splice unaware) while aligning a mouse RNA-seq dataset.

In this project you will be working with data from:

Singhania A, Graham CM, Gabryšová L, Moreira-Teixeira L, Stavropoulos E, Pitt JM, et al (2019). *Transcriptional profiling unveils type I and II interferon networks in blood and tissues across diseases*. Nat Commun. 10:1–21. [https://doi.org/10.1038/s41467-019-10601-6](https://doi.org/10.1038/s41467-019-10601-6)

Here's the [BioProject page](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA490485).

Download the mouse reference genome like this:

```sh
ftp://ftp.ensembl.org/pub/release-101/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz
```

### Tasks:

* Check out the BioProject, and download two samples that interest you.
* Do a QC on the data with `fastqc`
* Check which options to use, and run `bwa-mem`
* Check which options to use, and run `hisat2`
* Evaluate the alignment quality (e.g. alignment rates, mapping quality)
* Compare the bam files of the two aligners in IGV
* Compare different samples in read quality, alignment rates, depth, etc.
* Run `featurecounts` on both alignments
* Compare the count matrices in `R` or `python`

### Questions:

* What are the alignment rates?
* How do the aligners handle splicing?
* How are spliced alignments stored in the SAM file?
* Do you see differences in soft clipping?
* What would be the effect of the aligner if you would be measuring gene expression? (To investigate this you'll need to run e.g. [featureCounts](http://bioinf.wehi.edu.au/featureCounts/)).

!!! hint "Downloading from SRA"
    ```sh
    prefetch [SRR number]
    fastq-dump --split-files --gzip [SRR number]
    ```

!!! hint "Example code hisat2"
    Everything in between `<>` should be replaced with specific arguments

    ```sh
    hisat2-build <reference_sequence_fasta> <index_basename>

    hisat2 \
    -x <index_basename> \
    -1 <foward_reads.fastq.gz> \
    -2 <reverse_reads.fastq.gz> \
    -p <threads> \
    | samtools sort \
    | samtools view -bh \
    > <alignment_file.bam>
    ```

!!! hint "Example code `bwa mem`"
    ```
    bwa index <reference_sequence_fasta>

    bwa mem \
    <index_basename> \
    <forward_reads.fastq.gz> \
    <reverse_reads.fastq.gz> \
    | samtools sort \
    | samtools view -bh \
    > <alignment_file.bam>
    ```

!!! hint "More resources"
    Need e.g. a gtf file? Here's the [ensembl page](http://www.ensembl.org/Mus_musculus/Info/Index)

!!! hint "Spliced alignments"
    Have a look at IGV on a particular gene, e.g. Nbr1

## :fontawesome-solid-seedling: Project 2: Short-read RNA-seq data of *Arabidopsis thaliana* grown in space

**Aim:** Compare `hisat2` (splice-aware) with `bowtie2` (splice unaware) while aligning an Arabidopsis RNA-seq dataset.

The analysis of this dataset is reported in this paper:

Vandenbrink JP, Herranz R, Poehlman WL, Alex Feltus F, Villacampa A, Ciska M, et al. (2019) *RNA-seq analyses of Arabidopsis thaliana seedlings after exposure to blue-light phototropic stimuli in microgravity *. Am J Bot. 106:1466–76.

Reads can be found on the NASA repository [here](https://genelab-data.ndc.nasa.gov/genelab/accession/GLDS-251/). You can download data with `wget`. Here is an example for downloading the forward and reverse reads for sample 131:

```sh
wget -O sample_131_R1.fastq.gz \
https://genelab-data.ndc.nasa.gov/genelab/static/media/dataset/GLDS-251_rna-seq_13JUN2017HiSeq_Run_Sample_131_UMISS_Hoeksema_ACAGTG_L001_R1_001.fastq.gz?version=1

wget -O sample_131_R2.fastq.gz \
https://genelab-data.ndc.nasa.gov/genelab/static/media/dataset/GLDS-251_rna-seq_13JUN2017HiSeq_Run_Sample_131_UMISS_Hoeksema_ACAGTG_L001_R2_001.fastq.gz?version=1

```

!!! note "Use of `-O`"
    The name of the file is very long we use the option `-O` here to give it a shorter name.

Download the reference genome sequence like this:

```sh
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-48/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
```

### Tasks:

* Check out the BioProject, and download two samples that interest you.
* Do a QC on the data with `fastqc`
* Check which options to use, and run `bwa-mem`
* Check which options to use, and run `hisat2`
* Evaluate the alignment quality (e.g. alignment rates, mapping quality)
* Compare the bam files of the two aligners in IGV
* Compare different samples in read quality, alignment rates, depth, etc.
* Run `featurecounts` on both alignments
* Compare the count matrices in `R` or `python`

### Questions:

* What are the alignment rates?
* How do the aligners handle splicing?
* How are spliced alignments stored in the SAM file?
* Do you see differences in soft clipping?
* What would be the effect of the aligner if you would be measuring gene expression? (To investigate this you'll need to run e.g. [featureCounts](http://bioinf.wehi.edu.au/featureCounts/)).

!!! hint "Example code hisat2"
    Everything in between `<>` should be replaced with specific arguments

    ```sh
    hisat2-build <reference_sequence_fasta> <index_basename>

    hisat2 \
    -x <index_basename> \
    -1 <mate1.fastq.gz> \
    -2 <mate2.fastq.gz> \
    -p <threads> \
    | samtools sort \
    | samtools view -bh \
    > <alignment_file.bam>
    ```

!!! hint "More resources"
    Need e.g. a gtf file? Here's the [ensembl page](https://plants.ensembl.org/Arabidopsis_thaliana/Info/Index)


## :fontawesome-solid-brain: Project 3: Long-read genome sequencing

**Aim**: Align long reads from RNA-seq data to a reference genome.

In this project, you will be working with data from:

Clark, M. B. et al (2020). *Long-read sequencing reveals the complex splicing profile of the psychiatric risk gene CACNA1C in human brain*. Molecular Psychiatry, 25(1), 37–47. [https://doi.org/10.1038/s41380-019-0583-1](https://doi.org/10.1038/s41380-019-0583-1).

Here you can find the [BioProject page](https://www.ncbi.nlm.nih.gov/bioproject/PRJEB34660).

It is Oxford Nanopore Technology sequencing data of amplicons of the gene CACNA1C. It is primarily used to discover new splice variants. In this project, we will align a few of the samples to the reference genome, and assess the quality of reads and the alignment.

Download the human reference genome like this:

```sh
wget ftp://ftp.ensembl.org/pub/release-101/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
```

### Tasks:

* Check out the BioProject, and download two samples that interest you.
* Perform QC with `fastqc`
* Perform QC with `NanoPlot`
* Align with `minimap2` with default parameters
* Figure how you should set parameters `-x` and `-G`
* Evaluate the alignment quality (e.g. alignment rates, mapping quality)
* Compare different samples in read quality, alignment rates, depth, etc.
* **Bonus** see if you can identify different splice variants using [FLAIR](https://github.com/BrooksLabUCSC/flair) (see hints below).

### Questions:

* Have a look at the quality report. What are the average read lengths? Is that expected?
* What is the average read quality? What kind of accuracy would you expect?
* Note any differences between `fastqc` and `NanoPlot`? How is that compared to the publication?
* Check out the options `-x` and `-G` of `minimap2`. Are the defaults appropriate?
* You might consider using `-x map-ont` or `-x splice`. Do you see differences in the alignment in e.g. IGV?
* How are spliced alignments stored in the SAM file with the different settings of `-x`?
* How deep is the gene sequenced?

!!! hint "Downloading from SRA"
    ```sh
    prefetch [SRR number]
    fastq-dump --gzip [SRR number]
    ```

!!! hint "Accuracy from quality scores"
    Find the equation to calculate error probability from quality score on [Wikipedia](https://en.wikipedia.org/wiki/Phred_quality_score).

!!! hint "Comparing `fastqc` and `Nanoplot`"
    For comparing `fastqc` and `NanoPlot`, check out this [blog](https://gigabaseorgigabyte.wordpress.com/2017/06/26/averaging-basecall-quality-scores-the-right-way/) of the author of NanoPlot, and this [thread](https://github.com/wdecoster/NanoPlot/issues/191).

!!! hint "Running `minimap2`"
    Here's an example command for `minimap2`:

    ```sh
    minimap2 \
    -a \
    -x [PARAMETER] \
    -G [PARAMETER] \
    [REFERENCE].fa \
    [FASTQFILE].fastq.gz \
    | samtools sort \
    | samtools view -bh > [OUTPUT].bam
    ```

!!! hint "Intron sizes"
    Check out the the intron sizes of CACNA1C in e.g. IGV or UCSC genome browser. How does that relate to the parameter `-G`?

!!! hint "More resources"
    Need e.g. a gtf file? Here's the [ensembl page](https://www.ensembl.org/Homo_sapiens/Info/Index)

!!! hint "Running FLAIR"
    FLAIR is a set of python scripts that can be used to identify and quantify (new) isoforms based on alignment files of long-read sequencing data. You can basically follow the pipeline as described [here](https://github.com/BrooksLabUCSC/flair).

    To use FLAIR first clone the git repository, and activate the (pre-configured) conda environment:

    ```sh
    cd
    git clone https://github.com/BrooksLabUCSC/flair.git
    ```

    After that, generate a FLAIR working directory and convert your `.bam` alignment file to `bed12` format.

    ```sh
    mkdir ~/flair_output

    python3 ~/flair/bin/bam2Bed12.py \
    -i alignment.bam \
    > alignment.bed12
    ```

    Generate (and run) a shell script to run the modules `flair.py correct`, `flair.py collapse` and `flair.py quantify`. To do this, carefully follow the manual at https://github.com/BrooksLabUCSC/flair. Structure and document your script(s), so you can easily re-run the analysis.

    Files you will need are:

    * Reference genome (chromosome 12 only): `/data/references/GRCh38.p13.chr12.fa`
    * GTF: `/data/references/Homo_sapiens.GRCh38.100.gtf`
    * Reads manifest: `/data/reads/lrrnaseq/batch_combined/reads_manifest.tsv`
