#!/usr/bin/env bash
umask 022

#----------------------------------------------------------------------#
#       Script Name:    moveBackupJob_LAB2.sh
#       Author:         Doug-E-Fresh Nelson
#       Created:        9/11/2018
#----------------------------------------------------------------------#

USER=$(whoami)
ENVIRONMENT="Lab2_Docker_Environment_16.2"
FILE="backup-ucp-backup.sh"
SOURCE="lx1726"
SERVERS=$(cat /Cloud/dockerManifests/${ENVIRONMENT} | awk -F: '{print $1}')
SCRIPT="sudo scp ${SOURCE}:/Cloud/scripts/Docker/${FILE} /Cloud/scripts/Docker/"

for SERVER in ${SERVERS}
do  
    echo ${SERVER} 
    echo "============"

    ping -c 1 -w 2 ${SERVER} >/dev/null 2>&1 ; RC=${?}

    if [ ${RC} -eq 0 ] 
    then
        ssh -o BatchMode=yes -l ${USER} StrictHostKeyChecking=no -q ${SERVER} "${SCRIPT}" ; RC=${?}
        if [ ${RC} -eq 0 ]
        then
            echo "Updated backup job copied successfully on ${SERVER}."
        else
            echo "NO DICE ON ${SERVER}! SOMETHING WENT WRONG!"
        fi        
    fi 
done 
exit