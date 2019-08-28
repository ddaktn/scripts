#!/bin/bash
umask 022

#--------------------------------------------------------------------
#--------------------------------------------------------------------
# Name: Cloud_DynatraceAgentAddWithCollection.sh
# -----
#
# Purpose: Script to add Dynatrace agent with Docker Collection Tag
# --------
#
# File History:
# -------------
# 06 Aug 19 - Initial Version ...................................donG
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
COLLECTION=${COLLECTION:="NONE"}
USER="svcdockr"
GOOD=()
BAD=()
SSHCommand="ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -o StrictHostKeyChecking=no"

if [ ${MANIFEST} != "NONE" ]
then
   if [ ${COLLECTION} != "NONE" ]
   then
      for SERVER in $(grep -i ${COLLECTION} /Cloud/dockerManifests/${MANIFEST} | awk -F: '{print $1}')
      do
         echo -e "Installing the Dynatrace agent on ${SERVER}"
         COLL=${COLLECTION^^}
         ${SSHCommand} ${SERVER} "sudo /bin/sh ${COLL}-Dynatrace-OneAgent-Linux-1.151.314.sh APP_LOG_CONTENT_ACCESS=1 INFRA_ONLY=0 HOST_GROUP=DOCKER" > /dev/null 2>&1 ; RC=${?}
         if [ ${RC} -eq 0 ]
         then
            echo -e "Dynatrace was successfully uninstalled from ${SERVER}"
            GOOD+="${SERVER}\n"
         else
            echo -e "Dynatrace did NOT successfully uninstall from ${SERVER}... INVESTIGATE!!!"
            BAD+="${SERVER}\n"
         fi
      done
   else
      echo -e "YOU DID NOT PROVIDE A VALID COLLECTION!!!"
      exit 98
   fi
else
   echo -e "YOU DID NOT PROVIDE A VALID MANIFEST FILE!!!"
   exit 99
fi

MailList=$(cat /Cloud/scripts/MailList.txt)
MESSAGE="\nThe dynatrace agent was uninstalled on the following nodes:\n"
MESSAGE+="${GOOD}"
ERROR="\n\nThe dynatrace agent was NOT uninstalled on the following nodes and needs investigation:\n"
ERROR+="${BAD}"

if [ ${GOOD} && ${BAD} ]
then
   echo -e "${MESSAGE}${ERROR}"
   echo -e "${MESSAGE}${ERROR}" | mailx -s "The dynatrace uninstall on ${COLLECTION} nodes for ${MANIFEST} succeeded WITH ERRORS" ${MailList}
elif [ ${GOOD} ]
then
   echo -e "${GOOD}"
   echo -e "${MESSAGE}" | mailx -s "The dynatrace uninstall on ${COLLECTION} nodes for ${MANIFEST} succeeded" ${MailList}
elif [ ${BAD} ]
then
   echo -e "${BAD}"
   echo -e "${ERROR}" | mailx -s "The dynatrace uninstall on ${COLLECTION} nodes for ${MANIFEST} FAILED" ${MailList}
else
   echo -e "Investigate. No servers were populated in the successful or failed arrays. Check server logs." | mailx -s "The dynatrace uninstall on ${COLLECTION} nodes for ${MANIFEST} FAILED" ${MailList}
fi
exit
