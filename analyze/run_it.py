import sys
import sqlite3
filepath="/scratch/leeschro_armis/patnatha/limit_results/tune_up/outpatient/random/analysis_results_joined.csv"

dbfile="/scratch/leeschro_armis/patnatha/ReferenceIntervals/ReferenceIntervals.db"
conn = sqlite3.connect(dbfile)
c = conn.cursor()

uniqueParams = dict()

f = open(filepath)
cnt = 0
for line in f:
    splitline=line.split(",")
    cnt = cnt + 1
    if(cnt == 1): continue

    splitline=line.split(",")
    result_code = splitline[1]
    sex = splitline[3]
    race = splitline[4]
    start = splitline[5]
    end = splitline[6]
    source = "CALIPER"
    

    sql = "SELECT limit_type, limit_value FROM ReferenceIntervals WHERE (limit_type = 'upper' OR limit_type = 'lower') AND result_code = '" + result_code + "' AND sex='" + sex + "' AND low_age <= " + start + " AND high_age >= " + end + " AND race = '" + race + "' AND source='" + source + "'"
    upper=None
    lower=None
    for row in c.execute(sql):
        if(row[0] == "lower"):
            lower = row[1]
        elif(row[0] == "upper"):
            upper = row[1] 

    #Figure out divisior
    divisior = 0
    if(upper != None and lower != None):
        divisior = 2.0
    elif(upper != None or lower != None):
        divisior = 1.0
    if(divisior == 0): continue


    #Caclulate the total score
    if(splitline[19] == "NA"):
        riLower = None
    else:
        riLower = float(splitline[19])

    if(splitline[20] == "NA"):
        riUpper = None
    else:
        riUpper = float(splitline[20])
    
    if(riLower == None and riUpper == None):
        continue

    totalScore = 0 
    if(riUpper != None and upper != None):
        totalScore = totalScore + abs(upper - riUpper) / upper
    if(riLower != None and lower != None):
        totalScore = totalScore + abs(lower - riLower) / lower
    totalScore = totalScore / divisior

    #Keep track
    limitParams = splitline[8]
    if(limitParams not in uniqueParams):
        uniqueParams[limitParams] = [(totalScore)]
    else:
        uniqueParams[limitParams].append((totalScore))

    #if(limitParams == "H0_P0.05_PROP0.01_POST180_PRE0"):
    #    print(riLower, riUpper, lower, upper, totalScore, uniqueParams[limitParams])

    #Print some output for listening
    if(cnt % 100 == 0):
        print(cnt)

    #if(cnt == 3000):
    #    break

c.close()
conn.close()
f.close()

minsum=1000000
f = open("output.csv", "w")
f.write("limit_params, count, sum\n")
for key in uniqueParams:
    f.write(key + "," + str(len(uniqueParams[key])))
    thesum = sum(uniqueParams[key])
    if(len(uniqueParams[key]) == 6 and thesum < minsum): minsum = thesum
    f.write("," + str(thesum))
    f.write("\n")

f.close()

print("MIN: " + str(minsum))

