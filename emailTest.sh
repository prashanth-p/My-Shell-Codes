#!/bin/bash

############################# HEADER ###############################
# Author: Prashanth
# File Name: emailTest.sh
# Purpose:
# Version: 1.1
# Created Date: Fri Jan  4 03:36:35 MST 2019
# Last Modified Date:
####################################################################

# START #


#--------------------------------------------- FUNCTION DEFINITION ----------------------------------------------------#
#--------------------------- Proceed to Main code to see how to integrate the function --------------------------------#

# Create Body of email

send_mail()
{
        # Create the mail to be sent

        # echo "Creating Temp File"
        FILENAME="~testMailText.html"
        `touch ${FILENAME}`

        # EMAIL_TO=$1   EMAIL_FROM=$2   val=$3   job_name=$4    status_msg=$5  error_text=$6
        create_email_body "$1" "$2" $3 "$4" "$5" "$6"

        echo >> ${FILENAME}

        echo "</body></html>" >> ${FILENAME}
        cat ${FILENAME} |/usr/lib/sendmail -t
        `rm -r ${FILENAME}`
        echo "E-mail Sent"
}

create_email_body()
{
        # EMAIL_TO=$1   EMAIL_FROM=$2   val=$3   job_name=$4    status_msg=$5  error_text=$6

        DATE=`date +%Y%m%d%H%M`

        echo "To: "${1}" " > ${FILENAME}
        echo "From: "${2}" " >> ${FILENAME}
        echo "Content-Type: text/html" >> ${FILENAME}
        echo "Subject: Retry Option Status Email - $DATE" >> ${FILENAME}

        echo "<html><body>" >> ${FILE}.html

        # val=$3        job_name=$4     error_text=$5

        test_retry_condition $3 "$4" "$5" "$6"
}

test_retry_condition()
{
        # status_val=$1 job_name=$2     Status_MSG=$3 error_text=$4
        # if status_val=3; ERROR
        # ELSE NO ERROR

        if [ $1 -ne 3 ]; then
                echo "<p><span style=\"font-size: 12pt;\"><strong>Job Name:</strong>&nbsp; ${2} </span></p>" >> ${FILENAME}
                echo "<p><span style=\"font-size: 12pt;\"><strong>Status:</strong>&nbsp;<em> ${3} </em></span></p>" >> ${FILENAME}

        elif [ $1 -eq 3 ]; then
                echo "<p><span style=\"font-size: 12pt;\"><strong>Job Name:</strong>&nbsp; ${2} </span></p>" >> ${FILENAME}
                echo "<p><span style=\"font-size: 12pt;\"><strong>Status:</strong>&nbsp;<em> $3 </em></span></p>" >> ${FILENAME}


                echo '<table style="height: 18px; width: 100%; border-collapse: collapse; border-style: solid;" border="1" cellpadding="10">' >> ${FILENAME}
                echo '<tbody>' >> ${FILENAME}
                echo '<tr style="height: 18px;">' >> ${FILENAME}
                echo "<td style=\"width: 100%; height: 18px;\"><span style=\"font-size: 12pt;\"> ${4} </span></td>" >> ${FILENAME}
                echo "</tr></tbody></table>" >> ${FILENAME}

                #-------------------- Edit this message if required ------------------------#

                echo "<p><span style=\"font-size: 12pt;\"> The job <strong>$2</strong> is failed for connection issue </span></p>" >> ${FILENAME}
        fi

}

#--------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------- Main Code -----------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------------------------------------#

# Mail Details
EMAIL_TO="prashanth.pradeep@lntinfotech.com"
EMAIL_FROM="prashanth.pradeep@lntinfotech.com"


# if status_val=3; ERROR
# ELSE NO ERROR

STATUS_VAL=3


JOB_NAME="Happy Feet"

# Use HTML to style your Status Msg
if [ $STATUS_VAL -eq 3 ]; then
        STATUS_MSG="The RETRY Option script is completed with an <strong>ERROR</strong>. Below is the error text."

        # Enter the error message in the ERROR_TEXT Variable
        ERROR_TEXT="This is an error message. Syntax Error."

else
        STATUS_MSG="The RETRY Option script is completed successfuly."
fi


send_mail "${EMAIL_TO}" "${EMAIL_FROM}" ${STATUS_VAL} "${JOB_NAME}" "${STATUS_MSG}" "${ERROR_TEXT}"

#---------------------------------------------------------- END --------------------------------------------------------------------#
