import os
import sys
import sqlite3
import time
import math
from datetime import datetime, timedelta, date

if(len(sys.argv) != 2):
    print("ERROR CMD LINE OMISSION")
    print("ERROR: INSERT, INDEX, TIMEIT, TIMEIT_EXT, PREPARE, RC_INSERT, RC_PERMUTE, RC_EDIT")
    sys.exit(1)

if(sys.argv[1] == "INSERT"):
    whichProc = "INSERT"
elif(sys.argv[1] == "RC_INSERT"):
    whichProc = "RC_INSERT"
elif(sys.argv[1] == "RC_PERMUTE"):
    whichProc = "RC_PERMUTE"
elif(sys.argv[1] == "RC_EDIT"):
    whichProc = "RC_EDIT"
elif(sys.argv[1] == "INDEX"):
    whichProc = "INDEX"
elif(sys.argv[1] == "PREPARE"):
    whichProc = "PREPARE"
elif(sys.argv[1] == "TIMEIT"):
    whichProc = "TIMEIT"
elif(sys.argv[1] == "TIMEIT_EXT"):
    whichProc = "TIMEIT_EXT"
else:
    print("ERROR: INSERT, INDEX, TIMEIT, TIMEIT_EXT, RC_INSERT, RC_PERMUTE, RC_EDIT")
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

    pid_key_exists = False
    enc_key_exists = False
    resc_key_exists = False
    hlnf_key_exists = False
    pid_hlnf_key_exists = False
    rc_hlnf_key_exists = False
    pid_rc_hlnf_key_exists = False
    for row in c.execute("SELECT name FROM sqlite_master WHERE type='index' ORDER BY name;"):
        if(row[0] == "pid_key"): pid_key_exists = True
        if(row[0] == "enc_key"): enc_key_exists = True
        if(row[0] == "results_code_key"): resc_key_exists = True
        if(row[0] == "hilownormal_flag"): hlnf_key_exists = True
        if(row[0] == "pid_hlnf_key"): pid_hlnf_key_exists = True
        if(row[0] == "rc_hlnf_key"): rc_hlnf_key_exists = True
        if(row[0] == "pid_rc_hlnf_key"): pid_rc_hlnf_key_exists = True

    if(not pid_key_exists):
        sql = "CREATE INDEX pid_key ON " + tablename + "(PatientID);"
        c.execute(sql)
        conn.commit()

    if(not enc_key_exists):
        sql = "CREATE INDEX enc_key ON " + tablename + "(EncounterID); "
        c.execute(sql)
        conn.commit()

    if(not resc_key_exists):
        sql = "CREATE INDEX results_code_key ON " + tablename + "(RESULT_CODE); "
        c.execute(sql)
        conn.commit()

    if(not hlnf_key_exists):
        sql = "CREATE INDEX hilownormal_flag ON " + tablename + "(HILONORMAL_FLAG); "
        c.execute(sql)
        conn.commit()

    if(not pid_hlnf_key_exists):
        sql = "CREATE INDEX pid_hlnf_key ON " + tablename + "(PatientID, HILONORMAL_FLAG)"
        c.execute(sql)
        conn.commit()

    if(not rc_hlnf_key_exists):
        sql = "CREATE INDEX rc_hlnf_key ON " + tablename + "(RESULT_CODE, HILONORMAL_FLAG)"
        c.execute(sql)
        conn.commit()

    if(not pid_rc_hlnf_key_exists):
        sql = "CREATE INDEX pid_rc_hlnf_key ON " + tablename + "(PatientID, RESULT_CODE, HILONORMAL_FLAG)"
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
elif(whichProc == "TIMEIT_EXT"):
    stime = time.time()
    sql = "SELECT COLLECTION_DATE, since_epoch FROM LabResults WHERE since_epoch IS NULL"
    toUpdate = list()
    uniqCollDate = dict()
    for row in c.execute(sql):
        coll_date = row[0]
        cse = row[1]
        if(cse == None and coll_date not in uniqCollDate):
            datetimeobj = datetime.strptime(coll_date[:-1], '%Y-%m-%d %H:%M:%S.%f')
            timeSinceEpoch = int(math.floor((datetimeobj - datetime.utcfromtimestamp(0)).total_seconds() / (3600 * 24)))

            uniqCollDate[coll_date] = 1
            toUpdate.append([timeSinceEpoch, coll_date])

    #Commit the whole group
    print "To Update:", len(toUpdate), "records"
    if(len(toUpdate) > 0):
        c = conn.cursor()
        c.executemany("UPDATE LabResults SET since_epoch = ? WHERE COLLECTION_DATE = ?", toUpdate)
        conn.commit()
    print "Updated (since_epoch IS NULL):", round(time.time() - stime, 2), "secs"

    sql = "CREATE INDEX since_epoch_result_code_key ON " + tablename + "(RESULT_CODE, since_epoch);"
    c.execute(sql)
    conn.commit()
    c.close()
elif(whichProc == "RC_INSERT"):
    filename = "RESULT_CODES.txt"
    thefile = os.path.join(filepath, filename)
    tablename = (filename.split(".")[0]).lower()
    print(thefile + " => " + tablename)
    
    f = open(thefile)
    for linenum, line in enumerate(f):
        line = line.replace("\"","").rstrip('\n').rstrip('\r')
        splitline = line.split('\t')
        if(len(splitline) == 3):
            if(linenum == 0):
                c.execute("DROP TABLE IF EXISTS " + tablename)
                c.execute("CREATE TABLE " + tablename + " (RESULT_CODE TEXT, RESULT_NAME TEXT, RESULT_COUNT INTEGER)")
                conn.commit()
            else:
                c.execute("INSERT INTO " + tablename + " VALUES (\"" + ("\",\"").join(splitline) + "\")")
        else:
            print(line)
    f.close()

    sql = "CREATE INDEX results_code_rc_key ON " + tablename + "(RESULT_CODE)"
    c.execute(sql)
    conn.commit()
    c.close()
elif(whichProc == "RC_PERMUTE"):
    #Create result table
    createsql = "CREATE TABLE IF NOT EXISTS similar_result_codes (RESULT_CODE TEXT, RESULT_NAME TEXT, similar_result_code TEXT, similar_result_name TEXT, valid TEXT)"
    c.execute(createsql)
    createsql = "CREATE INDEX IF NOT EXISTS result_codes_similar_key ON " + tablename + " (RESULT_CODE)"
    c.execute(createsql)
    createsql = "CREATE INDEX IF NOT EXISTS result_codes_valid_similar_key ON " + tablename + " (RESULT_CODE, valid)"
    c.execute(createsql)
    conn.commit()

    #Get list of result_codes already run
    sql = "SELECT RESULT_CODE FROM similar_result_codes"
    alreadyRun = dict()
    for row in c.execute(sql):
        if(row[0] not in alreadyRun):
            alreadyRun[row[0]] = 1
        else:
            alreadyRun[row[0]] = alreadyRun[row[0]] + 1

    #Query all the result_codes from the table
    sql = "SELECT RESULT_CODE, RESULT_NAME FROM result_codes"
    cc = conn.cursor()
    similarDict = dict()
    resultNameDict = dict()
    origtbllen = 0
    for row in c.execute(sql):
        # For each result_code query for similar results
        rc = row[0]
        rn = row[1]
        resultNameDict[rc] = rn
        if(rc not in alreadyRun):
            sql = "SELECT RESULT_CODE FROM result_codes WHERE RESULT_CODE LIKE \"%" + rc + "%\" OR RESULT_NAME LIKE \"%" + rc + "%\""
            similarList = list()
            for frc in cc.execute(sql):
                similarList.append(frc[0])
        
            if(rc not in similarDict):
                similarDict[rc] = similarList
                origtbllen = origtbllen + 1
            else:
                print(rc, "already exists", similarDict[rc], "=", similarList)
    cc.close()

    #Insert the results into the new table
    newtbllen = 0
    for result_code in similarDict:
        result_name = resultNameDict[result_code]
        for simcode in similarDict[result_code]:
            simname = resultNameDict[simcode]
            sql = 'INSERT INTO similar_result_codes VALUES("' + result_code + '","' + result_name + '","'+ simcode + '","' + simname + '","enabled")'
            c.execute(sql)
            newtbllen = newtbllen + 1

    #Commit the results and print out some info
    print(str(origtbllen) + " => " + str(newtbllen))
    conn.commit()
    c.close()
elif(whichProc == "RC_EDIT"):
    chooseFxn = None
    choosenResult = None
    enabled = list()
    disabled = list()
    while(True):
        if(choosenResult == None):
            choosenResult = raw_input("Which RESULT_CODE to inspect: ").upper()
            sql = "SELECT * FROM similar_result_codes WHERE RESULT_CODE = \"" + choosenResult + "\""
            for row in c.execute(sql):
                if(row[4] == "enabled"):
                    enabled.append(row)
                elif(row[4] == "disabled"):
                    disabled.append(row)
            
            if(len(enabled) + len(disabled) == 0):
                print("ERROR: invalid RESULT_CODE...try again!", choosenResult)
                choosenResult = None
                chooseFxn = None
        elif(choosenResult != None):
            print("================" + choosenResult + "================")
            print("================Enabled================")
            index = 0
            for index, row in enumerate(enabled):
                print(str(index + 1) + " - (" + row[0] + "): " + row[2] + ", " + row[3])

            if(len(disabled) > 0):
                print("================Disabled================")
                for index, row in enumerate(disabled):
                    print(str(index + 1) + " - (" + row[0] + "): " + row[2] + ", " + row[3])
        
            if(chooseFxn == None):
                chooseFxn = raw_input("Which function [enable|disable]: ")
                if(chooseFxn == "enable"):
                    chooseFxn = "enabled"
                elif(chooseFxn == "disable"):
                    chooseFxn = "disabled"
                elif(chooseFxn == "quit" or chooseFxn == "exit"):
                    chooseFxn = None
                    choosenResult = None
                    enabled = list()
                    disabled = list()
                    continue
                else:
                    print("ERROR: invalid function [enable|disable]...try again!")
                    chooseFxn = None
            else:
                whichNum = raw_input(chooseFxn + ", choose number: ")
                if(whichNum == "quit" or whichNum == "exit"):
                    chooseFxn = None
                    choosenResult = None
                    enabled = list()
                    disabled = list()
                    continue

                try:
                    whichNum = int(whichNum)
                except Exception as ex:
                    print(ex)
                    whichNum = None

                if(whichNum != None and whichNum > 0):
                    simrescode = None
                    sql = "UPDATE similar_result_codes SET valid = ? WHERE RESULT_CODE = ? AND similar_result_code = ?"
                   
                    successUpdate = True
                    rowmove = None
                    if(chooseFxn == "disabled" and whichNum <= len(enabled)):
                        try:
                            rowmove = enabled[whichNum - 1]
                            simrescode = rowmove[2]
                            c.execute(sql, (chooseFxn, choosenResult, simrescode))
                            conn.commit()
                        except Exception as ex:
                            print(ex)
                            successUpdate = False
                    
                        if(successUpdate):
                            del enabled[whichNum - 1]
                            disabled.append(rowmove)
                    elif(chooseFxn == "enabled" and whichNum <= len(disabled)):
                        try:
                            rowmove = disabled[whichNum - 1]
                            simrescode = rowmove[2]
                            c.execute(sql, (chooseFxn, choosenResult, simrescode))
                            conn.commit()
                        except Exception as ex:
                            print(ex)
                            successUpdate = False
                
                        if(successUpdate):
                            del disabled[whichNum - 1]
                            enabled.append(rowmove)
    c.close()
elif(whichProc == "PREPARE"):
    analytes = sys.argv[2]
    for analyte in analytes.split(','):
        print "Downloading: " + analyte
        sql = "SELECT * LabResults WHERE "

#Close the connection
conn.close()

