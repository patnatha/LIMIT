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
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.Object;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.File;
import java.io.InputStream;
import java.io.StringWriter;

public class QuerySql {
    public static void main(String[] args) throws SQLException, IOException {
        //Specify all the variable for connecting to the database
        System.out.println("Welcome to the Sql Database Connector");
        Connection conn = null;
        ResultSet rs = null;
        String url = "jdbc:jtds:sqlserver://rdw-db.med.umich.edu:1433;databaseName=RDW_Views;domain=UMHS;useNTLMv2=true;useLOBs=false;";
        String driver = "net.sourceforge.jtds.jdbc.Driver";

        //Attempt to load credentials from text file
        Properties prop = new Properties();
        prop.load(new FileInputStream("credential.txt"));
        String userName = prop.getProperty("username");
        String password = prop.getProperty("password");

        //Get the username from the console
        if(userName == null){
            Scanner sc = new Scanner(System.in);
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
            System.out.println("Connected to the database!!!");
           
            //Get a list of all the Views 
            /*DatabaseMetaData dbm = conn.getMetaData();
            rs = dbm.getTables(null, null, "%", new String[] { "VIEW" });
            while (rs.next()) {
                System.out.println(rs.getString(3)); 
            }*/

            //Search for potassium values
            //String[] analytes = new String[]{"SOD"};
            //String[] analytes = new String[]{"HGBN","HGB"};
            //String[] analytes = new String[]{"GLUC","GLUC-WB"};
            String[] analytes = new String[]{"POT","POTPL"};
            boolean completeCohort = findCohort(analytes, conn);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            conn.close();
            //rs.close();
        }
    }

    public static boolean findCohort(String[] analyte, Connection conn) throws SQLException {
        if(analyte == null || analyte.length == 0){
            return false;
        }

        //Print some output for debugging
        System.out.println("Querying: " + String.join(",",analyte));
        
        //Manage the output directories
        File theDir = new File("downloads");
        if(!theDir.exists()) {
            theDir.mkdir();
        }
        theDir = new File("downloads/" + String.join("_",analyte));
        if(theDir.exists()){
            theDir.delete(); 
        }
        theDir.mkdir();

        //Create the output file
        String outputFile = "downloads/" + String.join("_",analyte) + "/LabResults.txt"; 

        //Build the select query 
        String sql = "SELECT * FROM LabResults WHERE "; 
        sql += "COLLECTION_DATE < '01/01/17' AND COLLECTION_DATE > '01/01/2014' ";
        sql += "AND (";
        for(int i = 0; i < analyte.length; i++){
            sql += "RESULT_CODE = '" + analyte[i];
            if(analyte.length > 1 && i + 1 < analyte.length){
                sql += "' OR ";
            }
            else{
                sql += "'";
            }
        }    
        sql += ");";

        //System.out.println(sql); 
        ResultSet rs = null;
        try{
            //Setup the statement
            PreparedStatement cursor = conn.prepareStatement(sql);
            cursor.setFetchDirection(ResultSet.FETCH_FORWARD);
            cursor.setFetchSize(10000);
            cursor.setQueryTimeout(60 * 60);

            //Run the statment
            rs = cursor.executeQuery();

            //Get the meta data
            ResultSetMetaData rsmd = rs.getMetaData();
            String[] colNames = new String[rsmd.getColumnCount()];
            for(int i = 0; i < rsmd.getColumnCount(); i++){
                colNames[i] = (rsmd.getColumnName(i + 1));
            }

            //Iterate over results and write to file
            try (BufferedWriter out = new BufferedWriter(new FileWriter(outputFile))) {
                //Define the deilimter and end of line characters
                String delimiter = "\t";
                String endOfLine = "\n";

                //Write the column name lines
                out.write(String.join(delimiter, colNames) + endOfLine);

                //Iterate over the results
                while(rs.next()){
                    //Define the result string of columns
                    String[] curRow = new String[colNames.length];

                    //Itrerate over the columns
                    for(int i = 0; i < colNames.length; i++){
                        //Get the column data
                        Object curVal = rs.getObject(colNames[i]);

                        //Switch on the column class type
                        if(curVal == null){
                            curRow[i] = "";
                        }
                        else if(curVal.getClass() == java.lang.String.class){
                            curRow[i] = rs.getString(colNames[i]);
                        } else if(curVal.getClass() == java.lang.Integer.class){
                            curRow[i] = Integer.toString(rs.getInt(colNames[i]));
                        } else if(curVal.getClass() == java.sql.Clob.class){
                            curRow[i] = rs.getString(colNames[i]); 
                        }
                        else{
                            //Error column
                            curRow[i] = "";
                            System.out.println(colNames[i]);
                            System.out.println(curVal);
                            System.out.println(curVal.getClass());
                        }

                        //Remove all quotes in the values
                        curRow[i] = curRow[i].replace("\"","");
                    }
    
                    //Write the current row to text file
                    out.write(String.join(delimiter, curRow) + endOfLine); 
                }
            }
        } catch (Exception e){
            e.printStackTrace();
            return false;
        } finally {
            rs.close();
        }

        return true; 
    }
}

