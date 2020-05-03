#!/bin/bash


#*********************************************************************************#
# Author: Prashanth Pradeep                                                       #
# Purpose: To parse through detail.log file in ccllog                             #
# Methods: checkNumberOfColdStart,getStartingPointToParse                         #
# Sun Apr 26 03:35:28 EDT 2020                                                    #
#*********************************************************************************#

PWX_HOME='/informatica/pwx_install'
CCLLOGS="${PWX_HOME}/ccllog"
cd ${CCLLOGS}
DETAIL_LOG="${CCLLOGS}/detail.log"

#----------------------------------------------------------------------------------------------------#
# Global Variables used throughout the script                                                        #
# DO NOT REMOVE THESE VARIABLES                                                                      #
# These are return variables which can be used for parsing the detail.log                            #
# example use: tail -${maxRange} detail.log | grep "parameter to be searched"                        #
# this is the range of the latest coldstart which was performed                                      #
#----------------------------------------------------------------------------------------------------#
maxRange=0
minRange=0

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Staging Global variables used in functions, do not delete       #
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
I=0
numberOfLinesDetailLog=$(wc -l ${DETAIL_LOG} | awk '{ print $1 }')


#------------------------------------------------------------------------------------------------------#
# return 0 indicates that the function is executed successfully                                        #
#------------------------------------------------------------------------------------------------------#
# This function will check the number of coldstart=Y/N in range(maxLineNumber,minLineNumber)           #
# while calling the function use the following syntax                                                  #
# checkNumberOfColdStart /path/to/detail.log maxLineNumber minLineNumber                               #
# Function - 0: checkNumberOfColdStart                                                                 #
#------------------------------------------------------------------------------------------------------#
checkNumberOfColdStart() {
    
    local fileName=$1
    local max=$2
    local min=$3
    local headVal=$(($max-$min))
    
    I=$(tail -${max} ${fileName} | head -${headVal} | grep -a -i 'coldstart' | wc -l)
    
    if [[ $I -ge 0 ]];then
        return 0
    else
        return -1
    fi
}

#------------------------------------------------------------------------------------------------------#
# This function returns the starting point for us from where we can start parsing detail.log           #
# function uses binary search to find the latest logger restart details                                #
# This function has two return variables: $maxRange and $minRange                                      #
# tail -${maxRange} detail.log | grep "pwx parameter to be searched"                                   #
# Function - 1: getStartingPointToParse                                                                #
#------------------------------------------------------------------------------------------------------#
getStartingPointToParse () {
    # declaring variables used in this function
    local max=$((numberOfLinesDetailLog))
    local min=0
    local tempMid=0

    while [[ ${min} -lt ${max} ]]; do
        local mid=$(( ${min} + ((${max} - ${min})/2) ))
        # echo "Mid: ${mid}"
        checkNumberOfColdStart ${DETAIL_LOG} ${mid} ${min}

        if [[ ${I} -eq 1 ]]; then
        # echo "Checking number of coldstart from $mid to $min and found it is Equal to 1..."
        
            if [[ $(( ${max} - ${min} )) -gt 250 ]]; then
                tempMid=$(( ${min} + ((${mid} - ${min})/2) ))
                # echo "in greater than 250..." 
                checkNumberOfColdStart ${DETAIL_LOG} $tempMid $min
               
                if [[ ${I} -eq 1 ]]; then 
                    max=$tempMid
                else
                    min=$tempMid 
                fi
            else
                # echo "Range Found.. hurray!!!" 
                # echo "New MAX: ${max} New MIN: ${min}"
                # returning gloabal variables

                startingPointRangeResult="Latest Coldstart=y/n found between Start Range: ${max} to End Range: ${min}"
                maxRange=$mid
                minRange=$min
                return 0
            fi 
        elif [[ ${I} -lt 1 ]]; then
            # echo "Checking number of coldstart from range $mid to $min and less than 1 coldstart found.."
            checkNumberOfColdStart ${DETAIL_LOG} $max $mid
            
            if [[ ${I} -gt 0 ]]; then
                min=$mid
            else
                echo "coldstart not found.."
                break
            fi
        elif [[ ${I} -gt 1 ]]; then
            # echo "if number of coldstart in range $mid to $min greater than 1......"
            tempMid=$(( ${min} + ((${mid} - ${min})/2) ))
            checkNumberOfColdStart ${DETAIL_LOG} $tempMid $min
            
            if [[ $I -gt 0 ]]; then
                max=$tempMid
            else
                min=$tempMid
            fi
        else
            echo "check if os supports the commands.."
            break
        fi
    done
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Calling driver function to get starting point from where we can start parsing the detail.log        #
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
getStartingPointToParse
#-----------------------------------------------------------------------------------------------------#
# return values are $maxRange and $minRange                                                           #
# the latest coldstart is within this range                                                           #
# echo "maxRange: ${maxRange} minRange: ${minRange}"                                                  #
#-----------------------------------------------------------------------------------------------------#




#-----------------------------------------------------------------------------------------------------#
# The following are the parameters we are grepping for:                                               #
# timestamp: the latest timestamp of the logger restart                                               #
# coldstart: captures the type of logger restart: warm/cold                                           #
# AGEOUT: The current value of the ageout parameter as in pwxccl.cfg file                             #
# ROWID: Captures the current value of ROWID in pwxccl.cfg                                            #
# DBNAME: Captures the name of the oracle database                                                    #
# OS_VERSION: Caputres the OS of the ERP Platform                                                     #     
# PWX Version: Capures the Informatica PowerExchange version of our platform,                         #
#              Including the EBF Version                                                              #
# Condense_File_Retention_Period: The retention period of the condense files                          #
#                                                                                                     #
#-----------------------------------------------------------------------------------------------------#
# ALL THE ABOVE VARIABLES ARE WRAPPED TO A RESULT VARIABLE AND RETURNED TO THE MAIN PROGRAM           #
#-----------------------------------------------------------------------------------------------------#

TIMESTAMP=$(tail -${maxRange} detail.log | grep -a -i 'Controller: Started' | awk '{ print $(NF-1),$NF }')
COLDSTART=$(tail -${maxRange} detail.log | grep -a -i 'coldstart' | awk '{ print $NF }')
CCLPARM_AGEOUT=$(tail -${maxRange} detail.log | grep -a -i 'ageout' | awk '{ print $NF }')
CCLPARM_ROWID=$(tail -${maxRange} detail.log | grep -a -i 'rowid' | awk '{ print $NF }')
DBNAME=$(tail -${maxRange} detail.log | grep -a -i 'Info: Oracle database' | grep -a -i 'version is' | awk '{ print $(NF-2) }' )
DBVERSION=$(tail -${maxRange} detail.log | grep -a -i 'OCI Info: OCI client version' | awk '{ print $NF }' )
# tail -${maxRange} detail.log | grep -a -i 'ORAD Info: Connecting to Oracle' 
OSVERSION=$(tail -${maxRange} detail.log | grep -a -i 'ORAD Info: Database platform name' | awk '{ print $(NF-1),$NF }')
# tail -${maxRange} detail.log | grep -a -i 'Info: Oracle database' 
PWXVERSION=$(tail -${maxRange} detail.log | grep -a -i 'PWX-00607 PWXCCL VRM'  | awk '{ print $(NF-2),$NF }')
CONDENSEFILERETENTION=$(tail -${maxRange} detail.log | grep -a -i 'COND_CDCT_RET_P' | awk '{ print $NF }')  
RESULT="${DBNAME},${DBVERSION},${PWXVERSION},${OSVERSION},${TIMESTAMP},${COLDSTART},${CONDENSEFILERETENTION},${CCLPARM_AGEOUT},${CCLPARM_ROWID}"

echo $RESULT
 
