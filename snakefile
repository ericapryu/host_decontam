# The purpose of this script is to QC the microbiome reads and remove host contaminants 

# define variables - modify as needed
initial_input_dir="data/raw/"
bowtie_ref="data/refs/hg38_index/hg38"
snap_ref="data/refs/hg38_snap"
conda_env="host_decontam.yml"
threads=15

# define variables - DO NOT CHANGE
fastqc_input=initial_input_dir+"{sample}_{read}.fastq.gz"
bowtie2_input_r1=initial_input_dir+"{sample}_R1.fastq.gz"
bowtie2_input_r2=initial_input_dir+"{sample}_R2.fastq.gz"

# define sample files 
(SAMPLES,READS,)=glob_wildcards(os.path.join(initial_input_dir,"{sample}_{read}.fastq.gz"))
READS=["R1","R2"]

# rules 
rule all:
    input:
        # initial fastqc
        expand("output/1.fastqc_initial/{sample}_{read}_fastqc.{extension}", sample=SAMPLES, read=READS, extension=["zip","html"]),
        # reads mapping to human genome
        expand("output/2.bowtie2/mapped/1.sam_files/{sample}_mapped.sam", sample=SAMPLES),
        expand("output/3.snap/mapped/1.sam_files/{sample}_mapped.sam", sample=SAMPLES),
        # reads not mapping to human genome
        expand("output/3.snap/unmapped/3.fastq/{sample}_unmapped_{read}.fastq", sample=SAMPLES, read=READS),
        # final fastqc
        expand("output/4.fastqc_final/{sample}_unmapped_{read}_fastqc.{extension}", sample=SAMPLES, read=READS, extension=["zip","html"])

rule fastqc_initial:
    input:
        fastqc_input
    output:
        "output/1.fastqc_initial/{sample}_{read}_fastqc.html",
        "output/1.fastqc_initial/{sample}_{read}_fastqc.zip"
    params:
        dir="output/1.fastqc_initial"
    threads: threads
    shell:
        "mkdir -p {params.dir};"
        "module load fastqc;"
        "fastqc -t {threads} {input} -o {params.dir}"

rule bowtie2_align:
    input:
        # determine `r1` based on the {sample} wildcard defined in `output`
        # and the fixed value `1` to indicate the read direction
        r1=bowtie2_input_r1,
        # determine `r2` based on the {sample} wildcard similarly
        r2=bowtie2_input_r2
    output:
        "output/2.bowtie2/sam_files/{sample}.sam"
    params: 
        index_prefix=bowtie_ref
    conda:
        conda_env
    threads: threads
    shell:
        '''
        bowtie2 -p {threads} \
            -x {params.index_prefix} \
            -1 {input.r1} \
            -2 {input.r2} \
            -S {output}
        '''

rule bowtie2_sort_map:
    input:
        "output/2.bowtie2/sam_files/{sample}.sam"
    output:
        unmapped="output/2.bowtie2/unmapped/1.sam_files/{sample}_unmapped.sam",
        mapped="output/2.bowtie2/mapped/1.sam_files/{sample}_mapped.sam"
    conda:
        conda_env
    shell:
        "samtools view -b -f 4 {input} > {output.unmapped};"
        "samtools view -b -F 4 {input} > {output.mapped}"

rule bowtie2_sort_coord:
    input:
        "output/2.bowtie2/unmapped/1.sam_files/{sample}_unmapped.sam"
    output:
        "output/2.bowtie2/unmapped/2.sorted_sam/{sample}_sort_unmapped.sam"
    conda:
        conda_env
    shell:
        "samtools sort -n {input} -o {output}"

rule bowtie2_fastq:
    input:
        "output/2.bowtie2/unmapped/2.sorted_sam/{sample}_sort_unmapped.sam"
    output:
        r1="output/2.bowtie2/unmapped/3.fastq/{sample}_unmapped_R1.fastq",
        r2="output/2.bowtie2/unmapped/3.fastq/{sample}_unmapped_R2.fastq"
    conda:
        conda_env
    shell:
        '''
        samtools fastq {input} \
            -1 {output.r1} \
            -2 {output.r2}  \
            -0 /dev/null -s /dev/null -n
        '''

rule snap_align:
    input:
        r1="output/2.bowtie2/unmapped/3.fastq/{sample}_unmapped_R1.fastq",
        r2="output/2.bowtie2/unmapped/3.fastq/{sample}_unmapped_R2.fastq"
    output:
        "output/3.snap/sam_files/{sample}.sam"
    params: 
        index_prefix=snap_ref
    conda:
        conda_env
    threads: threads
    shell:
        '''
        snap-aligner paired {params.index_prefix} \
            {input.r1} \
            {input.r2} \
            -o {output} \
            -t {threads}
        '''

rule snap_sort_map:
    input:
        "output/3.snap/sam_files/{sample}.sam"
    output:
        unmapped="output/3.snap/unmapped/1.sam_files/{sample}_unmapped.sam",
        mapped="output/3.snap/mapped/1.sam_files/{sample}_mapped.sam"
    conda:
        conda_env
    shell:
        "samtools view -b -f 4 {input} > {output.unmapped};"
        "samtools view -b -F 4 {input} > {output.mapped}"

rule snap_sort_coord:
    input:
        "output/3.snap/unmapped/1.sam_files/{sample}_unmapped.sam"
    output:
        "output/3.snap/unmapped/2.sorted_sam/{sample}_sort_unmapped.sam"
    conda:
        conda_env
    shell:
        "samtools sort -n {input} -o {output}"

rule snap_fastq:
    input:
        "output/3.snap/unmapped/2.sorted_sam/{sample}_sort_unmapped.sam"
    output:
        r1="output/3.snap/unmapped/3.fastq/{sample}_unmapped_R1.fastq",
        r2="output/3.snap/unmapped/3.fastq/{sample}_unmapped_R2.fastq"
    conda:
        conda_env
    shell:
        '''
        samtools fastq {input} \
            -1 {output.r1} \
            -2 {output.r2}  \
            -0 /dev/null -s /dev/null -n
        '''

rule fastqc_final:
    input:
        "output/3.snap/unmapped/3.fastq/{sample}_unmapped_{read}.fastq"
    output:
        "output/4.fastqc_final/{sample}_unmapped_{read}_fastqc.html",
        "output/4.fastqc_final/{sample}_unmapped_{read}_fastqc.zip"
    params:
        dir="output/4.fastqc_final"
    threads: threads
    shell:
        "mkdir -p {params.dir};"
        "module load fastqc;"
        "fastqc -t {threads} {input} -o {params.dir}"