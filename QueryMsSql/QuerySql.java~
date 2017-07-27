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

public class QuerySql {
    public static void main(String[] args) throws SQLException, IOException {	
		//Construct variables for keeping track of values to search for
		ArrayList<ArrayList<String>> analytess = new ArrayList<ArrayList<String>>();
		ArrayList<String> temp = null;
		
		//Add the BMP values
		temp = new ArrayList<String>(Arrays.asList("SOD"));
		analytess.add(temp);
		temp = new ArrayList<String>(Arrays.asList("GLUC","GLUC-WB"));
		analytess.add(temp);
		temp = new ArrayList<String>(Arrays.asList("POT","POTPL"));
		analytess.add(temp);
		temp = new ArrayList<String>(Arrays.asList("CHLOR"));
		analytess.add(temp);
		temp = new ArrayList<String>(Arrays.asList("CAL"));
		analytess.add(temp);
		temp = new ArrayList<String>(Arrays.asList("UN"));
		analytess.add(temp);
		temp = new ArrayList<String>(Arrays.asList("BCARB"));
		analytess.add(temp);
		temp = new ArrayList<String>(Arrays.asList("CREAT"));
		analytess.add(temp);
		
		//Add the CBC values
		temp = new ArrayList<String>(Arrays.asList("HGBN","HGB"));
		analytess.add(temp);
		
		
		//Scanner for getting user input
		Scanner sc = new Scanner(System.in);
		
		//Print out the selection choices to the user
		System.out.println("**********Analyte Selection**********");
		System.out.println("Which analyte would you like to analyze?");
		for(int i = 0; i < analytess.size(); i++){
			Integer to = i + 1;
			System.out.println(to.toString() + ") " + analytess.get(i));
		}
	
		//Get user input
		ArrayList<String> analytes_temp = null;
		try{
			Integer to = analytess.size();
			System.out.print("Which One [1 - " + to.toString() + "]: ");
			String whichAnalyte = sc.next();
			analytes_temp = analytess.get(Integer.parseInt(whichAnalyte) - 1);
		}
		catch(Exception e){
			return;
		}
	
		//Assign the user intput to a variable for analyzing
		String[] analytes = analytes_temp.toArray(new String[analytes_temp.size()]);
	
		//Check to make sure that the destination folder is empty
		File toTest = new File(getLabResultsPath(analytes));
		if(toTest.exists()){
			System.out.println("**********Overwrite Results**********");
			System.out.print("Results Exists, would you like to clear them [Y|N]: ");
			String clearEm = sc.next();
			if(clearEm.equals("Y") || clearEm.equals("y")){
				FileUtils.deleteDirectory(new File(findDirPath(analytes)));
			}
			else{
				System.out.println("Error: cannot preceed");
				return;
			}
		}
			
		//Setup the date range to search
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");
		Date start = null;
		Date end = null;
		try{
			start = sdf.parse("2013/01/01");
			end = sdf.parse("2017/01/01");
		}
		catch(Exception e){
			return;
		}
		
		//Specify all the variable for connecting to the database
		Connection conn = null;		
		ResultSet rs = null;
		String url = "jdbc:jtds:sqlserver://rdw-db.med.umich.edu:1433;databaseName=RDW_Views;domain=UMHS;useNTLMv2=true;useLOBs=false;";
		String driver = "net.sourceforge.jtds.jdbc.Driver";
		
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

			//Setup the month iterator
			GregorianCalendar gcal = new GregorianCalendar();
			gcal.setTime(start);
			
			//Init the startTime and endTime
			String startDate = sdf.format(gcal.getTime());
			String endDate = null;
			
			//Create the structures for keeping track of old pids & encounters 
            HashMap<String, Integer> oldPids = new HashMap<String, Integer>();  
            HashMap<String, Integer> oldEncs = new HashMap<String, Integer>();
						
			System.out.println("**********Downloading**********");
			while(!gcal.getTime().after(end)){
				//Add a month to the current time
				gcal.add(Calendar.DAY_OF_YEAR, 14);
				endDate = sdf.format(gcal.getTime());
				System.out.println(startDate + " - " + endDate);
				
				//Use lab values for cohort discovery
				if(true && findCohort(analytes, startDate, endDate, conn)){
					System.out.println("LabResults: Success");
				}
				else{
					System.out.println("LabResults: Failure");
				}
		   
				//Get the list of unique pids and EncIDs in the most recent query
				String[][] cohortUniq = FindUniquePids(analytes);
				String[] incomingPIDS = cohortUniq[0];
				String[] incomingENCS = cohortUniq[1];

				//Iterate over the new PIDS and examine if they have been searched before
				ArrayList<String> finalPIDS = new ArrayList<String>();
				for(int i = 0; i < incomingPIDS.length; i++){
					String curPid = incomingPIDS[i];
					if(curPid != null && !oldPids.containsKey(curPid)){
						finalPIDS.add(curPid);
						oldPids.put(curPid, 0);
					}
				}
				String[] cohortPIDS = finalPIDS.toArray(new String[finalPIDS.size()]);
				
				//Iterate over the new ENCS and examine if they have been searched before
				ArrayList<String> finalENCS = new ArrayList<String>();
				for(int i = 0; i < incomingENCS.length; i++){
					String curEnc = incomingENCS[i];
					if(curEnc != null && !oldEncs.containsKey(curEnc)){
						finalENCS.add(curEnc);
						oldEncs.put(curEnc, 0);
					}
				}
				String[] cohortENCS = finalENCS.toArray(new String[finalENCS.size()]);
				
				//Query for the demographic info
				if(cohortPIDS.length > 0 && GetDemographicInfo(analytes, cohortPIDS, conn)){
					System.out.println("DemographicInfo: Success");
				}
				else{
					System.out.println("DemographicInfo: Failure");
				}

				//Query for patient information
				if(cohortPIDS.length > 0 && GetPatientInfo(analytes, cohortPIDS, conn)){
					System.out.println("PatientInfo: Success");
				}
				else{
					System.out.println("PatientInfo: Failure");
				}

				
				//Query for the encounter results
				/*if(cohortENCS.length > 0 && GetEncounters(analytes, cohortENCS, conn)){
					System.out.println("Encounters: Success");
				}
				else{
					System.out.println("Encounters: Failure");
				}
				
				//Query for the encounter results
				if(cohortENCS.length > 0 && GetEncounterLocations(analytes, cohortENCS, conn)){
					System.out.println("Encounters Locations: Success");
				}
				else{
					System.out.println("Encounters Locations: Failure");
				}*/
				
				//Query for the Diagnosis codes
				if(cohortPIDS.length > 0 && GetDiagnoses(analytes, cohortPIDS, conn)){
					System.out.println("Diagnoses: Success");
				}
				else{
					System.out.println("Diagnoses: Failure");
				}

				//Query for the Medications
				if(cohortENCS.length > 0 && GetMedications(analytes, cohortENCS, conn)){
					System.out.println("Medications: Success");
				}
				else{
					System.out.println("Medicaitons: Failure");
				}
				
				//Write the done file
				GetDone(analytes, conn);

				//Update the startDate with new endDate
				startDate = endDate;
			}
			
            

            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            conn.close();
        }
    }
	
	public static boolean GetDone(String[] analytes, Connection conn){
		try{
			String dirPath = findDirPath(analytes) + "/Done.txt";
			BufferedWriter out = new BufferedWriter(new FileWriter(dirPath));
			out.write("YASE");
			out.close();
			return true;
		} catch (Exception e){
			e.printStackTrace();
			return false;
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
            return GetAssociatedPidInfo(uniquePids, "PatientInfo", "PatientID, DOB", patientPath, conn);
        } catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }

    public static boolean GetDiagnoses(String[] analytes, String[] uniquePids, Connection conn){
        try{
            String diagPath = getDiagnosesPath(analytes);
            return GetAssociatedPidInfo(uniquePids, "DiagnosesComprehensive", "PatientID, EncounterID, Lexicon, TermCodeMapped, TermNameMapped, ProblemID", diagPath, conn);
        } catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }

    public static boolean GetMedications(String[] analytes, String[] uniqueEncs, Connection conn){
        try{
            String medsPath = getMedicationsPath(analytes); 
            return GetAssociatedEncounterInfo(uniqueEncs, "MedicationAdministrationsComprehensive", "PatientID, EncounterID, MedicationTermID, MedicationName, MedicationStatus, DoseStartTime, OrderID", medsPath, conn);
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
			
			//Set the timeout at 10 hours
            cursor.setQueryTimeout(60 * 60 * 10);

            //Run the statment
            rs = cursor.executeQuery();

            //Write the results to an output file
            returnRes = writeResultSetToFile(rs, outputFile, true);
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

    public static String[][] FindUniquePids(String[] analytes){
        try{
			//Check that the final output file is there and ready to go
			String finalOutputFile = getLabResultsPath(analytes);
			File f = new File(finalOutputFile);
			Boolean firstWrite = null;
			BufferedWriter out = null;
			if(f.exists() && !f.isDirectory()) {
				out = new BufferedWriter(new FileWriter(finalOutputFile, true));
				firstWrite = false;
			}
			else{
				out = new BufferedWriter(new FileWriter(finalOutputFile));
				firstWrite = true;
			}
			
			//Setup the input file
			String inputTempFile = finalOutputFile + ".temp";
            BufferedReader br = new BufferedReader(new FileReader(inputTempFile));
			
			//Create the structures for keeping track of new pids & encounters 
            HashMap<String, Integer> hm = new HashMap<String, Integer>();  
            HashMap<String, Integer> hmEnc = new HashMap<String, Integer>();

			Integer curLine = 0;
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
				
				//Write the temp file to the output file
				if((firstWrite && curLine == 0) || (curLine > 0)){
					out.write(line + "\n");
				}
				
				curLine += 1;
            }

			//Close the files paths
            br.close();
			out.close();
			
			//Delete the temp file
			File ftd = new File(inputTempFile);
			ftd.delete();

			//Return the results
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

    public static boolean findCohort(String[] analyte, String sTime, String eTime, Connection conn) throws SQLException {
        if(analyte == null || analyte.length == 0 || sTime == null || eTime == null){
            return false;
        }
				
        //Print some output for debugging
        System.out.println("LabResults: " + String.join(",", analyte));
        
        //Create the temp output file
        String outputFile = getLabResultsPath(analyte) + ".temp";

        //Build the select query 
        String sql = "SELECT ";
		sql += "PatientID, EncounterID, COLLECTION_DATE, ORDER_CODE, ORDER_NAME, RESULT_CODE, ACCESSION_NUMBER, VALUE, UNIT, RANGE ";
		sql += "FROM LabResults WHERE "; 
        
        //This is where you can filter the data range
        sql += "COLLECTION_DATE <= '" + eTime + "' AND COLLECTION_DATE > '" + sTime + "' ";
        
        //This is where you can filter the result codes
        sql += "AND (RESULT_CODE = '" + String.join("' OR RESULT_CODE = '", analyte) + "')";
		
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
}

