import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.io.Console;
import java.util.Scanner;
import java.util.Properties;
import java.io.FileInputStream;
import java.io.IOException;


public class QuerySql {
    public static void main(String[] args) throws SQLException, IOException {
        //Specify all the variable for connecting to the database
        System.out.println("Welcome to the Sql Database Connector");
        Connection conn = null;
        ResultSet rs = null;
        String url = "jdbc:jtds:sqlserver://rdw-db.med.umich.edu:1433;databaseName=RDW_Views;domain=UMHS;useNTLMv2=true;";
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
            System.out.println("Connected to the database!!! Getting table list...");
           
            //Get a list of all the Views 
            /*DatabaseMetaData dbm = conn.getMetaData();
            rs = dbm.getTables(null, null, "%", new String[] { "VIEW" });
            while (rs.next()) {
                System.out.println(rs.getString(3)); 
            }*/

            //Prepare to execute prepared statement 
            PreparedStatement cursor = conn.prepareStatement("");
             
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            conn.close();
            rs.close();
        }
    }
}

