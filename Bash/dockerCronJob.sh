#!/usr/bin/env bash
umask 022

#----------------------------------------------------------------------#
#       Script Name:    dockerCronJob.sh
#       Author:         Doug-E-Fresh Nelson
#       Created:        9/07/2018
#----------------------------------------------------------------------#

USER=$(whoami)
MANAGERS=$(grep -i "manager" /Cloud/dockerManifests/Lab2_Docker_Environment_16.3 | awk -F: '{print $1}')
SCRIPT="sudo crontab -e 0 2 * * 1 /root/DockerScripts/docker-bench-security.sh > /dev/null 2>&1"

for MANAGER in ${MANAGERS}
do  
    echo $MANAGER 
    echo "============"

    ping -c 1 -w 2 ${MANAGER} >/dev/null 2>&1 ; RC=$?

    if [ $RC -eq 0 ] 
    then
        ssh -o BatchMode=yes -l ${USER} StrictHostKeyChecking=no -q ${MANAGER} "${SCRIPT}" ; SUCCESS=$?
        if [ $SUCCESS -eq 0 ]
        then
            echo "Cron Job was created successfully on ${MANAGER}."
        else
            echo "NO DICE ON THE CRON JOB FOR ${MANAGER}! SOMETHING WENT WRONG!"
        fi        
    fi 
done 
exit