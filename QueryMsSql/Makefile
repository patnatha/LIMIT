# Detect if operating system is Windows
ifeq ($(OS),Windows_NT)
	cpFlags=".;.\commons-io-2.5\commons-io-2.5.jar;.\jtds-1.3.1-dist\jtds-1.3.1.jar"
else
	cpFlags=".:jtds-1.3.1-dist/jtds-1.3.1.jar:commons-io-2.5/commons-io-2.5.jar"
endif

# Compile the program
QuerySql.class: QuerySql.java
	javac -classpath $(cpFlags) -Xlint QuerySql.java

# Run the program
run: QuerySql.class
	java -cp $(cpFlags) -Xmx1024m QuerySql

# Clear out the compiled version
clean: 
	rm .\QuerySql.class
	rm ./QuerySql.class
	