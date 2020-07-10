######################################################################
# Author: Prashanth
# Created on: Thu Jul  2 07:21:33 EDT 2020
# Purpose: To Generate Status Report of Publisher
######################################################################

# Global Variable Definition
export EMAIL_TIMESTAMP=`date '+%d-%b-%Y %H:%M:%S'`
export HTML_TIMESTAMP=`date '+%d%m%Y_%H%M%S'`
export BASE_DIR=/apps/Admin_Scripts/NODE_OUTAGE_LOGGING/xcode/pub_status_report
# Derived Paths
export CONFIG_DIR=${BASE_DIR}/Config
export TEMPLATE_DIR=${BASE_DIR}/Templates
export ALERT_EMAILS=${BASE_DIR}/ALERT_EMAILS
# Config Files and template FIles
export MON_CONFIG_FILE=${CONFIG_DIR}/pub_status_cfg_PROD.cfg
export HEADER_TEMPLATE_01=${TEMPLATE_DIR}/header1.html
export HEADER_TEMPLATE_02=${TEMPLATE_DIR}/header2.html
export TABLE_TEMPLATE=${TEMPLATE_DIR}/table_prod.html
export FOOTER_TEMPLATE=${TEMPLATE_DIR}/footer.html
export CLOSING_TEMPLATE=${TEMPLATE_DIR}/closing.html
export ALERT_FILE_NAME=${ALERT_EMAILS}/PWXPUB_REPORT_${HTML_TIMESTAMP}.html

# Notification Mail List
# To Email ID
export EMAIL_NOTIFY1=
export EMAIL_NOTIFY2=

# CC Email ID
export EMAIL_NOTIFY3=
export EMAIL_NOTIFY4=

# Send Mail to Team

#########################
# FUNCTION VARIABLES    #
#########################
export TABLE_COUNT
export PUB_ENV
export FAILED_INSTANCE_NAME=()
export COUNT_FAILED=0

#########################
# ASPAC VARIABLES       #
#########################
export ASPAC_PROD_COUNT=0
export ASPAC_PROD_PUB_ENV=()
export ASPAC_PROD_PUB_LIVE_FLAG=()
export ASPAC_PROD_SSH_UID=()
export ASPAC_PROD_SSH_SERVER=()
export ASPAC_PROD_PUB_INSTANCE_NAME=()
export ASPAC_PROD_PUB_COUNT_RESULT=()
export ASPAC_PROD_PUB_LIVE=()
export ASPAC_PROD_PUB_STATUS=()
#########################
# NA VARIABLES          #
#########################
export NA_PROD_COUNT=0
export NA_PROD_PUB_ENV=()
export NA_PROD_PUB_LIVE_FLAG=()
export NA_PROD_SSH_UID=()
export NA_PROD_SSH_SERVER=()
export NA_PROD_PUB_INSTANCE_NAME=()
export NA_PROD_PUB_COUNT_RESULT=()
export NA_PROD_PUB_LIVE=()
export NA_PROD_PUB_STATUS=()
#########################
# EMEA VARIABLES        #
#########################
export EMEA_PROD_COUNT=0
export EMEA_PROD_PUB_ENV=()
export EMEA_PROD_PUB_LIVE_FLAG=()
export EMEA_PROD_SSH_UID=()
export EMEA_PROD_SSH_SERVER=()
export EMEA_PROD_PUB_INSTANCE_NAME=()
export EMEA_PROD_PUB_COUNT_RESULT=()
export EMEA_PROD_PUB_LIVE=()
export EMEA_PROD_PUB_STATUS=()

#################################################
# Driver Code                                   #
#################################################
main() {
    printstar
    read_config_file
    # display_config_file
    printstar
    ssh_to_check_pub_status
    printstar
    generate_html_table
    printstar
    consolidate_html_template
    printstar
    send_html_to_team
}

#################################################
# Main Methods                                  #
#################################################


read_config_file() {
    echo -e "$(timestamp):\tReading Configuration File."
    while IFS= read -r RECLINE
    do
        PUB_ENV=`echo ${RECLINE} | cut -d":" -f1 | cut -d"=" -f2`
        export PROD_PUB_LIVE_FLAG=`echo ${RECLINE} | cut -d":" -f2 | cut -d"=" -f2`
        if [ ${PROD_PUB_LIVE_FLAG} -eq 1 ]; then
            store_data_region_wise ${PUB_ENV} ${RECLINE}  
        fi      
    done < ${MON_CONFIG_FILE}
    # FETCH TABLE_COUNT
    greatest_count_of_regions
}

ssh_to_check_pub_status() {
    # Check NA Status
    na_ssh_to_check_pub_status
    aspac_ssh_to_check_pub_status
    emea_ssh_to_check_pub_status
}

generate_html_table() {
    echo -e "$(timestamp):\tGenerating HTML TABLE.."
    echo -e "\n\n<!-- TABLE DATA POPULATED AT: $(timestamp) -->" > ${TABLE_TEMPLATE}
    for(( i=0; i<${TABLE_COUNT}; i++ ))
    do
        if [ "${NA_PROD_PUB_LIVE_FLAG[$i]}" != "" ] && [ ${NA_PROD_PUB_LIVE_FLAG[$i]} -eq 1 ] && [ ${NA_PROD_PUB_COUNT_RESULT[$i]} -eq 0 ]; then
                FAILED_INSTANCE_NAME[${COUNT_FAILED}]="${NA_PROD_PUB_INSTANCE_NAME[$i]}"
                COUNT_FAILED=$((${COUNT_FAILED}+1))
                NA_DATA="<td bgcolor=\"#F8CBAD\">${NA_PROD_PUB_INSTANCE_NAME[$i]}</td><td bgcolor=\"#F8CBAD\">${NA_PROD_PUB_LIVE[$i]}</td><td bgcolor=\"#F8CBAD\">${NA_PROD_PUB_STATUS[$i]}</td>"
        else
            NA_DATA="<td>${NA_PROD_PUB_INSTANCE_NAME[$i]}</td><td>${NA_PROD_PUB_LIVE[$i]}</td><td>${NA_PROD_PUB_STATUS[$i]}</td>"
        fi
        if [ "${EMEA_PROD_PUB_LIVE_FLAG[$i]}" != "" ] && [ ${EMEA_PROD_PUB_LIVE_FLAG[$i]} -eq 1 ] && [ ${EMEA_PROD_PUB_COUNT_RESULT[$i]} -eq 0 ]; then
                FAILED_INSTANCE_NAME[${COUNT_FAILED}]="${EMEA_PROD_PUB_INSTANCE_NAME[$i]}"
                COUNT_FAILED=$((${COUNT_FAILED}+1))
                EMEA_DATA="<td bgcolor=\"#F8CBAD\">${EMEA_PROD_PUB_INSTANCE_NAME[$i]}</td><td bgcolor=\"#F8CBAD\">${EMEA_PROD_PUB_LIVE[$i]}</td><td bgcolor=\"#F8CBAD\">${EMEA_PROD_PUB_STATUS[$i]}</td>"
        else
            EMEA_DATA="<td>${EMEA_PROD_PUB_INSTANCE_NAME[$i]}</td><td>${EMEA_PROD_PUB_LIVE[$i]}</td><td>${EMEA_PROD_PUB_STATUS[$i]}</td>"
        fi
        if [ "${ASPAC_PROD_PUB_LIVE_FLAG[$i]}" != "" ] && [ ${ASPAC_PROD_PUB_LIVE_FLAG[$i]} -eq 1 ] && [ ${ASPAC_PROD_PUB_COUNT_RESULT[$i]} -eq 0 ]; then
                FAILED_INSTANCE_NAME[${COUNT_FAILED}]="${ASPAC_PROD_PUB_INSTANCE_NAME[$i]}"
                COUNT_FAILED=$((${COUNT_FAILED}+1))
                ASPAC_DATA="<td bgcolor=\"#F8CBAD\">${ASPAC_PROD_PUB_INSTANCE_NAME[$i]}</td><td bgcolor=\"#F8CBAD\">${ASPAC_PROD_PUB_LIVE[$i]}</td><td bgcolor=\"#F8CBAD\">${ASPAC_PROD_PUB_STATUS[$i]}</td>"
        else
            ASPAC_DATA="<td>${ASPAC_PROD_PUB_INSTANCE_NAME[$i]}</td><td>${ASPAC_PROD_PUB_LIVE[$i]}</td><td>${ASPAC_PROD_PUB_STATUS[$i]}</td>"
        fi
        echo -e "<tr>\n" >> ${TABLE_TEMPLATE}
        echo -e "\t${NA_DATA}\n\t${EMEA_DATA}\n\t${ASPAC_DATA}" >> ${TABLE_TEMPLATE}
        echo -e "</tr>\n" >> ${TABLE_TEMPLATE}
    done
    echo -e "$(timestamp):\tHTML Table has been created."

}

consolidate_html_template() {
    echo -e "$(timestamp):\tConsolidating HTML Template"
    cat ${HEADER_TEMPLATE_01} > ${ALERT_FILE_NAME}
    echo -e " $(timestamp)\n" >> ${ALERT_FILE_NAME}
    cat ${HEADER_TEMPLATE_02} >> ${ALERT_FILE_NAME}
    cat ${TABLE_TEMPLATE} >> ${ALERT_FILE_NAME}
    cat ${FOOTER_TEMPLATE} >> ${ALERT_FILE_NAME}
    echo -e "<b>Report generated at: </b>$(timestamp)" >> ${ALERT_FILE_NAME}
    cat ${CLOSING_TEMPLATE} >> ${ALERT_FILE_NAME}
    echo -e "$(timestamp):\tHTML Template Created at $(timestamp)"
}

send_html_to_team() {
    echo -e "$(timestamp):\tSending Mail"
    if [ ${COUNT_FAILED} -ne 0 ]; then
        for(( i=0; i<${COUNT_FAILED}; i++ ))
        do
            if [ $i -eq 0 ]; then
                FAIL_SUBJECT="${FAIL_SUBJECT}${FAILED_INSTANCE_NAME[$i]}"
            else
                FAIL_SUBJECT="${FAIL_SUBJECT} || ${FAILED_INSTANCE_NAME[$i]}"
            fi
        done
        EMAIL_SUBJECT="{Publisher Report} Publisher Instance: ${FAIL_SUBJECT} is not running : $(timestamp)"
    else
        EMAIL_SUBJECT="{Publisher Report} All instances are up and running: $(timestamp)"
    fi
    echo -e "$(timestamp):\tSubject: ${EMAIL_SUBJECT}"
    echo -e "$(timestamp):\tFile Name: ${ALERT_FILE_NAME}"
    echo -e "$(timestamp):\tTo: ${EMAIL_NOTIFY1};${EMAIL_NOTIFY2};${EMAIL_NOTIFY3};${EMAIL_NOTIFY4}"
    (
        echo "To: ${EMAIL_NOTIFY1};${EMAIL_NOTIFY2};"
        echo "Cc: ${EMAIL_NOTIFY3};${EMAIL_NOTIFY4}"
        echo "Subject: ${EMAIL_SUBJECT}"
        echo "Content-Type: text/html"
        echo
        cat ${ALERT_FILE_NAME}
    ) | /usr/sbin/sendmail -t
    echo -e "$(timestamp):\tPublisher Report Sent"

}


#################################################
# Sub Methods                                   #
#################################################


#################################################
# Parent Method: read_config_file               #
#################################################
store_data_region_wise() {
    ENV=$1
    RECLINE=$2
    if [ ${ENV} = "ASPAC_PROD" ]; then
        i=${ASPAC_PROD_COUNT}
        ASPAC_PROD_PUB_ENV[$i]=`echo ${RECLINE} | cut -d":" -f1 | cut -d"=" -f2`
        ASPAC_PROD_PUB_LIVE_FLAG[$i]=`echo ${RECLINE} | cut -d":" -f2 | cut -d"=" -f2`
        ASPAC_PROD_SSH_UID[$i]=`echo ${RECLINE} | cut -d":" -f3 | cut -d"=" -f2`
        ASPAC_PROD_SSH_SERVER[$i]=`echo ${RECLINE} | cut -d":" -f4 | cut -d"=" -f2`
        ASPAC_PROD_PUB_INSTANCE_NAME[$i]=`echo ${RECLINE} | cut -d":" -f5 | cut -d"=" -f2`
        ASPAC_PROD_COUNT=$((${ASPAC_PROD_COUNT}+1))
    elif [ ${ENV} = "NA_PROD" ]; then
        i=${NA_PROD_COUNT}
        NA_PROD_PUB_ENV[$i]=`echo ${RECLINE} | cut -d":" -f1 | cut -d"=" -f2`
        NA_PROD_PUB_LIVE_FLAG[$i]=`echo ${RECLINE} | cut -d":" -f2 | cut -d"=" -f2`
        NA_PROD_SSH_UID[$i]=`echo ${RECLINE} | cut -d":" -f3 | cut -d"=" -f2`
        NA_PROD_SSH_SERVER[$i]=`echo ${RECLINE} | cut -d":" -f4 | cut -d"=" -f2`
        NA_PROD_PUB_INSTANCE_NAME[$i]=`echo ${RECLINE} | cut -d":" -f5 | cut -d"=" -f2`
        NA_PROD_COUNT=$((${NA_PROD_COUNT}+1))

    elif [ ${ENV} = "EMEA_PROD" ]; then
        i=${EMEA_PROD_COUNT}
        EMEA_PROD_PUB_ENV[$i]=`echo ${RECLINE} | cut -d":" -f1 | cut -d"=" -f2`
        EMEA_PROD_PUB_LIVE_FLAG[$i]=`echo ${RECLINE} | cut -d":" -f2 | cut -d"=" -f2`
        EMEA_PROD_SSH_UID[$i]=`echo ${RECLINE} | cut -d":" -f3 | cut -d"=" -f2`
        EMEA_PROD_SSH_SERVER[$i]=`echo ${RECLINE} | cut -d":" -f4 | cut -d"=" -f2`
        EMEA_PROD_PUB_INSTANCE_NAME[$i]=`echo ${RECLINE} | cut -d":" -f5 | cut -d"=" -f2`
        EMEA_PROD_COUNT=$((${EMEA_PROD_COUNT}+1))
    fi
}
greatest_count_of_regions() {
    echo -e "$(timestamp):\tFinding Greatest of ASPAC_COUNT: ${ASPAC_PROD_COUNT} NA_COUNT: ${NA_PROD_COUNT} EMEA_COUNT: ${EMEA_PROD_COUNT}"
    if [ ${ASPAC_PROD_COUNT} -gt ${NA_PROD_COUNT} ] && [ ${ASPAC_PROD_COUNT} -gt ${EMEA_PROD_COUNT} ]; then
        TABLE_COUNT=${EMEA_PROD_COUNT}
    elif [ ${EMEA_PROD_COUNT} -gt ${ASPAC_PROD_COUNT} ] && [ ${EMEA_PROD_COUNT} -gt ${NA_PROD_COUNT} ]; then
        TABLE_COUNT=${EMEA_PROD_COUNT}
    else
        TABLE_COUNT=${NA_PROD_COUNT}
    fi
    echo -e "$(timestamp):\tTable Count Initialized to: ${TABLE_COUNT}"
    readonly TABLE_COUNT
}

#####################################################
# Parent Method: ssh_to_check_pub_status            #
#####################################################

na_ssh_to_check_pub_status() {
    for(( i=0; i<${NA_PROD_COUNT} ; i++ ))
    do
        read_status_log_na ${i}
        NA_PROD_PUB_COUNT_RESULT[${i}]=`ssh -q -o PasswordAuthentication=no -o ConnectTimeout=600 -n ${NA_PROD_SSH_UID[${i}]}@${NA_PROD_SSH_SERVER[${i}]} "ps -eaf | grep PwxCDCPublisher.sh | grep -v grep | grep ${NA_PROD_PUB_INSTANCE_NAME[${i}]} | wc -l;"`
        if [ ${NA_PROD_PUB_LIVE_FLAG[${i}]} -eq 0 ]; then
            NA_PROD_PUB_LIVE[${i}]="Not Live"
        else
            NA_PROD_PUB_LIVE[${i}]="Live"
        fi
        
        if [ ${NA_PROD_PUB_COUNT_RESULT[${i}]} -gt 0 ]; then
            NA_PROD_PUB_STATUS[${i}]="Running"
        else
            NA_PROD_PUB_STATUS[${i}]="Not Running"
        fi
        pub_status_log_na ${i}
    done
}
read_status_log_na() {
    i=$1
    printstar
    echo -e "$(timestamp):\tCurrently Checking Publisher status of ${NA_PROD_PUB_INSTANCE_NAME[${i}]} in ${NA_PROD_PUB_ENV[${i}]}"
    echo -e "$(timestamp):\tPublisher Instance: ${NA_PROD_PUB_INSTANCE_NAME[${i}]} runs in server: ${NA_PROD_SSH_SERVER[${i}]} and ssh userid is ${NA_PROD_SSH_UID[${i}]}"
}
pub_status_log_na() {
    i=$1
    echo -e "$(timestamp):\t${NA_PROD_PUB_INSTANCE_NAME[${i}]} is a ${NA_PROD_PUB_LIVE[${i}]} instance.."
    echo -e "$(timestamp):\t${NA_PROD_PUB_INSTANCE_NAME[${i}]} is currently ${NA_PROD_PUB_STATUS[${i}]} "
}

emea_ssh_to_check_pub_status() {
    for(( i=0; i<${EMEA_PROD_COUNT} ; i++ ))
    do
        read_status_log_emea ${i}
        EMEA_PROD_PUB_COUNT_RESULT[${i}]=`ssh -q -o PasswordAuthentication=no -o ConnectTimeout=600 -n ${EMEA_PROD_SSH_UID[${i}]}@${EMEA_PROD_SSH_SERVER[${i}]} "ps -eaf | grep PwxCDCPublisher.sh | grep -v grep | grep ${EMEA_PROD_PUB_INSTANCE_NAME[${i}]} | wc -l;"`
        if [ ${EMEA_PROD_PUB_LIVE_FLAG[${i}]} -eq 0 ]; then
            EMEA_PROD_PUB_LIVE[${i}]="Not Live"
        else
            EMEA_PROD_PUB_LIVE[${i}]="Live"
        fi
        
        if [ ${EMEA_PROD_PUB_COUNT_RESULT[${i}]} -gt 0 ]; then
            EMEA_PROD_PUB_STATUS[${i}]="Running"
        else
            EMEA_PROD_PUB_STATUS[${i}]="Not Running"
        fi
        pub_status_log_emea ${i}
    done
}
read_status_log_emea() {
    i=$1
    printstar
    echo -e "$(timestamp):\tCurrently Checking Publisher status of ${EMEA_PROD_PUB_INSTANCE_NAME[${i}]} in ${EMEA_PROD_PUB_ENV[${i}]}"
    echo -e "$(timestamp):\tPublisher Instance: ${EMEA_PROD_PUB_INSTANCE_NAME[${i}]} runs in server: ${EMEA_PROD_SSH_SERVER[${i}]} and ssh userid is ${EMEA_PROD_SSH_UID[${i}]}"
}
pub_status_log_emea() {
    i=$1
    echo -e "$(timestamp):\t${EMEA_PROD_PUB_INSTANCE_NAME[${i}]} is a ${EMEA_PROD_PUB_LIVE[${i}]} instance.."
    echo -e "$(timestamp):\t${EMEA_PROD_PUB_INSTANCE_NAME[${i}]} is currently ${EMEA_PROD_PUB_STATUS[${i}]} "
}

aspac_ssh_to_check_pub_status() {
    for(( i=0; i<${ASPAC_PROD_COUNT} ; i++ ))
    do
        read_status_log_aspac ${i}
        ASPAC_PROD_PUB_COUNT_RESULT[${i}]=`ssh -q -o PasswordAuthentication=no -o ConnectTimeout=600 -n ${ASPAC_PROD_SSH_UID[${i}]}@${ASPAC_PROD_SSH_SERVER[${i}]} "ps -eaf | grep PwxCDCPublisher.sh | grep -v grep | grep ${ASPAC_PROD_PUB_INSTANCE_NAME[${i}]} | wc -l;"`
        if [ ${ASPAC_PROD_PUB_LIVE_FLAG[${i}]} -eq 0 ]; then
            ASPAC_PROD_PUB_LIVE[${i}]="Not Live"
        else
            ASPAC_PROD_PUB_LIVE[${i}]="Live"
        fi
        
        if [ ${ASPAC_PROD_PUB_COUNT_RESULT[${i}]} -gt 0 ]; then
            ASPAC_PROD_PUB_STATUS[${i}]="Running"
        else
            ASPAC_PROD_PUB_STATUS[${i}]="Not Running"
        fi
        pub_status_log_aspac ${i}
    done
}
read_status_log_aspac() {
    i=$1
    printstar
    echo -e "$(timestamp):\tCurrently Checking Publisher status of ${ASPAC_PROD_PUB_INSTANCE_NAME[${i}]} in ${ASPAC_PROD_PUB_ENV[${i}]}"
    echo -e "$(timestamp):\tPublisher Instance: ${ASPAC_PROD_PUB_INSTANCE_NAME[${i}]} runs in server: ${ASPAC_PROD_SSH_SERVER[${i}]} and ssh userid is ${ASPAC_PROD_SSH_UID[${i}]}"
}
pub_status_log_aspac() {
    i=$1
    echo -e "$(timestamp):\t${ASPAC_PROD_PUB_INSTANCE_NAME[${i}]} is a ${ASPAC_PROD_PUB_LIVE[${i}]} instance.."
    echo -e "$(timestamp):\t${ASPAC_PROD_PUB_INSTANCE_NAME[${i}]} is currently ${ASPAC_PROD_PUB_STATUS[${i}]} "
}


#####################################################
# Logging Method                                    #
#####################################################

timestamp() {
    echo -e "$(date '+%d-%b-%Y %H:%M:%S') EST"
}

printstar() {
    echo -e "********************************************************************"
}

main "$@"
