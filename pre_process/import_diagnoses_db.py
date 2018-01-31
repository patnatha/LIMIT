import os
import sys
import sqlite3
import time

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
filepath = "/scratch/leeschro_armis/patnatha/DiagComp/"
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
    
    pid_key_exists = False
    enc_key_exists = False
    term_map_key_exists = False
    pid_term_map_key_exists = False
    for row in c.execute("SELECT name FROM sqlite_master WHERE type='index' ORDER BY name;"):
        if(row[0] == "pid_key"): pid_key_exists = True
        if(row[0] == "enc_key"): enc_key_exists = True
        if(row[0] == "term_map_key"): term_map_key_exists = True     
        if(row[0] == "pid_term_map_key_exists"): pid_term_map_key_exists = True

    if(not pid_key_exists):
        sql = "CREATE INDEX pid_key ON " + tablename + "(PatientID)"
        c.execute(sql)
        conn.commit()

    if(not enc_key_exists):
        sql = "CREATE INDEX enc_key ON " + tablename + "(EncounterID)"
        c.execute(sql)
        conn.commit()

    if(not term_map_key_exists):
        sql = "CREATE INDEX term_map_key ON " + tablename + "(TermCodeMapped)"
        c.execute(sql)
        conn.commit()

    if(not pid_term_map_key_exists):
        sql = "CREATE INDEX pid_term_map_key ON " + tablename + "(PatientID, TermCodeMapped)"
        c.execute(sql)
        conn.commit()
conn.close()

