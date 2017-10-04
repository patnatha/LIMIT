import os
import sys
import sqlite3
import time;

if(len(sys.argv) != 2):
    print("ERROR CMD LINE OMISSION")
    sys.exit(1)

if(sys.argv[1] == "INSERT"):
    whichProc = "INSERT"
elif(sys.argv[1] == "INDEX"):
    whichProc = "INDEX"
else:
    print("ERROR CMD LINE INPUT")
    sys.exit(1)

#Edit this line below to upload a text file to a sqlite file
txtfile = "/scratch/leeschro_armis/patnatha/EncountersAll/EncountersAll.txt"
tablename = os.path.basename(os.path.splitext(txtfile)[0])
dbfile = os.path.join(os.path.basename(txtfile), tablename + ".db")
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

conn.close()

