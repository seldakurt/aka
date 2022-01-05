fq1=$1
fq2=$2
dna=$3
#fastqc
fastqc "${fq1}" "${fq2}"
#bowtie built index
#bowtie2-build GCF_000001405.39_GRCh38.p13_genomic.fna GRCh38_noalt_as
#align reads
bowtie2 -x GRCh38_noalt_as -1 ${fq1} -2 ${fq2} -S "${dna}.sam"
#Sam to bam
samtools view -b "${dna}.sam" > "${dna}.bam"
#sort a bam file
samtools sort "${dna}.bam" -o "${dna}.sorted.bam"
#index sorted bam
samtools index "${dna}.sorted.bam"
#variant calling
bcftools mpileup -f GCF_000001405.39_GRCh38.p13_genomic.fna "${dna}.sorted.bam"| \
bcftools call -mv -Ov --ploidy GRCh38 -o "${dna}.vcf"
#filter quality
cut -f1-6 "${dna}.vcf"
bcftools view -i '%QUAL>=40' "${dna}.vcf"
