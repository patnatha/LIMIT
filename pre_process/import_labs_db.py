import os
import sys
import sqlite3
import time
import math
from datetime import datetime, timedelta, date

if(len(sys.argv) != 2):
    print("ERROR CMD LINE OMISSION")
    sys.exit(1)

if(sys.argv[1] == "INSERT"):
    whichProc = "INSERT"
elif(sys.argv[1] == "INDEX"):
    whichProc = "INDEX"
elif(sys.argv[1] == "TIMEIT"):
    whichProc = "TIMEIT"
else:
    print("ERROR CMD LINE INPUT")
    sys.exit(1)

#Edit this line below to upload a text file to a sqlite file
filepath = "/scratch/leeschro_armis/patnatha/LabResults/"
filesupload = []
for tfile in os.listdir(filepath):
    if(os.path.splitext(tfile)[1] == ".txt"):
        filesupload.append(os.path.join(filepath, tfile))
tablename = os.path.basename(os.path.dirname(filepath))    
dbfile = os.path.join(filepath, tablename + ".db")
print(dbfile)

conn = sqlite3.connect(dbfile)
c = conn.cursor()

if(whichProc == "INSERT"):
    for txtfile in filesupload:
        doneWFile = False
        filename = os.path.basename(txtfile)
        ms = time.time()*1000.0

        questArray = []
        toInsert = []
        cnt = 0
        f = open(txtfile)
        for line in f:
            sql = ""
            try:
                #Get the line and remove unecessary characters and then split on tab
                splitline = line.replace("\n", "").split("\t")
                if(cnt == 0):
                    #Create the data table
                    sql = "CREATE TABLE IF NOT EXISTS " + tablename + " (" + (" TEXT, ").join(splitline) + " TEXT)" 
                    c.execute(sql)

                    #Create the uploaded files table
                    sql = "CREATE TABLE IF NOT EXISTS files_uploaded (filename TEXT, status TEXT)"
                    c.execute(sql)
                    conn.commit()

                    #Check the status of the current text file to run
                    sql = "SELECT status FROM files_uploaded WHERE filename = '" + filename + "'"
                    c.execute(sql)
                    txtstatus = c.fetchone()
            
                    #Parse the response of the filename
                    if(txtstatus != None):
                        if(txtstatus[0] == "Done"):
                            print "Skip IT:", filename
                            doneWFile = True
                            break
                    else:
                        sql = "INSERT INTO files_uploaded VALUES('" + filename + "','Started')"
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

        #Skip this file if necessary
        if(doneWFile): continue
        f.close()

        # Insert the last of them
        if(len(toInsert) > 0):
            conn.executemany("INSERT INTO " + tablename + " VALUES (" + (",").join(questArray) + ")", toInsert)
            conn.commit()

        #Set the txt file to Done
        sql = "UPDATE files_uploaded SET status = 'Done' WHERE filename = '" + filename + "'"
        conn.execute(sql)
        conn.commit()
elif(whichProc == "INDEX"):
    print("Indexing")
    sql = "CREATE INDEX pid_key ON " + tablename + "(PatientID);"
    c.execute(sql)
    conn.commit()

    sql = "CREATE INDEX enc_key ON " + tablename + "(EncounterID); "
    c.execute(sql)
    conn.commit()

    sql = "CREATE INDEX results_code_key ON " + tablename + "(RESULT_CODE); "
    c.execute(sql)
    conn.commit()

    sql = "CREATE INDEX hilownormal_flag ON " + tablename + "(HILONORMAL_FLAG); "
    c.execute(sql)
    conn.commit()
elif(whichProc == "TIMEIT"):
    se_exist = False
    for row in c.execute("PRAGMA table_info(" + tablename + ")"):
        if(row[1] == "since_epoch"): se_exist = True
    if(not se_exist):
        print("ADD since_epoch COLUMN")
        sql = "ALTER TABLE " + tablename + " ADD COLUMN since_epoch INTEGER DEFAULT NULL"
        c.execute(sql)
        conn.commit()

    cdk_exist = False
    se_index_exists = False
    for row in c.execute("SELECT name FROM sqlite_master WHERE type='index' ORDER BY name;"):
        if(row[0] == "collection_date_key"): cdk_exist = True
        if(row[0] == "since_epoch_key"): se_index_exists = True

    if(not cdk_exist):
        print("ADD INDEX ON collection_date_key")
        sql = "CREATE INDEX collection_date_key ON " + tablename + "(COLLECTION_DATE);"
        c.execute(sql)
        conn.commit()

    currentIteration = 1

    #Iterate over the entire table day by day
    def daterange(start_date, end_date):
        for n in range(int ((end_date - start_date).days)):
            yield start_date + timedelta(n)
    #start_date = date(2000, 04, 01) # This is constant from table
    start_date = date(2014, 03, 16)
    end_date = date(2017, 11, 26) # This is constant from table
    last_date = None
    for single_date in daterange(start_date, end_date):
        if(last_date == None):
            last_date = single_date.strftime("%Y-%m-%d")
            continue
        current_date = single_date.strftime("%Y-%m-%d")

        #Query a group of collection_dates to update
        stime = time.time()
        sql = "SELECT COLLECTION_DATE, since_epoch FROM LabResults WHERE COLLECTION_DATE >= \"" + last_date + "\" AND COLLECTION_DATE < \"" + current_date + "\""
        toUpdate = list()
        uniqCollDate = dict()
        for row in c.execute(sql):
            #Get the date and convert to datetime object
            coll_date = row[0]
            cse = row[1]
            if(cse == None and coll_date not in uniqCollDate):
                datetimeobj = datetime.strptime(coll_date[:-1], '%Y-%m-%d %H:%M:%S.%f')
                timeSinceEpoch = int(math.floor((datetimeobj - datetime.utcfromtimestamp(0)).total_seconds() / (3600 * 24)))

                uniqCollDate[coll_date] = 1
                toUpdate.append([timeSinceEpoch, coll_date])
    
        #Commit every group
        print "To Update:", len(toUpdate), "records", last_date, "<=>", current_date
        if(len(toUpdate) > 0):
            cup = conn.cursor()
            cup.executemany("UPDATE LabResults SET since_epoch = ? WHERE COLLECTION_DATE = ?", toUpdate)
            conn.commit()
            cup.close()
        print "Updated (", currentIteration, "):", round(time.time() - stime, 2), "secs"

        currentIteration = currentIteration + 1
        last_date = current_date

    print("ADD INDEX ON since_epoch_key")
    if(not se_index_exists):
        sql = "CREATE INDEX since_epoch_key ON " + tablename + "(since_epoch);"
        c.execute(sql)
        conn.commit()

#Close the connection
conn.close()

