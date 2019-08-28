#!/bin/bash
umask 022

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Name: Cloud_WorkerEnableDebugging.sh
# -----
#
# Purpose: Enable debugging on worker nodes.
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
      docker info | grep -i debug.*server | grep -iq true
      if [ \${?} -eq 0 ]
      then

         #-----------------------------------------------------------------------------------------
         # Exit if already in debug mode
         #-----------------------------------------------------------------------------------------

         echo -e "\nThe \$(hostname) is alreay in debug mode. Moving on to the next server..."
         exit
      else

         #------------------------------------------------------------------------------------------
         # Add debug value to daemon.json if machine is not in debug mode
         #------------------------------------------------------------------------------------------

         echo -e "\nThe \$(hostname) server is not in debug mode. Modifying the daemon.json now..."
         DAEMON="/etc/docker/daemon.json"
         if [ -f \${DAEMON} ]
         then
            grep -q "\"debug\": true" \${DAEMON}
            if [ \${?} -eq 0 ]
            then
               echo -e "The debug value was already set in the daemon.json. Moving on to the daemon reload..."
            else
            
               #------------------------------------------------------------------------
               # Add value to existing daemon.json
               #------------------------------------------------------------------------

               echo -e "The daemon.json file already exists; adding debug values now..."
               DOCKER_DAEMON_CONF=\$(cat \${DAEMON} 2>&1 /dev/null)
               echo \${DOCKER_DAEMON_CONF} | jq '.debug=true' > \${DAEMON}
               grep -q "\"debug\": true" \${DAEMON}
               if [ \${?} -ne 0 ]
               then
                  echo -e "Could not add debug value to existing daemon.json; INVESTIGATE! Exiting now..."
                  exit 1
               fi
            fi
         else
         
            #--------------------------------------------------------------------------
            # Add value to new daemon.json
            #--------------------------------------------------------------------------

            echo -e "The daemon.json file did not exist; creating it now and adding debug values..."
            touch \${DAEMON}
            echo -e "{\n    \"debug\": true\n}" > \${DAEMON}
            grep -q "\"debug\": true" \${DAEMON}
            if [ \${?} -ne 0 ]
            then
               echo - "Could not add debug value to newly create daemon.json; INVESTIGATE! Exiting now..."
               exit 1
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
         # Final validation check for debug value
         #------------------------------------------------------------------------------------

         docker info | grep -i debug.*server | grep -iq true
      fi
EOF

   if [ ${?} -eq 0 ]
   then
      echo -e "\nThe worker ${WORKER} has been enabled for debugging."
      GOOD+="${WORKER}\n"
      sleep 10
   else
      ERROR="\nEnabling debugging on ${WORKER} FAILED!!! Please INVESTIGATE!!!"
      echo -e "${ERROR}"
      echo -e "${ERROR}" | mailx -s "Enabling debugging FAILED on ${WORKER}"
      exit 98
   fi
done

MESSAGE="\nThe following worker nodes have been enabled for debugging.\n"
MESSAGE+="${GOOD}"

if [ ${GOOD} ]
then
   echo -e "${MESSAGE}"
   echo -e "${MESSAGE}" | mailx -s "Debugging was enabled on ${COLLECTION} workers in ${MANIFEST} manifest." ${MailList}
fi

exit
