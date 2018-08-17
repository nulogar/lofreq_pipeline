#!/bin/bash
#Lanzar desde el directorio donde queramos los resultados
#Para lanzar lofreq con TB. Se podría utilizar para otro organismo cambiando el genoma de referencia y la BBDD de SNPs ya conocidos
#Utilizando Best Practices de lofreq y con Gatk v4.0.6.0. Las rutas son sin generalizar, de mi ordenador
#Hace falta java 8 (sudo update-alternatives --config java para cambiar si se tienen varias versiones)
#No hace falta activar entorno de python de gatk. Y mejor no activarlo porque el script de python de el final es java 2
#Tiene que estar el archivo de la BBDD de SNPs alguna vez detectados en algun formato que acepte gatk e indexada
#El genoma de referencia, aparte de indexado para bwa etc, debe de tener creado un .dict para gatk (diccionario)
#(aclaraciones mirar "comandos")
#
#Manejamos los argumentos de entrada
while getopts 1:2:n: option
do
        case "${option}"
        in
                1) FQ1=${OPTARG};;   #fastq (o .gz) forward                            
		2) FQ2=${OPTARG};;   #fastq (o .gz) reverse             
		n) nombre=${OPTARG};; #Identificador
		\?) exit 1;;
		:) exit 1;;
        esac
done

if [[ -z "$FQ1" || -z "$FQ2" || -z "$nombre" ]];
then
	echo "Compulsory argument (-1, -2, -n) needed!"	
	exit 2
fi 

bwa mem -R'@RG\tID:'$nombre'\tSM:'$nombre'\tPL:illumina\tLB:bar\tPU:foo' -t 4 /home/usuario/Escritorio/gm/referencias/MTB_ancestorII_reference.fasta "$FQ1" "$FQ2" > "$nombre".sam
#Lo de -R es para ponerle un read group en la cabecera que pide GATK. Para salir del paso

~/programitas/gatk-4.0.6.0/gatk FixMateInformation -I $nombre.sam -O $nombre.fixed.sam

~/programitas/gatk-4.0.6.0/gatk CleanSam -I $nombre.fixed.sam -O $nombre.fixed.cleaned.sam

samtools sort $nombre.fixed.cleaned.sam -o $nombre.fixed.cleaned.sorted.bam

~/programitas/lofreq_star-2.1.3.1/bin/lofreq viterbi --verbose -f ~/Escritorio/gm/referencias/MTB_ancestorII_reference.fasta $nombre.fixed.cleaned.sorted.bam  | samtools sort > $nombre.viterbi.sorted.bam

~/programitas/gatk-4.0.6.0/gatk MarkDuplicates -I $nombre.viterbi.sorted.bam -O $nombre.MarkDup.bam -M $nombre.metrics.txt

~/programitas/gatk-4.0.6.0/gatk LeftAlignIndels -R ~/Escritorio/gm/referencias/MTB_ancestorII_reference.fasta -I $nombre.MarkDup.bam -OUTPUT $nombre.LeftAlign.bam

~/programitas/gatk-4.0.6.0/gatk BaseRecalibrator -R ~/Escritorio/gm/referencias/MTB_ancestorII_reference.fasta -I $nombre.LeftAlign.bam -O $nombre.recal_data.table --known-sites /home/usuario/programitas/scripts/pipelineLofreq/BBDD_260718.table

~/programitas/gatk-4.0.6.0/gatk ApplyBQSR -R ~/Escritorio/gm/referencias/MTB_ancestorII_reference.fasta -I $nombre.LeftAlign.bam --bqsr-recal-file $nombre.recal_data.table -O $nombre.BQSR.bam

~/programitas/lofreq_star-2.1.3.1/bin/lofreq call -f ~/Escritorio/gm/referencias/MTB_ancestorII_reference.fasta -o $nombre.lofreq.vcf $nombre.BQSR.bam

python /home/usuario/programitas/scripts/pipelineLofreq/filtrarZonasVCF.py $nombre.lofreq.vcf $nombre.lofreq.vcf.filtrado

sed 's/;/\t/g' $nombre.lofreq.vcf.filtrado > $nombre.lofreq.vcf.filtrado.tsv
sed -i 's/AF=//g' $nombre.lofreq.vcf.filtrado.tsv

sed -i '1i CHROM	POS	ID	REF	ALT	QUAL	FILTER	DEPTH	ALLELE FREQUENCY	SB	DP4' $nombre.lofreq.vcf.filtrado.tsv

Rscript --vanilla /home/usuario/programitas/scripts/pipelineLofreq/histogramLofreq.R $nombre.lofreq.vcf.filtrado.tsv $nombre

#Borrar archivos intermedios. Si se quieren conservar comentar la siguiente linea
rm *sam *sorted* *MarkDup.bam *txt *LeftAlign* *table
