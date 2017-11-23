import sqlite3
import time
from datetime import datetime

def compare_str_times(time1, time2):
    dt_1 = datetime.strptime(time1.split(" ")[0], '%Y-%m-%d')
    dt_2 = datetime.strptime(time2.split(" ")[0], '%Y-%m-%d')
    return (dt_1 - dt_2).days

dbfile = "/scratch/leeschro_armis/patnatha/EncountersAll/EncountersAll.db"
tablename = "ever_inpatient"

#Connect to database
conn = sqlite3.connect(dbfile)
c = conn.cursor()
ic = conn.cursor()

#Drop the table if already exists
c.execute("DROP TABLE IF EXISTS " + tablename)
conn.commit()

#Create new table to hold results
c.execute("CREATE TABLE " + tablename + " (PatientID TEXT, FirstInpatient TEXT, InpatientCnt INTEGER, FirstED TEXT, EDCnt INTEGER)")
conn.commit()
c.execute("CREATE INDEX pid_key_ei ON " + tablename + " (PatientID)")
conn.commit()

#Stuct to remember pids already found
pids = dict()

cnt = 0
stime = time.time()
for result in c.execute("SELECT PatientID, AdmitDate, PatientClassCode FROM EncountersAll"):
    cnt = cnt + 1
    if(cnt % 100000 == 0):
        tdiff = time.time() - stime
        print cnt, "-", round(tdiff, 2), "secs"
        stime = time.time()

    if(result[0] != None and result[0] != "" and result[1] != None and result[1] != "" \
      and (result[2] == "Inpatient" or result[2] == "Emergency")):
        pid = result[0]
        thedate = result[1]
        thetype = result[2]

        curRec = None
        if(pid not in pids):
            #Create base record if doesn't exist
            ic.execute("INSERT INTO " + tablename + " VALUES (\"" + pid + "\", NULL, 0, NULL, 0)")
            conn.commit()
            curRec = [pid, None, 0, None, 0]
            pids[pid] = 1
        else:
            #Get the PID record
            ic.execute("SELECT * FROM " + tablename + " WHERE PatientID = \"" + pid + "\"")
            curRec = list(ic.fetchone())
            pids[pid] = pids[pid] + 1

        if(thetype == "Inpatient"):
            #Get the most recent date
            if(curRec[1] == None or compare_str_times(curRec[1], thedate) > 0):
                curRec[1] = thedate

            ic.execute("UPDATE " + tablename + " SET FirstInpatient = \"" + curRec[1] + "\", InpatientCnt = " + str(curRec[2] + 1) + " WHERE PatientID = \"" + pid + "\"")
            conn.commit()
        elif(thetype == "Emergency"):
            #Get the most recent date
            if(curRec[3] == None or compare_str_times(curRec[3], thedate) > 0):
                curRec[3] = thedate
 
            ic.execute("UPDATE " + tablename + " SET FirstED = \"" + curRec[3] + "\", EDCnt = " + str(curRec[4] + 1) + " WHERE PatientID = \"" + pid + "\"")
            conn.commit()

c.close()
ic.close()
conn.close()

