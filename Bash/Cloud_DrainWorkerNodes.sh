#!/usr/bin/env bash
umask 022

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# Name: Cloud_DrainWorkerNodes
# -----
#
# Purpose: This script will drain all of the Worker Nodes in a swarm's manifest
# --------
#
# File History:
# -------------
# 05 Nov 18 - Initial Version ............................................dongN
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

#set -x

Script=$(echo -e $0 | awk -F"/" '{print $NF}')
Server=$(uname -n)
LogFile=/Cloud/logs/${Script}.log
/syslib/rotate_logs ${LogFile}
exec &> >(tee -a "${LogFile}")

MANIFEST=${1}
MANIFEST=${MANIFEST:="NONE"}
USER="svcdockr"
MGR="$(grep -i -m 1 manager /Cloud/dockerManifests/${MANIFEST} | awk -F: '{print $1}')"
GOOD=()

if [ ${MANIFEST} != "NONE" ]
then
    ping -c 1 -w2 ${MGR} > /dev/null 2>&1 ; RC=${?}
else
    echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo -e "YOU DID NOT SUPPLY A VALID MANIFEST FILE!!!!!!!"
    echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
    exit 99
fi

if [ ${RC} -ne 0 ]
then
    echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo -e "${MGR} MANAGER NODE IS DOWN!!!! PLEASE INVESTIGATE!"
    echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
    exit 98
else
    echo -e "\nThe Manager node running the \"ACTIVE|DRAIN\" commands is ${MGR}\n"
    WORKERS=$(grep -i "worker" /Cloud/dockerManifests/${MANIFEST} | awk -F: '{print $1}')
    for WORKER in ${WORKERS}
    do
        ping -c 1 -w2 ${WORKER} > /dev/null 2>&1 ; RC=${?}
        
        if [ ${RC} -eq 0 ]
        then
            ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${MGR} "sudo docker node update --availability drain ${WORKER}" > /dev/null 2>&1 ; RC=${?}
        else
            echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo -e "${WORKER} WORKER NODE IS DOWN!!!! PLEASE INVESTIGATE"
            echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
            exit 97
        fi

        if [ ${RC} -eq 0 ]
        then
            sleep 10
            ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${MGR} "sudo docker node ls | grep -i ${WORKER} | grep -i drain" > /dev/null 2>&1 ; RC=${?}
        else
            echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo -e "The DRAIN command did NOT successfully run on ${MGR} for node ${WORKER}!!!"
            echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
            exit 96
        fi

        if [ ${RC} -eq 0 ]
        then
            sleep 60
            echo -e "Rebooting ${WORKER}...."
            ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${WORKER} "sudo nohup /Cloud/scripts/Cloud_ServerBoot.sh &"
            /Cloud/scripts/Docker/bootMonitor.sh ${WORKER} ${USER} ; RC=${?}
        else
            echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo -e "The DRAIN command successfully ran, but the ${WORKER} node is still showing active! Please investigate!"
            echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
            exit 95
        fi

        if [ ${RC} -eq 0 ]
        then
            ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${WORKER} "sudo docker container ls | grep -i ucp" > /dev/null 2>&1 ; RC=${?}
        else
            echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo -e "The boot monitoring script didn't return a success code! Please investigate ${WORKER}!"
            echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
            exit 94
        fi
        
        if [ ${RC} -eq 0 ]
        then
            ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${MGR} "sudo docker node update --availability active ${WORKER}" > /dev/null 2>&1 ; RC=${?}
        else
            echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo -e "The ${WORKER} node rebooted, but the UCP agent is not running! Please investigate!"
            echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n!"
            exit 93
        fi

        if [ ${RC} -eq 0 ]
        then
            sleep 10
            ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${MGR} "sudo docker node ls | grep -i ${WORKER} | grep -i active" > /dev/null 2>&1 ; RC=${?}
        else
            echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo -e "The ACTIVE command did NOT successfully run on ${MGR} for node ${WORKER}!!!"
            echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
            exit 92
        fi

        if [ ${RC} -eq 0 ]
        then
            echo -e "\n\nThe worker ${WORKER} node has successfully been drained, rebooted and set back to active!\n"
            GOOD+="${WORKER}\n"
            sleep 30
        else
            echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo -e "The Active command successfully ran, but ${WORKER} node is still showing drained! Please investigate!"
            echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
            exit 91
        fi
    done
fi

MailList=$(cat /Cloud/scripts/MailList.txt)
MESSAGE="\nThe following nodes were successfully drained, rebooted, and set back to active with no issue.\n"
MESSAGE+="${GOOD}"

if [ ${GOOD} ]
then
    echo -e "${MESSAGE}"
    echo -e "${MESSAGE}" | mailx -s "The worker nodes drained for the ${MANIFEST} manifest" ${MailList}
fi

exit
