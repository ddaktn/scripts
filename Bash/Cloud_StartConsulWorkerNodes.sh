#!/usr/bin/env bash
umask 022

#--------------------------------------------------------------------
#--------------------------------------------------------------------
# Name: Cloud_StartConsulWorkerNodes
# -----
#
# Purpose: Script to enable the Consul Agent on Worker Nodes in Swarm
# --------
#
# File History:
# -------------
# 09 Aug 19 - Initial Version ...................................donG
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
USER="svcdockr"
GOOD=()
BAD=()

if [ ${MANIFEST} != "NONE" ]
then
   for SERVER in $(grep -i ${COLLECTION} /Cloud/dockerManifests/${MANIFEST} | awk -F: '{print $1}')
   do
      echo ${SERVER}
      echo -e "========================="
      ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -qo StrictHostKeyChecking=no ${SERVER} "sudo systemctl start consul" ; RC=${?}
      if [ ${RC} -eq 0 ]
      then
         echo -e "Consul service was successfully started on ${SERVER}"
         GOOD+="${SERVER}\n"
      else
         echo -e "Consul service was NOT successfully started on ${SERVER}... INVESTIGATE!!!"
         BAD+="${SERVER}\n"
      fi
      echo -e "========================="
   done
else
   echo -e "YOU DID NOT PROVIDE A VALID MANIFEST FILE!!!!!"
   exit 99
fi

MailList=$(cat /Cloud/scripts/MailList.txt)
MESSAGE="\nThe consul agent was successfully started on the following nodes:\n"
MESSAGE+="${GOOD}"
ERROR="\n\nThe consul agent was NOT successfully started on the following nodes and needs investigation:\n"
ERROR+="${BAD}"

if [[ ${GOOD} && ${BAD} ]]
then
    echo -e "${MESSAGE}${ERROR}"
    echo -e "${MESSAGE}${ERROR}" | mailx -s "The consul start on ${COLLECTION} nodes for ${MANIFEST} succeeded WITH ERRORS" ${MailList}
elif [ ${GOOD} ]
then
   echo -e "${GOOD}"
   echo -e "${MESSAGE}" | mailx -s "The consul start on ${COLLECTION} nodes for ${MANIFEST} succeeded" ${MailList}
elif [ ${BAD} ]
then
   echo -e "${BAD}"
   echo -e "${ERROR}" | mailx -s "The consul start on ${COLLECTION} nodes for ${MANIFEST} FAILED" ${MailList}
else
   echo -e "Investigate. No servers were populated in the successful or failed arrays. Check server logs." | mailx -s "The puppet start on ${COLLECTION} nodes for ${MANIFEST} FAILED" ${MailList} 
fi

exit
