## lofreq_pipeline

Para lanzar lofreq con Best Practices y Gatk 4. No generalizado, con las rutas de mi ordenador. Faltan los archivos de las referencias.

El script principial es lofreqGatk4.sh. Se obtiene vcf de las variantes con sus frecuencias alelicas, el filtrado quitando las zonas problematicas y el histograma de las frecuencias de las variantes. NO tiene en cuenta nada de indels.


Elaborado siguiendo Best Practices para Lofreq. "https://github.com/CSB5/lofreq/blob/master/devel-doc/best-practices.txt"

Para ejecutar Gatk 4 hace falta java 8 (no superior). Si no se esta en esa version:
sudo update-alternatives --config java
para cambiar a java 8 (cambiar al final de nuevo a 11)

Se supone que algunas herramientas de Gatk 4 necesitan cierto entorno de python. Esta instalado y se activa con:
source activate gatk
Pero no parece que sea necesario con estas herramientas, asi que no hace falta activarlo. Y mejor, pq el script de python del final es java 2 y puede no funcionar si el entorno es java 3.

El Base Recalibrator (BQSR) de Gatk necesita una lista de SNPs ya detectados. Se le puede dar una lista vacia, pero aprovechamos la BBDD que tenemos. Se puede utilizar el formato table. Para gatk4 hay que hacer:
mv BBDD_260718 BBDD_260718.table
~/programitas/gatk-4.0.6.0/gatk IndexFeatureFile -F BBDD_260718.table 
Hay que darle extension .table para que gatk4 sepa lo que es e indexarlo (en gatk 3 detectaba el nombre de otra manera y lo indexaba solo)

Tambien hace falta crear un sequence dictionary del genoma de referencia:
~/programitas/gatk-4.0.6.0/gatk CreateSequenceDictionary -R ~/Escritorio/gm/referencias/MTB_ancestorII_reference.fasta -O ~/Escritorio/gm/refe
rencias/MTB_ancestorII_reference.dict

Al hacer bwa mem le ponemos una cabecera al .bam resultado, porque luego lo pide gatk. Lo unico con un valor serio es lo de "illumina". Para lo demás en este caso ponemos cualquier cosa, pero con otros usos de gatk habría que mirarlo con más cuidado por si acaso


