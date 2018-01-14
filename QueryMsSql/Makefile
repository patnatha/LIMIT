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
	
DownloadAllDiagnosis.class: DownloadAllDiagnosis.java
	javac -classpath $(cpFlags) DownloadAllDiagnosis.java

DownloadAllMeds.class: DownloadAllMeds.java
	javac -classpath $(cpFlags) DownloadAllMeds.java

DownloadAllPatientInfo.class: DownloadAllPatientInfo.java
	javac -classpath $(cpFlags) DownloadAllPatientInfo.java

DownloadAllDemographicInfo.class: DownloadAllDemographicInfo.java
	javac -classpath $(cpFlags) DownloadAllDemographicInfo.java
	
downAnalyte: QuerySql.class
	java -cp $(cpFlags) -Xmx1024m QuerySql

downEnc: DownloadAllEncounters.class
	java -cp $(cpFlags) -Xmx1024m DownloadAllEncounters

downLab: DownloadAllLabs.class
	java -cp $(cpFlags) -Xmx1024m DownloadAllLabs

downDiag: DownloadAllDiagnosis.class
	java -cp $(cpFlags) -Xmx1024m DownloadAllDiagnosis

downMed: DownloadAllMeds.class
	java -cp $(cpFlags) -Xmx1024m DownloadAllMeds

downPatientInfo: DownloadAllPatientInfo.class
	java -cp $(cpFlags) -Xmx1024m DownloadAllPatientInfo

downDemoInfo: DownloadAllDemographicInfo.class
	java -cp $(cpFlags) -Xmx1024m DownloadAllDemographicInfo
	
clean: 
	rm ./QuerySql.class
	rm ./DownloadAllEncounters.class
	rm ./DownloadAllLabs.class
	rm ./DownloadAllMeds.class
	rm ./DownloadAllDiagnosis.class
	rm -rf downloads
	
