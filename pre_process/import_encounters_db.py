import os
import sys
import sqlite3
import time
from datetime import datetime

def compare_str_times(time1, time2):
    dt_1 = datetime.strptime(time1.split(" ")[0], '%Y-%m-%d')
    dt_2 = datetime.strptime(time2.split(" ")[0], '%Y-%m-%d')
    return (dt_1 - dt_2).days

if(len(sys.argv) != 2):
    print("ERROR CMD LINE OMISSION")
    sys.exit(1)

if(sys.argv[1] == "INSERT"):
    whichProc = "INSERT"
elif(sys.argv[1] == "INDEX"):
    whichProc = "INDEX"
elif(sys.argv[1] == "FIND_INPATIENTS"):
    whichProc = "FIND_INPATIENTS"
else:
    print("ERROR CMD LINE INPUT")
    sys.exit(1)

#Edit this line below to upload a text file to a sqlite file
txtfile = "/scratch/leeschro_armis/patnatha/EncountersAll/EncountersAll.txt"
tablename = os.path.basename(os.path.splitext(txtfile)[0])
dbfile = os.path.join(os.path.dirname(txtfile), tablename + ".db")
print(dbfile)

conn = sqlite3.connect(dbfile)
c = conn.cursor()

if(whichProc == "INSERT"):
    c.execute("DROP TABLE IF EXISTS " + tablename)
    conn.commit()

    ms = time.time()*1000.0

    questArray = []
    toInsert = []
    cnt = 0
    f = open(txtfile)
    for line in f:
        sql = ""
        try:
            splitline = line.split("\t")
            if(cnt == 0):
                sql = "CREATE TABLE " + tablename + " (" + (" TEXT, ").join(splitline) + " TEXT)" 
                c.execute(sql)
                conn.commit()
               
                for i in range(0, len(splitline)): questArray.append("?")
            else:
                toInsert.append(splitline)
        except Exception as err:
            print("ERROR")    
            print(err)
            print(sql)
            

        cnt = cnt + 1
        if(cnt % 100000 == 0):
            conn.executemany("INSERT INTO " + tablename + " VALUES (" + (",").join(questArray) + ")", toInsert)
            conn.commit()
            toInsert = []
            timediff = (time.time()*1000.0) - ms
            print(str(cnt) + ": " + str(timediff / 1000.0) + " secs")
            ms = time.time()*1000.0

    # Insert the last of them
    if(len(toInsert) > 0):
        conn.executemany("INSERT INTO " + tablename + " VALUES (" + (",").join(questArray) + ")", toInsert)
        conn.commit()

    f.close()
elif(whichProc == "INDEX"):
    sql = "CREATE INDEX pid_key ON " + tablename + "(PatientID); "
    c.execute(sql)
    conn.commit()

    sql = "CREATE INDEX enc_key ON " + tablename + "(EncounterID); "
    c.execute(sql)
    conn.commit()
elif(whichProc == "FIND_INPATIENTS"):
    tablename = "ever_inpatient"
   
    #Create other table cursor 
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
    ic.close()

    sql = "CREATE INDEX inpatient_cnt_key ON " + tablename + "(InpatientCnt)"
    c.execute(sql)
    conn.commit()

c.close()
conn.close()

