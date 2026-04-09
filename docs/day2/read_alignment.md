## Learning outcomes

**After having completed this chapter you will be able to:**

- Explain what a sequence aligner does
- Explain why in some cases the aligner needs to be 'splice-aware'
- Calculate mapping quality out of the probability that a mapping position is wrong
- Build an index of the reference and perform an alignment of paired-end reads with `bowtie2`

## Material

<iframe width="560" height="315" src="https://www.youtube.com/embed/552Rv-HrV6Q" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

[:fontawesome-solid-file-pdf: Download the presentation](../assets/pdf/05_read_alignment.pdf){: .md-button }

* Unix command line [E-utilities documentation](https://www.ncbi.nlm.nih.gov/books/NBK179288/)
* `bowtie2` [manual](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#command-line)
* Ben Langmead's [youtube channel](https://www.youtube.com/channel/UCrDmN9uRVJR7KM8aRE_58Zw) for excellent lectures on e.g. BWT, suffix matrixes/trees, and binary search. 

## Exercises

### Prepare the reference sequence

Make a script called `05_download_ecoli_reference.sh`, and paste in the code snippet below. Use it to retrieve the reference sequence using `esearch` and `efetch`:

```sh title="05_download_ecoli_reference.sh"
#!/usr/bin/env bash

REFERENCE_DIR=~/project/ref_genome/

mkdir $REFERENCE_DIR
cd $REFERENCE_DIR

esearch -db nuccore -query 'U00096' \
| efetch -format fasta > ecoli-strK12-MG1655.fasta
```

**Exercise:** Check out the [documentation of `bowtie2-build`](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#the-bowtie2-build-indexer), and build the indexed reference genome with bowtie2 using default options. Do that with a script called `06_build_bowtie_index.sh`.

??? done "Answer"
    ```sh title="06_build_bowtie_index.sh"
    #!/usr/bin/env bash

    cd ~/project/ref_genome

    bowtie2-build ecoli-strK12-MG1655.fasta ecoli-strK12-MG1655.fasta
    ```

### Align the reads with `bowtie2`

**Exercise:** Check out the bowtie2 manual [here](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#command-line). We are going to align the sequences in paired-end mode. What are the options we'll minimally need?

??? done "Answer"
    According to the usage of `bowtie2`:
    ```sh
    bowtie2 [options]* -x <bt2-idx> {-1 <m1> -2 <m2> | -U <r> | --interleaved <i> | --sra-acc <acc> | b <bam>}
    ```

    We'll need the options:

    * `-x` to point to our index
    * `-1` and `-2` to point to our forward and reverse reads

**Exercise:** Try to understand what the script below does. After that copy it to a script called `07_align_reads.sh`, and run it.

```sh title="07_align_reads.sh"
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
```

We'll go deeper into alignment statistics later on, but `bowtie2` writes already some statistics to stdout. General alignment rates seem okay, but there are quite some non-concordant alignments. That doesn't sound good. Check out the explanation about concordance at the [bowtie2 manual](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#concordant-pairs-match-pair-expectations-discordant-pairs-dont). Can you guess what the reason could be?

??? done "Answer"

    In [`Bowtie2`](https://bowtie-bio.sourceforge.net/bowtie2/manual.shtml), a pair of reads is marked as discordant when both mates map uniquely to the reference but fail to meet the "concordant" criteria, which are defined by orientation, distance, and relative position [1, 2]. 
    Based on bioinformatics course materials and community consensus (e.g., [Biostars](https://www.biostars.org/p/78446/), [SeqAnswers](https://www.seqanswers.com/forum/bioinformatics/bioinformatics-aa/17856-bowtie-2-explanation-of-the-pair-end-mode-report)), the following are the primary reasons for high discordance rates in _E. coli_ K-12 MG1655 data:

    ## 1. Insert Size Mismatch
    Bowtie 2 uses a default `maximum fragment length` (`-X`) of `500 bp`. [2,3] 

    * __The Issue:__ If your DNA library was prepared with larger fragments (e.g., `600–800 bp`), `Bowtie2` will mark these as discordant because they exceed the `500 bp` limit.
    * __Fix:__ Adjust the `maximum fragment size` using `-X` <int> (e.g., `-X 1000`). [2, 3] 

    ## 2. Genetic Drift in Lab Strains
    The official MG1655 reference (`U00096.3`) may not perfectly match your specific lab sample. [4, 5] 

    * __Structural Variation:__ Laboratory _E. coli_ K-12 strains frequently accumulate Inversions, Deletions, or Insertion Sequence (IS) element movements.
    * __The Result:__ If a segment of the genome is inverted in your sample compared to the reference, the mates will map in the wrong orientation (e.g., Forward-Forward), causing them to be flagged as discordant. [6, 7, 8] 

    ## 3. Read "Dovetailing"
    "Dovetailing" occurs when one mate alignment extends past the beginning of the other (common in libraries with very short DNA fragments). [2, 3] 

    * __The Issue:__ By default, `Bowtie2` considers dovetailing to be non-concordant.
    * __Fix:__ Add the `--dovetail` flag to your command to allow these reads to be considered concordant. [2,3] 

    ## 4. Mismatched Library Orientation
    Standard Illumina sequencing uses the Forward-Reverse (`--fr`) orientation. [2,6] 

    * __The Issue:__ If your library protocol uses a different orientation (e.g., `--rf` or `--ff`) and you did not specify it, the software will mark almost every correctly mapped pair as discordant.
    * __Fix:__ Verify your library type and use the appropriate flag (`--fr`, `--rf`, or `--ff`). [1, 3, 6] 

    ## 5. Repetitive Elements
    The _E. coli_ genome contains repetitive regions, such as rRNA operons. [9] 

    * __The Issue:__ If each mate of a pair maps uniquely but to different copies of a repeat (e.g., one to rrnA and one to rrnB), the resulting distance or orientation will not match the reference expectations, leading to a discordant flag. [10] 

    ## 6. `Trimmomatic` for Synchronization and Artifact Removal
    Using [`Trimmomatic`](https://pmc.ncbi.nlm.nih.gov/articles/PMC4103590/) is often more effective than tools like `fastp` for reducing discordance because of its strict handling of paired-end constraints.

    * __Superior "Dovetail" Prevention:__ `Trimmomatic`'s `Palindrome mode` aligns the two mates against each other to identify and remove adapter sequences with high precision. This eliminates the "overhangs" that cause `Bowtie2` to flag pairs as discordant.
    * __Guarding Physical Distance:__ By using `SLIDINGWINDOW` to aggressively trim low-quality ends, `Trimmomatic` ensures that `Bowtie2` works with high-confidence bases, preventing "noisy" read ends from being mapped to incorrect, distant locations.
    * __Absolute Synchronization:_ `Trimmomatic`'s `PE` mode strictly maintains read order. If a mate is discarded, its partner is moved to an "unpaired" file. This prevents the "desynchronization" often seen in automated tools, where a shift in read order causes 100% discordance.
    

    [1] [`Bowtie2` Manual](https://gensoft.pasteur.fr/docs/bowtie2/2.5.4/)  
    [2] [`Bowtie2` Output, Concordant Vs. Discordant Mapping??](https://www.biostars.org/p/78446/)  
    [3] [`Bowtie2` for paired-end reads and own genome](https://chipster.csc.fi/manual/bowtie2-paired-end-with-index-building.html)  
    [4] [Newly Identified Genetic Variations in Common _Escherichia coli_ MG1655 Stock Cultures](https://pmc.ncbi.nlm.nih.gov/articles/PMC3256642/)  
    [5] [_Escherichia coli_ K-12 substr. MG1655](https://biocyc.org/ECOLI/organism-summary)  
    [6] [`bowtie` `--fr`/`--rf`/`--ff` reporting](https://www.biostars.org/p/204218/)  
    [7] [Laboratory strains of _Escherichia coli_ K-12: things are seldom what they seem](https://pmc.ncbi.nlm.nih.gov/articles/PMC9997739/)  
    [8] [_Escherichia coli_ K-12 MG1655 sequence and annotations U00096.3 (aka version 3)](https://www.genome.wisc.edu/sequencing/k12.htm)  
    [9] [_Escherichia coli_ K-12: a cooperatively developed annotation snapshot—2005](https://pmc.ncbi.nlm.nih.gov/articles/PMC1325200/)  
    [10] [Discordant mapping of `R1` and `R2` in WGS studies: understanding Illumina paired-end sequencing.](https://www.revvity.com/blog/discordant-mapping-r1-and-r2-wgs-studies-understanding-illumina-paired-end-sequencing)  
