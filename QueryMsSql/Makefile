# Detect if operating system is Windows
ifeq ($(OS),Windows_NT)
	cpFlags=".;.\commons-io-2.5\commons-io-2.5.jar;.\jtds-1.3.1-dist\jtds-1.3.1.jar"
else
	cpFlags=".:jtds-1.3.1-dist/jtds-1.3.1.jar:commons-io-2.5/commons-io-2.5.jar"
endif

QuerySql.class: QuerySql.java 
	javac -classpath $(cpFlags) -Xlint QuerySql.java

DownloadAllEncounters.class: DownloadAllEncounters.java
	javac -classpath $(cpFlags) DownloadAllEncounters.java
	
DownloadAllLabs.class: DownloadAllLabs.java
	javac -classpath $(cpFlags) DownloadAllLabs.java

downAnalyte: QuerySql.class
	java -cp $(cpFlags) -Xmx1024m QuerySql

downEnc: DownloadAllEncounters.class
	java -cp $(cpFlags) -Xmx1024m DownloadAllEncounters

downLab: DownloadAllLabs.class
	java -cp $(cpFlags) -Xmx1024m DownloadAllLabs

clean: 
	rm ./QuerySql.class
	rm ./DownloadAllEncounters.class
	rm ./DownloadAllLabs.class
	
