#!/bin/bash

######################################################
# Author: Prashanth
# NXP_ID:
# Email ID: prashanth.pradeep@lntinfotech.com
# File Name: monitorLoad.sh
# Purpose: To monitor the processes and files associated with a running load
# Version: 1.0
# Created Date: Thu Dec 13 01:49:49 MST 2018
# Last Modified Date:
# ---------------------------------------------------
# Usage:
#       * MON LoadName
#       * MON TargetTableName
#       * MON LoadName TargetTableName
#       * MON TargetTableName LoadName
# MON stands for Monitor and is the
# alias for monitorLoad.sh
######################################################


# START #

# Set DS Profile
. /local/data1/edw/profile/set_ebi_ds_env

if [ $# -eq 0 ]; then
        echo "*****************************************************************"
        echo "No arguments are provided"
        echo
        echo "------------------------------"
        echo "Use Case: "
        echo "------------------------------"
        echo "MON LoadName [TargetTableName]"
        echo
        echo "*****************************************************************"
        echo ""
        exit 1
fi

loadName=${1}
tableName=${2}

# Check if the arguments are empty
if [ -z "$tableName" ]
then
        testTable=1
else
#       echo "\$tableName is NOT empty"
        table_name_upper=${tableName^^};
        table_name_lower=${tableName,,} ;
        tablePathLower="$TDDATA_ARCHIVE/$table_name_lower/" ;
        tablePathUpper="$TDDATA_ARCHIVE/$table_name_upper/" ;
        testTable=0
fi

if [ -z "$loadName" ]
then
        testLoad=1
else
#       echo "\$tableLoad is NOT empty"
        load_name_upper=${loadName^^};
        load_name_lower=${loadName,,};
        loadPathUpper="$TDDATA_ARCHIVE/$load_name_upper/";
        loadPathLower="$TDDATA_ARCHIVE/$load_name_lower/" ;
        testLoad=0
fi

# echo "Load Name Upper: ${load_name_upper}"
# echo "Table Name Upper: ${table_name_upper}"


# The Following Code displays the Proceses Running
# And the last updated folder

# echo "TestTable : $testTable "
# echo "TestLoad: $testLoad"

if [ "${testTable}" -eq 0 ]; then
        searchFiles="*${load_name_upper}* *${load_name_lower}* *${table_name_upper}* *${table_name_lower}* "
else
        searchFiles="*${load_name_upper}* *${load_name_lower}* "
fi

# echo; ps aux | grep -E '^dwops.+${load_name_upper}|^dwops.+${load_name_lower}|^dwops.+${table_name_upper}|^dwops.+${table_name_lower}|(${table_name_upper})|(${table_name_lower})|(${load_name_lower})|(${load_name_upper})' | grep -v grep

# echo "SearchFilePath: $searchFiles"
# echo "SearchPathEnd"
#grepReg='^dwops.+${load_name_upper}'
# grepReg='^dwops.+${loadName}|^dwops.+${tableName}'

watch -t "

echo; echo "--------------------------------------------------------------------------- Search for files ---------------------------------------------------------------------------"
echo; cd ${PUSH_GBI_DIR};echo -n "Inbound Staging GBI:   "; pwd; ls -l ${searchFiles} 2>/dev/null;
echo; cd ${PUSH_MCP_DIR};echo -n "Inbound Staging FCP:  "; pwd; ls -l ${searchFiles} 2>/dev/null;
echo; cd ${TRIGGER_DIR};echo -n "Trigger Directory: "; pwd; ls -l ${searchFiles}  2>/dev/null;
echo; cd ${STAGING_DIR};echo -n "Working Directory: "; pwd; ls -l ${searchFiles} 2>/dev/null;
echo; echo;
echo; echo "------------------------------------------------------------- Show processes for the load --------------------------------------------------------------------"

if [ "${testTable}" -eq 0 ]; then
        echo; ps aux | grep -E -i '${load_name_upper}|${table_name_upper}' | grep -v grep;
else
        echo; ps aux --sort=-pcpu | grep -E -i '${load_name_upper}' | grep -v grep | head -n 20;
fi
echo; echo;


echo; echo; echo; echo "------------------------------------ Show latest archive directory for the load -------------------------------------------"
echo;
if [ "${testTable}" -eq 0 ]; then
        echo "Searching for ${load_name_upper} and ${table_name_upper} ..............."
        if cd ${loadPathUpper} 2>/dev/null; then
        echo; echo "Found Load: ${load_name_upper}" ;
        echo "Found ${load_name_upper} in: ${loadPathUpper}"
        echo; echo "Latest Load Archive Directory Updated:";
        echo;
        ls -ltr | tail -1 2>/dev/null;
        echo;
        else
                if cd ${loadPathLower} 2>/dev/null; then
                        echo; echo "Found Load: ${load_name_upper}" ;
                        echo "Found ${load_name_upper} in: ${loadPathLower}"
                        echo; echo "Latest Load Archive Directory Updated:";
                        echo;
                        ls -ltr | tail -1 2>/dev/null;
                        flag=1;
                        echo;
                else
                        if cd ${tablePathUpper} 2>/dev/null ; then
                                echo; echo "Found Load: ${table_name_upper}" ;
                                echo "Found ${table_name_upper} in: ${tablePathUpper}"
                                echo; echo "Latest Load Archive Directory Updated:";
                                echo;
                                ls -ltr | tail -1 2>/dev/null;
                                echo;
                        else
                                if cd ${tablePathLower} 2>/dev/null; then
                                        echo; echo "Found Load: ${table_name_upper}" ;
                                        echo "Found ${table_name_upper} in: ${tablePathLower}"
                                        echo; echo "Latest Load Archive Directory Updated:";
                                        echo;
                                        ls -ltr | tail -1 2>/dev/null;
                                        flag=1;
                                        echo;
                                else
                                        echo; echo "Load Not Found"
                                fi
                        fi
                fi
        fi

else
        echo "Searching for ${load_name_upper}"
        if cd ${loadPathUpper} 2>/dev/null; then
                echo; echo "Found Load: ${load_name_upper}" ;
                echo "Found ${load_name_upper} in: ${loadPathUpper}"
                echo; echo "Latest Load Archive Directory Updated:";
                echo;
                ls -ltr | tail -1 2>/dev/null;
                flag=1;
                echo;
        else
                if cd ${loadPathLower} 2>/dev/null; then
                        echo; echo "Found Load: ${load_name_upper}" ;
                        echo "Found ${load_name_upper} in: ${loadPathLower}"
                        echo; echo "Latest Load Archive Directory Updated:";
                        echo;
                        ls -ltr | tail -1 2>/dev/null;
                        echo;
                else
                        echo; echo "Load Not Found"
                fi
        fi
fi

"


# END #
