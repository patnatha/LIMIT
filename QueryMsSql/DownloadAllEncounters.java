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

public class DownloadAllEncounters {
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
            
            String sql = "SELECT * FROM Encounter"
            
            //System.out.println(sql); 
			ResultSet rs = null;
			try{
				//Setup the statement
				PreparedStatement cursor = conn.prepareStatement(sql);
				cursor.setFetchDirection(ResultSet.FETCH_FORWARD);
				cursor.setFetchSize(10000);
				cursor.setQueryTimeout(60 * 60 * 10);

				//Run the statment
				rs = cursor.executeQuery();
			
				//Write the results to an output file
				return writeResultSetToFile(rs, outputFile, false);
			} catch (Exception e){
				e.printStackTrace();
				return false;
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
    
    public static String findDirPath(){
    	//Create the download directory
        File theDir = new File("downloads");
        if(!theDir.exists()) {
            theDir.mkdir();
        }
    
        //Create the analyte directory
        theDir = new File("downloads/Encounters");
        if(!theDir.exists()){
            theDir.mkdir();
        }
        
        return theDir.getPath();
    }
}

