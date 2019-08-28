#!/usr/bin/env bash
umask 022

#--------------------------------------------------------------------
#--------------------------------------------------------------------
# Name: Cloud_StartPuppetWorkerNodes
# -----
#
# Purpose: Script to enable the Puppet Agent on Worker Nodes in Swarm
# --------
#
# File History:
# -------------
# 17 Jul 19 - Initial Version ...................................donG
#--------------------------------------------------------------------
#--------------------------------------------------------------------

#set-x

Script=$(echo -e $0 | awk -F"/" '{print $NF}')
Server=$(uname -n)
LogFile=/Cloud/logs/${Script}.log
/syslib/rotate_logs ${LogFile}
exec &> >(tee -a "${LogFile}")

MANIFEST=${1}
MANIFEST=${MANIFEST:="NONE"}
COLLECTION=${2}
COLLECTION=${COLLECTION:="Worker"}
MANAGER="$(grep -i -m 1 manager /Cloud/dockerManifests/${MANIFEST} | awk -F: '{print $1}')"
USER="svcdockr"
GOOD=()
BAD=()

if [ ${MANIFEST} != "NONE" ]
then
   for SERVER in $(grep -i ${COLLECTION} /Cloud/dockerManifests/${MANIFEST} | awk -F: '{print $1}')
   do
      echo -e "Draining the ${SERVER} node from the ${MANAGER} manager node..."
      ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${MANAGER} "sudo docker node update --availability drain ${SERVER}" > /dev/null 2>&1 ; RC=${?}

      if [ ${RC} -eq 0 ]
      then
         sleep 10
         ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${MANAGER} "sudo docker node ls | grep -i ${SERVER} | grep -i drain" > /dev/null 2>&1 ; RC=${?}
      else
         echo -e "There was an issue running the drain command for the ${SERVER} worker node on ${MANAGER} manager node... Investigate!"
         exit 97
      fi

      if [ ${RC} -eq 0 ]
      then
         echo ${SERVER}
         echo -e "========================="
         ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${SERVER} "sudo systemctl start puppet; sleep 5m; consul version | grep 1.3.1" > /dev/null 2>&1 ; RC=${?}

         if [ ${RC} -eq 0 ]
         then
            echo -e "Puppet service was successfully started and consul successfully upgraded on ${SERVER}"
            GOOD+="${SERVER}\n"
         else
            echo -e "Puppet service was NOT successfully started and consul UNSUCCESSFULLY upgraded on ${SERVER}... INVESTIGATE!!!"
            BAD+="${SERVER}\n"
         fi
         echo -e "========================="

         echo -e "Setting the ${SERVER} worker node back to ACTIVE..."
         ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${MANAGER} "sudo docker node update --availability active ${SERVER}" > /dev/null 2>&1 ; RC=${?}

         if [ ${RC} -eq 0 ]
         then
            ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no ${MANAGER} "sudo docker node ls | grep -i ${SERVER} | grep -i active" > /dev/null 2>&1 ; RC=${?}
         else
            echo -e "There was an issue running the active command for ${SERVER} worker node on ${MANAGER} manager node... INVESTIGATE!!!"
            exit 96
         fi

         if [ ${RC} -eq 0 ]
         then
            echo -e "The ${SERVER} worker node is back in an active state."
         else
            echo -e "The ACTIVE command ran successfully, but the ${SERVER} worker node is still showing drained! INVESTIGATE!!!"
            exit 95
         fi

      else
         echo -e "The DRAIN command ran successfully, but the ${SERVER} worker node is still showing active! INVESTIGATE!!!"
         exit 98
      fi
   done
else
   echo -e "YOU DID NOT PROVIDE A VALID MANIFEST FILE!!!!!"
   exit 99
fi

MailList=$(cat /Cloud/scripts/MailList.txt)
MESSAGE="\nThe puppet agent was started and consul successfully upgraded on the following nodes:\n"
MESSAGE+="${GOOD}"
ERROR="\n\nThe puppet agent was NOT started and consul UNSUCCESSFULLY upgraded on the following nodes and needs investigation:\n"
ERROR+="${BAD}"

if [ ${GOOD} && ${BAD} ]
then
    echo -e "${MESSAGE}${ERROR}"
    echo -e "${MESSAGE}${ERROR}" | mailx -s "The puppet start and consul upgrade on ${COLLECTION} nodes for ${MANIFEST} succeeded WITH ERRORS" ${MailList}
elif [ ${GOOD} ]
then
   echo -e "${GOOD}"
   echo -e "${MESSAGE}" | mailx -s "The puppet start and consul upgrade on ${COLLECTION} nodes for ${MANIFEST} succeeded" ${MailList}
elif [ ${BAD} ]
then
   echo -e "${BAD}"
   echo -e "${ERROR}" | mailx -s "The puppet start and consul upgrade on ${COLLECTION} nodes for ${MANIFEST} FAILED" ${MailList}
else
   echo -e "Investigate. No servers were populated in the successful or failed arrays. Check server logs." | mailx -s "The puppet start on ${COLLECTION} nodes for ${MANIFEST} FAILED" ${MailList} 
fi

exit
