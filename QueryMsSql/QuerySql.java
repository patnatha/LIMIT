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
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.HashMap;
import java.util.Map;

public class QuerySql {
    public static void main(String[] args) throws SQLException, IOException {
        //Specify all the variable for connecting to the database
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

            //Search for potassium values
            //String[] analytes = new String[]{"SOD"};
            //String[] analytes = new String[]{"HGBN","HGB"};
            //String[] analytes = new String[]{"GLUC","GLUC-WB"};
            String[] analytes = new String[]{"POT","POTPL"};

            //Use lab values for cohort discovery
            if(true && findCohort(analytes, conn)){
                System.out.println("LabResults: Success");
            }
            else{
                System.out.println("LabResults: Failure");
            }
       
            //Get the list of unique pids 
            String[][] cohortUniq = FindUniquePids(getLabResultsPath(analytes));
            String[] cohortPIDS = cohortUniq[0];
            String[] cohortENCS = cohortUniq[1];

            //Query for the demographic info
            if(GetDemographicInfo(analytes, cohortPIDS, conn)){
                System.out.println("DemographicInfo: Success");
            }
            else{
                System.out.println("DemographicInfo: Failure");
            }

            //Query for the Diagnosis codes
            if(GetPatientInfo(analytes, cohortPIDS, conn)){
                System.out.println("PatientInfo: Success");
            }
            else{
                System.out.println("PatientInfo: Failure");
            }    

            //Query for the Diagnosis codes
            if(GetEncounters(analytes, cohortENCS, conn)){
                System.out.println("Encounters: Success");
            }
            else{
                System.out.println("Encounters: Failure");
            }

            //Query for the Diagnosis codes
            if(GetDiagnoses(analytes, cohortPIDS, conn)){
                System.out.println("Diagnoses: Success");
            }
            else{
                System.out.println("Diagnoses: Failure");
            }

            //Query for the Medications
            if(GetMedications(analytes, cohortPIDS, conn)){
                System.out.println("Medications: Success");
            }
            else{
                System.out.println("Medicaitons: Failure");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            conn.close();
        }
    }

    public static boolean GetDemographicInfo(String[] analytes, String[] uniquePids, Connection conn){
        try{
            String demoPath = getDemographicPath(analytes); 
            return GetAssociatedPidInfo(uniquePids, "DemographicInfo", "*", demoPath, conn);
        } catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }

    public static boolean GetPatientInfo(String[] analytes, String[] uniquePids, Connection conn){
        try{
            String patientPath = getPatientInfoPath(analytes); 
            return GetAssociatedPidInfo(uniquePids, "PatientInfo", "DOB", patientPath, conn);
        } catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }

    public static boolean GetDiagnoses(String[] analytes, String[] uniquePids, Connection conn){
        try{
            String diagPath = getDiagnosesPath(analytes);
            return GetAssociatedPidInfo(uniquePids, "DiagnosesComprehensive", "*", diagPath, conn);
        } catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }

    public static boolean GetMedications(String[] analytes, String[] uniquePids, Connection conn){
        try{
            String medsPath = getMedicationsPath(analytes); 
            return GetAssociatedPidInfo(uniquePids, "MedicationAdministrationsComprehensive", "*", medsPath, conn);
        } catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }

    public static boolean GetEncounters(String[] analytes, String[] uniqueEncs, Connection conn){
        try{
            String encountersPath = getEncountersPath(analytes);
            return GetAssociatedEncounterInfo(uniqueEncs, "EncounterAll", "*", encountersPath, conn);
        } catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }

    public static boolean GetEncounterLocations(String[] analytes, String[] uniqueEncs, Connection conn){
        try{
            String encountersLocPath = getEncounterLocationsPath(analytes);
            return GetAssociatedEncounterInfo(uniqueEncs, "EncounterLocationsInternal", "*", encountersLocPath, conn);
        } catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }

    public static boolean GetAssociatedPidInfo(String[] uniquePids, String sqlTable, String columns, String outputFile, Connection conn) throws SQLException {
        return GetAssociatedInfo(uniquePids, "PatientID", sqlTable, columns, outputFile, conn);
    }

    public static boolean GetAssociatedEncounterInfo(String[] uniquePids, String sqlTable, String columns, String outputFile, Connection conn) throws SQLException {
        return GetAssociatedInfo(uniquePids, "EncounterID", sqlTable, columns, outputFile, conn);
    }

    public static boolean GetAssociatedInfo(String[] uniqueIds, String whereCol, String sqlTable, String columns, String outputFile, Connection conn) throws SQLException {
        boolean returnRes = false;
        ResultSet rs = null;
        PreparedStatement cursor = null;
        try{
            if(uniqueIds == null || uniqueIds.length == 0){
                return false;
            }

            //Build the sql parameter
            String sql = "SELECT " + columns + " FROM " + sqlTable + " WHERE " + whereCol + " IN ";
            sql += "('" + String.join("','", uniqueIds) + "');";
    
            //Setup the statement
            cursor = conn.prepareStatement(sql);
            cursor.setFetchDirection(ResultSet.FETCH_FORWARD);
            cursor.setFetchSize(10000);
            cursor.setQueryTimeout(60 * 60);

            //Run the statment
            rs = cursor.executeQuery();

            //Write the results to an output file
            returnRes = writeResultSetToFile(rs, outputFile);
        } catch (Exception e){
            e.printStackTrace();
            returnRes = false;
        }
        finally{
            rs.close();
            cursor.close();
        }

        return returnRes;
    }

    public static String[][] FindUniquePids(String filePath){
        try{
            BufferedReader br = new BufferedReader(new FileReader(filePath));

            HashMap<String, Integer> hm = new HashMap<String, Integer>();  
            HashMap<String, Integer> hmEnc = new HashMap<String, Integer>();

            for (String line = br.readLine(); line != null; line = br.readLine()) {
                String[] pid = line.split("\t", 3);
                if(pid.length > 0){
                    String pidVal = pid[0];
                    if(pidVal.length() == 36){
                        //Add the EncounterID to a HashMap
                        String EncounterID = pid[1];
                        Integer newVal = 1;
                        if(hmEnc.containsKey(EncounterID)){
                            newVal = hmEnc.get(EncounterID) + 1;
                        }
                        hmEnc.put(EncounterID, newVal);

                        //Add the PatientID to a HashMap
                        newVal = 1;
                        if(hm.containsKey(pidVal)){
                            newVal = hm.get(pidVal) + 1;
                        }
                        hm.put(pidVal, newVal);
                    }
                    else{
                        //Print out poorley formed pids
                        //System.out.println(pidVal);
                    }
                }
            }

            br.close();

            String[][] outputResult = new String[2][];
            outputResult[0] = hm.keySet().toArray(new String[0]);
            outputResult[1] = hmEnc.keySet().toArray(new String[0]);
            return outputResult;
        } catch(Exception e){
            e.printStackTrace();
            return null;
        }
    }

    public static String getEncountersPath(String[] analytes){
        String dirPath = findDirPath(analytes);
        return dirPath + "/EncountersAll.txt";
    }

    public static String getEncounterLocationsPath(String[] analytes){
        String dirPath = findDirPath(analytes);
        return dirPath + "/EncounterLocations.txt";
    }

    public static String getPatientInfoPath(String[] analytes){
        String dirPath = findDirPath(analytes);
        return dirPath + "/PatientInfo.txt";
    }

    public static String getMedicationsPath(String[] analytes){
        String dirPath = findDirPath(analytes);
        return dirPath + "/MedicationAdministrationsComprehensive.txt";
    }

    public static String getDiagnosesPath(String[] analytes){
        String dirPath = findDirPath(analytes);
        return dirPath + "/DiagnosesComprehensive.txt";
    }

    public static String getDemographicPath(String[] analytes){
        String dirPath = findDirPath(analytes);
        return dirPath + "/DemographicInfo.txt";
    }

    public static String getLabResultsPath(String[] analytes){
        String dirPath = findDirPath(analytes);
        return dirPath + "/LabResults.txt";
    }

    public static String findDirPath(String[] analytes){
        //Create the download directory
        File theDir = new File("downloads");
        if(!theDir.exists()) {
            theDir.mkdir();
        }
    
        //Create the analyte directory
        theDir = new File("downloads/" + String.join("_", analytes));
        if(!theDir.exists()){
            theDir.mkdir();
        }

        //Return the base directory path
        return theDir.getPath(); 
    }

    public static boolean findCohort(String[] analyte, Connection conn) throws SQLException {
        if(analyte == null || analyte.length == 0){
            return false;
        }

        //Print some output for debugging
        System.out.println("LabResults: " + String.join(",", analyte));
        
        //Create the output file
        String outputFile = getLabResultsPath(analyte);

        //Build the select query 
        String sql = "SELECT TOP 50000 * FROM LabResults WHERE "; 
        
        //This is where you can filter the data range
        sql += "COLLECTION_DATE < '01/01/17' AND COLLECTION_DATE > '01/01/2014' ";
        
        //This is where you can filter the result codes
        sql += "AND (RESULT_CODE = '" + String.join("' OR RESULT_CODE = '", analyte) + "')";

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

            //Write the results to an output file
            return writeResultSetToFile(rs, outputFile);
        } catch (Exception e){
            e.printStackTrace();
            return false;
        } finally {
            rs.close();
        }
    }

    public static boolean writeResultSetToFile(ResultSet rs, String fileName) {
        try{
            //Get the column names
            String[] colNames = getColumnNames(rs);

            //Iterate over results and write to file
            try (BufferedWriter out = new BufferedWriter(new FileWriter(fileName))) {
                //Define the deilimter and end of line characters
                String delimiter = "\t";
                String endOfLine = "\n";

                //Write the column name lines
                out.write(String.join(delimiter, colNames) + endOfLine);

                //Iterate over the results
                while(rs.next()){
                    //Define the result string of columns
                    String[] curRow = convertRowToString(colNames, rs);

                    //Write the current row to text file
                    if(curRow != null){
                        out.write(String.join(delimiter, curRow) + endOfLine);
                    }
                }
            }
        } catch (Exception e){
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
}

