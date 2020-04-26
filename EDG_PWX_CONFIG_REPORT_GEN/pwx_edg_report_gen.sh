#!/bin/bash

#*********************************************************************************#
# Author: Prashanth Pradeep                                                       #
# Purpose: To collect and generate EDG Platform report                            #
# Methods:                                                                        #
# Sun Apr 26 03:35:28 EDT 2020                                                    #
#*********************************************************************************#



#----------------------------------------------------------------------------------------------------------#
#                                   Global Varibles used throught the script                               #
#----------------------------------------------------------------------------------------------------------#
configFile="$(pwd)/config/sampleconfig.cfg"
userName='<userID>'
parseDetailLogScript="$(pwd)/scripts/parseDetailLog.sh"
resultFilePath="$(pwd)/output"
resultFileName="EDG_REPORT_$(date +%d%m%y_%H%M%S).csv"
resultFile="$resultFilePath/$resultFileName"


#----------------------------------------------------------------------------------------------------------#
#                       Use this function to fetch data from logger detail.log                             #
#                'RESULT' is a global return variable which is then parsed in the main fun                 #
#----------------------------------------------------------------------------------------------------------#

parseDetailLog() {
    SERVER=$1
    outputFileName=$2
    ERPNAME=$3
    ENVNAME=$4
    cat $parseDetailLogScript | ssh ${userName}@${SERVER} > ${outputFileName}
    # RESULT="${DBNAME},${DBVERSION},${PWXVERSION},${OSVERSION},${TIMESTAMP},${COLDSTART},${CONDENSEFILERETENTION},${CCLPARM_AGEOUT},${CCLPARM_ROWID}"
    local DBNAMEFROMSCRIPT=$( cat ${outputFileName} | awk -F, '{ print $1 }') 
    local DBVERSION=$( cat ${outputFileName} | awk -F, '{ print $2 }')
    local PWXVERSION=$( cat ${outputFileName} | awk -F, '{ print $3 }') 
    local OSVERSION=$( cat ${outputFileName} | awk -F, '{ print $4 }') 
    local TIMESTAMP=$( cat ${outputFileName} | awk -F, '{ print $5 }') 
    local COLDSTART=$( cat ${outputFileName} | awk -F, '{ print $6 }')
    local CONDENSEFILERETENTION=$( cat ${outputFileName} | awk -F, '{ print $7 }') 
    local CCLPARM_AGEOUT=$( cat ${outputFileName} | awk -F, '{ print $8 }')
    local CCLPARM_ROWID=$( cat ${outputFileName} | awk -F, '{ print $9 }') 
    RESULT="${ERPNAME},${ENVNAME},${DBNAMEFROMSCRIPT},${SERVER},${DBVERSION},${PWXVERSION},${OSVERSION},${TIMESTAMP},${COLDSTART},${CONDENSEFILERETENTION},${CCLPARM_AGEOUT},${CCLPARM_ROWID}"
}


#------------------------------------------------------------------------------------------------------------#
#                            We are creating the csv file with the headers in this step                      #
#                         Add more parameters here as per requirement and expand the code                    #
#------------------------------------------------------------------------------------------------------------#

echo "ERP_NAME,ENV_NAME,DB_NAME,SERVER,DB_VERSION,PWX_VERSION,OS_VERSION,Latest_Timestamp_of_Logger_Restart,Type_of_Restart,Condense_File_Retention,AGEOUT_PARAMETER, ROWID_PARAMETER" > ${resultFile}


#---------------------------------------------------------------------------------------------------------------------#
#                       We are looping through the configuration file with the server details                         #
#   As of now we are reading and genrating report only from the logger logs, add in more logic as per requirement     #
#---------------------------------------------------------------------------------------------------------------------#
while IFS=, read -r ERPNAME ENVNAME DBNAME SERVER 
do
    echo "Processing ${ERPNAME} ${ENVNAME} ${DBNAME}"
    outputFileName="$(pwd)/output/output_${SERVER}_${ERPNAME}.txt"
    echo $outputFileName
    parseDetailLog $SERVER $outputFileName $ERPNAME $ENVNAME
    echo $RESULT >> ${resultFile}
    echo "DBNAME :  ${DBNAMEFROMSCRIPT}"
done < $configFile


#-------------------------------------------------------------------------------------------------------------#
#                         Hurray! Final step, we are sending the report generated.                            #
#-------------------------------------------------------------------------------------------------------------#
echo "Sending mail ....."
echo "Test mail.." | mailx -s "${resultFileName}" -a ${resultFile} "<my_mail_id>"
echo "File: ${resultFile} has been sent"

