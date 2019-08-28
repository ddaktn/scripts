#!/bin/bash
umask 022

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Name: Cloud_WorkerDisableDebugging.sh
# -----
#
# Purpose: Disable debugging on worker nodes.
# --------
#
# File History:
# -------------
# 27 Aug 19 - Initial Version .............................................donG
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

#set -x

MailList=$(cat /Cloud/scripts/MailList.txt)
Script=$(echo -e $0 | awk -F"/" '{print $NF}')
Server=$(uname -n)
LogFile=/Cloud/logs/${Script}.log
/syslib/rotate_logs ${LogFile}
exec &> >(tee -a "${LogFile}")

MANIFEST=${1}
MANIFEST=${MANIFEST:="NONE"}
COLLECTION=${2}
COLLECTION=${COLLECTION:="ALL"}
USER="svcdockr"
SSHCommand="ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -qo StrictHostKeyChecking=no"

#------------------------------------------------------------------------------------------------------
# Create array of workers from collection
#------------------------------------------------------------------------------------------------------

if [ ${MANIFEST} == "NONE" ]
then
   echo -e "\n\nYou did not supply a valid manifest file!!!! Please try again!!!!\n\n"
   exit 99
fi

if [ ${COLLECTION^^} == "ITG" ]
then
   WORKERS=$(grep -i worker /Cloud/dockerManifests/${MANIFEST} | grep -i itg | awk -F: '{print $1}')
elif [ ${COLLECTION^^} == "CAT" ]
then
   WORKERS=$(grep -i worker /Cloud/dockerManifests/${MANIFEST} | grep -i cat | awk -F: '{print $1}')
elif [ ${COLLECTION^^} == "PROD" ]
then
   WORKERS=$(grep -i worker /Cloud/dockerManifests/${MANIFEST} | grep -i prod | awk -F: '{print $1}')
else
   WORKERS=$(grep -i worker /Cloud/dockerManifests/${MANIFEST} | awk -F: '{print $1}')
fi

for WORKER in ${WORKERS}
do
   ${SSHCommand} ${WORKER} <<EOF
      sudo -s
      echo -e "\n\n============================"
      echo -e "\$(hostname)"
      echo -e "============================"
      DAEMON="/etc/docker/daemon.json"
      docker info | grep -i debug.*server | grep -iq false
      if [ \${?} -eq 0 ]
      then

         #-----------------------------------------------------------------------------------------
         # Exit if already out of debug mode after checking the daemon.json
         #-----------------------------------------------------------------------------------------

         echo -e "\nThe \$(hostname) is alreay out of debug mode. Validating the daemon.json and moving on to the next server..."
         if [ -f \${DAEMON} ]
         then
            grep -q "\"debug\": true" \${DAEMON}
            if [ \${?} -eq 0 ]
            then
               sed -i 's/\"debug\": true/\"debug\": false/g' \${DAEMON}
               if [ \${?} -ne 0 ]
               then
                  echo -e "Something went wrong writing to the daemon.json file; please INVESTIGATE!"
                  exit 1
               fi
            fi
         fi
         exit
      else

         #------------------------------------------------------------------------------------------
         # Change daemon (if exists) and send SIGHUP command to reload docker daemon 
         #------------------------------------------------------------------------------------------

         echo -e "\nThe \$(hostname) server is currently in debug mode. Modifying the daemon.json to disable now..."
         if [ -f \${DAEMON} ]
         then
            grep -q "\"debug\": true" \${DAEMON}
            if [ \${?} -eq 0 ]
            then
               sed -i 's/\"debug\": true/\"debug\": false/g' \${DAEMON}
               if [ \${?} -ne 0 ]
               then
                  echo -e "Something went wrong writing to the daemon.json file; please INVESTIGATE!"
                  exit 1
               fi
            fi
         fi
      
         #-----------------------------------------------------------------------------------
         # Reload the docker daemon configuration without doing a restart
         #-----------------------------------------------------------------------------------
      
         echo -e "Reloading the config without service restart now..."
         kill -SIGHUP \$(pidof dockerd)
         if [ \${?} -eq 0 ]
         then
            echo -e "The SIGHUP kill command for the docker daemon was successful."
         else
            echo -e "Something went wrong with the SIGHUP command; INVESTIGATE! Exiting now..."
            exit 1
         fi

         #------------------------------------------------------------------------------------
         # Final validation check for false  debug value
         #------------------------------------------------------------------------------------

         docker info | grep -i debug.*server | grep -iq false
      fi
EOF

   if [ ${?} -eq 0 ]
   then
      echo -e "\nThe worker ${WORKER} has been disabled for debugging."
      GOOD+="${WORKER}\n"
      sleep 10
   else
      ERROR="\nDisabling debugging on ${WORKER} FAILED!!! Please INVESTIGATE!!!"
      echo -e "${ERROR}"
      echo -e "${ERROR}" | mailx -s "Disabling debugging FAILED on ${WORKER}"
      exit 98
   fi
done

MESSAGE="\nThe following worker nodes have been disabled for debugging.\n"
MESSAGE+="${GOOD}"

if [ ${GOOD} ]
then
   echo -e "${MESSAGE}"
   echo -e "${MESSAGE}" | mailx -s "Debugging was disabled on ${COLLECTION} workers in ${MANIFEST} manifest." ${MailList}
fi

exit
