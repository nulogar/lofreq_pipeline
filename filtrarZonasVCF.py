#!/usr/bin/python
"""
Para eliminar de los archivos .vcf zonas que no nos interesan (PE/PPE, phage y repeat)
Creado especificamente para el archivo H37Rv_annotation2sytems.ptt. Otros formatos comprobar
"""
import sys

infile=sys.argv[1] #archivo .vcf a filtrar
outfile=sys.argv[2] #archivo de salida 


compfile="/home/usuario/Escritorio/gm/referencias/H37Rv_annotation2sytems.ptt"

try:
	inputfile = open(infile)
except IOError:
	print("%s does not exist!!" % infile)

try:
	zonasfile = open(compfile)
except IOError:
	print("%s does not exist!!" % compfile)

try:
	output = open(outfile,'w')
except IOError:
	print("File %s cannot be created!!" % outfile)


intervalos=[]
count=0

for i in range(3):
	line=zonasfile.readline()
#	print line

for line in zonasfile:
	line=line.rstrip()
#	print line
	words=line.split()
	if words[3]=="I":
		pass
	else:
#		print words[10]
		if ("PE/PPE" in str(words[10])) or ("phage" in str(words[10])) or ("repeat" in str(words[10])):
			start=int(words[1])
			end=int(words[2])
#			print start
#			print end
			intervalos.append(start)
			intervalos.append(end)

#print intervalos
#print len(intervalos)
zonasfile.close()



count=0
count2=0
for line in inputfile:
	if line[0]!="#":
		flag=0
		line=line.rstrip()
#		print line
		words=line.split()
		posicion=int(words[1])
#		print posicion
		for i in range(0,len(intervalos),2):
			if (posicion >=intervalos[i]) and (posicion<=intervalos[i+1]):
#				print intervalos[i]
				flag=1
				count+=1
#				print line
		if flag==0:
			output.write(line+"\n")
			count2+=1
	
#print count

inputfile.close()

output.close()
print "SNPs tras filtrado: "+str(count2)

