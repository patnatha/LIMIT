import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.io.Console;
import java.util.Scanner;
import java.util.Properties;
import java.util.ArrayList;
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.File;
import java.io.InputStream;
import java.io.StringWriter;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.HashMap;
import java.util.Arrays;
import java.util.Map;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.text.SimpleDateFormat;
import org.apache.commons.io.FileUtils;

public class DownloadAllLabs {
    public static void main(String[] args) throws SQLException, IOException {	
		//Specify all the variable for connecting to the database
		Connection conn = null;		
		ResultSet rs = null;
		String url = "jdbc:jtds:sqlserver://rdw-db.med.umich.edu:1433;databaseName=RDW_Views;domain=UMHS;useNTLMv2=true;useLOBs=false;";
		String driver = "net.sourceforge.jtds.jdbc.Driver";
		
		//Scanner for getting user input
		Scanner sc = new Scanner(System.in);
		
        //Attempt to load credentials from text file
        String userName = null;
        String password = null;
        try{
            Properties prop = new Properties();
            prop.load(new FileInputStream("credential.txt"));
            userName = prop.getProperty("username");
            password = prop.getProperty("password");
        } catch (Exception e){
            
        }

        //Get the username from the console
		System.out.println("**********Database Connection**********");
        if(userName == null){
            System.out.print("Username: ");
            userName = sc.next();
        }

        //Get the password from the console
        if(password == null){
            Console console = System.console(); 
            password = new String(console.readPassword("Password: "));
        }

        try {
            //Open the connection to the database
            Class.forName(driver);
            conn = DriverManager.getConnection(url, userName, password);
            conn.setAutoCommit(false);
            
            String sql = "SELECT ";
			sql += "PatientID,EncounterID,ACCESSION_NUMBER,COLLECTION_DATE,OBSERVATION_DATE,ActivityDate,ORDER_CODE,ORDER_NAME,RESULT_CODE,RESULT_NAME,RESULT_TERMID,VALUE,UNIT,RANGE,HILONORMAL_FLAG,HILONORMAL_COMMENT,RESULT_COMMENT,ORDER_COMMENT ";
            sql += "FROM LabResults ";
			//sql += "WHERE COLLECTION_DATE >= '2000/01/01' AND COLLECTION_DATE < '2005/01/01'";
			//sql += "WHERE COLLECTION_DATE >= '2005/01/01' AND COLLECTION_DATE < '2008/01/01'";
			//sql += "WHERE COLLECTION_DATE >= '2008/01/01' AND COLLECTION_DATE < '2011/01/01'";
			//sql += "WHERE COLLECTION_DATE >= '2011/01/01' AND COLLECTION_DATE < '2014/01/01'";
			//sql += "WHERE COLLECTION_DATE > '2014/01/01' AND COLLECTION_DATE < '2015/01/01'";
			//sql += "WHERE COLLECTION_DATE > '2015/01/01' AND COLLECTION_DATE < '2016/01/01'";
			//sql += "WHERE COLLECTION_DATE > '2016/01/01' AND COLLECTION_DATE < '2017/01/01'";
			sql += "WHERE COLLECTION_DATE > '2017/01/01' AND COLLECTION_DATE < '2018/01/01'";
			try{
				System.out.println("Building Query");
				
				//Setup the statement
				PreparedStatement cursor = conn.prepareStatement(sql);
				cursor.setFetchDirection(ResultSet.FETCH_FORWARD);
				cursor.setFetchSize(10000);
				cursor.setQueryTimeout(60 * 60 * 10);

				//Run the statment
				System.out.println("Execute Query");
				rs = cursor.executeQuery();
			
				//Write the results to an output file
				System.out.println("Write Results to File");
				String outputFile = findDirPath() + "/LabResults.txt";
				writeResultSetToFile(rs, outputFile, false);
			} catch (Exception e){
				e.printStackTrace();
			} finally {
				rs.close();
			}
			
            //Write a DONE file
            String dirPath = findDirPath() + "/Done.txt";
			BufferedWriter out = new BufferedWriter(new FileWriter(dirPath));
			out.write("YASE");
			out.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            conn.close();
        }
    }
	
	public static boolean writeResultSetToFile(ResultSet rs, String fileName, Boolean appendIt) throws IOException {
        BufferedWriter out = null;
		
		try{
			//Define the deilimter and end of line characters
            String delimiter = "\t";
            String endOfLine = "\n";
			
            //Get the column names
            String[] colNames = getColumnNames(rs);

			if(! appendIt){
				//Over write any file that already exists
				out = new BufferedWriter(new FileWriter(fileName));
				out.write(String.join(delimiter, colNames) + endOfLine);
			}
			else{
				//Check to see if the file already exists
				File yase = new File(fileName);
				if(yase.exists()){
					//Append results to the output file
					out = new BufferedWriter(new FileWriter(fileName, true));
				}
				else{
					//Create a new file to write results to 
					out = new BufferedWriter(new FileWriter(fileName));
					out.write(String.join(delimiter, colNames) + endOfLine);
				}
			}

            //Iterate over the results
            while(rs.next()){
                //Define the result string of columns
                String[] curRow = convertRowToString(colNames, rs);

                //Write the current row to text file
                if(curRow != null){
                    out.write(String.join(delimiter, curRow) + endOfLine);
                }
            }
			
			if(out != null){
				out.close();
			}
        } catch (Exception e){
			if(out != null){
				out.close();
			}
            e.printStackTrace();
            return false;
        }
		
        return true;
    }

    public static String[] getColumnNames(ResultSet rs) throws SQLException {
        //Get the meta data
        ResultSetMetaData rsmd = rs.getMetaData();
        String[] colNames = new String[rsmd.getColumnCount()];
        for(int i = 0; i < rsmd.getColumnCount(); i++){
            colNames[i] = (rsmd.getColumnName(i + 1));
        }

        return colNames;   
    }

    public static String[] convertRowToString(String[] colNames, ResultSet theRow) {
        try{
            //Create the output string array
            String[] curRow = new String[colNames.length];
       
            //Itrerate over the columns
            for(int i = 0; i < colNames.length; i++){
                //Get the column data
                Object curVal = theRow.getObject(colNames[i]);

                //Switch on the column class type
                if(curVal == null){
                    curRow[i] = "";
                }
                else if(curVal.getClass() == java.lang.String.class){
                    curRow[i] = theRow.getString(colNames[i]);
                } else if(curVal.getClass() == java.lang.Integer.class){
                    curRow[i] = Integer.toString(theRow.getInt(colNames[i]));
                } else if(curVal.getClass() == java.sql.Clob.class){
                    curRow[i] = theRow.getString(colNames[i]);
                } else if(curVal.getClass() == java.math.BigDecimal.class){
                    curRow[i] = theRow.getBigDecimal(colNames[i]).toString();
				} else if(curVal.getClass() == java.lang.Boolean.class){
					curRow[i] = theRow.getString(colNames[i]);
                } else {
                    //Error column
                    curRow[i] = "";
                    System.out.println("ERROR: convertRowToString");
                    System.out.println(colNames[i]);
                    System.out.println(curVal);
                    System.out.println(curVal.getClass());
                }

                //Remove invalid characters from input
                curRow[i] = curRow[i].replace("\"","");
                curRow[i] = curRow[i].replace("\t","");
                curRow[i] = curRow[i].replace("\n","");
                curRow[i] = curRow[i].replace("\r","");
            }

            //Return the row
            return curRow;
        } catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }
    
    public static String findDirPath(){
    	//Create the download directory
        File theDir = new File("downloads");
        if(!theDir.exists()) {
            theDir.mkdir();
        }
    
        //Create the analyte directory
        theDir = new File("downloads/LabResults");
        if(!theDir.exists()){
            theDir.mkdir();
        }
        
        return theDir.getPath();
    }
}

