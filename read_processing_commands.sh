#The following commands provide an overview of running a pipeline for genomic resequencing using breseq
#Only general commands for primary tools are included here. In practice, commands may need to be modified based on file naming schemes and environement setup.
#Additionally, we reccomend submitting this code through a job scheduler such as SLURM if working on a cluster environment to enable parralelization.

#Step 1: Examine reads using fastqc and multiqc
fastqc -o fastqc_output_dir/ raw_reads/*.fastqc.gz
multiqc fastqc_output_dir/

#Step 2: Trim reads using trim_galore as neccesary
trim_galore --paired read_file_1.fastq.gz read_file_2.fastq.gz -o trimmed_reads/
fastqc -o fastqc_trimmed_output_dir/ trimmed_reads/*.fq.gz
multiqc fastqc_trimmed_output_dir/

#Step 3: Align reads to reference genome and look for mutations using breseq
breseq -r reference_genome.gbk -o breseq_output_dir/ trimmed_reads/read_file_1.fq.gz trimmed_reads/read_file_2.fq.gz

#Step 4: Aggregate breseq results using gdtools on the gd files generated from each breseq run
gdtools compare -r reference_genome.gbff -o gdtools_output.html gd_files/*.gd  #For HTML report
gdtools compare -r reference_genome.gbff -o gdtools_output.csv -f TABLE gd_files/*.gd  #For CSV report
gdtools compare -r reference_genome.gbff -o gdtools_output.tsv -f TSV gd_files/*.gd  #For TSV report

#Step 5: Analyze html file visually and t/csv flat files in R for further analysis
#To visualize read pileups using IGV, starting with trimmed files from step 2 (or untrimmed if no trimming needed from step 1)
#Step 3: Align reads to reference genome using bowtie2
bowtie2 -x bt2_species_index -1 trimmed_reads/read_file_1.fq.gz -2 trimmed_reads/read_file_2.fq.gz -S output.sam

#Step 4: Convert compress sam, sort and index bam files
samtools view -S -b output.sam > output.bam
samtools sort output.bam -o output_sorted.bam
samtools index output_sorted.bam

#Step 5: Visualize using IGV