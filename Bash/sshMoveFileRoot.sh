#!/usr/bin/env bash
umask 022

#----------------------------------------------------------------------#
#       Script Name:    moveBackupJob_LAB2.sh
#       Author:         Doug-E-Fresh Nelson
#       Created:        9/11/2018
#----------------------------------------------------------------------#

ENVIRONMENT="Lab2_Docker_Environment_16.2"
FILE="docker-ucp-backup.sh"
SERVERS=$(cat /Cloud/dockerManifests/${ENVIRONMENT} | awk -F: '{print $1}')
SCRIPT="sudo mv -f /data/req92473/${FILE} /Cloud/scripts/Docker/"

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