#!/bin/bash
umask 022

#--------------------------------------------------------------------
#--------------------------------------------------------------------
# Name: Cloud_DynatraceAgentRemove
# -----
#
# Purpose: Script to remove the Dynatrace agent from Docker nodes
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
COLLECTION=${COLLECTION:="Worker"}
USER="svcdockr"
GOOD=()
BAD=()
SSHCommand="ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -qo StrictHostKeyChecking=no"

if [ ${MANIFEST} != "NONE" ]
then
   for SERVER in $(grep -i ${COLLECTION} /Cloud/dockerManifests/${MANIFEST} | awk -F: '{print $1}')
   do
      echo -e "Uninstalling the Dynatrace agent from ${SERVER}"
      ${SSHCommand} ${SERVER} "sudo /opt/dynatrace/oneagent/agent/uninstall.sh; rm-rf /opt/dynatrace" > /dev/null 2>&1 ; RC=${?}
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
