#!/usr/bin/bash

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
# Name:  Cloud_Puppet.sh-2.1 UNIX Bash shell script.
# -----
#
# Purpose:  This script will do the following for a new VM which requires
# -------   Puppet that is provisioned from the private cloud:
#              - Install the Puppet client
#              -
#
# File History:
# -------------
# 02 Mar 16 - Initial Version ............................................rd
# 13 Feb 17 - Added versioning to script..............................1.7-rd
# 15 Mar 17 - Added support of AutoDestroy on ANY Provisioning error..1.8-rd
# 06 Feb 18 - Updated boostrap_server RPM to 5.0.3....................2.1-rd
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

#set -x

MailList=$(cat /Cloud/scripts/MailList.txt)

Server=${1}
Request=${2}
PuppetFacts=${3}
PuppetMaster=${4}
PuppetEnv=${5}

PuppetEnv=${PuppetEnv:="NONE"}

User=$(whoami)

if [ ${User} == "svcldadm" ]
then
   logger "${User} is a valid SysAdmin with server build priveleges."
   logger "Running the ${Script} as root user using sudo."
   /usr/bin/sudo -i /Cloud/scripts/Cloud_Puppet.sh-2.1 ${Server} ${Request} ${PuppetFacts}
   exit
elif [ ${User} == "root" ]
then
   echo -e "\nRunning script as native ${User}"
else
   echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   echo -e "!!!  You are not an authorized SysAdmin.  GO FISH.         !!!"
   echo -e "!!!  (and I'm telling)                                     !!!"
   echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
   exit 99
fi

Script=$(echo -e $0 | awk -F"/" '{print $NF}')

LogFile=/Cloud/logs/${Script}.log

/syslib/rotate_logs ${LogFile}

exec >> ${LogFile} 2>> ${LogFile}

OSVersion=$(cat /etc/redhat-release | awk -F"release " '{print $2}' | cut -c 1)
if [ ${OSVersion} -eq 7 ]
then
   Satellite=lx686
else
   Satellite=lx084
fi

echo -e "Installing the Puppet client."

#---------------------------------------------------------------------------
# Install the puppet rpm.
#---------------------------------------------------------------------------

if [ ${OSVersion} -eq 7 ]
then
   yum -y localinstall /Cloud/scripts/PuppetConfig/puppet-agent-1.5.3-1.el7.x86_64.rpm --nogpgcheck; RC=${?}
else
   yum -y localinstall /Cloud/scripts/PuppetConfig/puppet-agent-1.8.0-1.el6.x86_64.rpm --nogpgcheck; RC=${?}
fi

export PATH="${PATH}:/opt/puppetlabs/bin"

if [ ${RC} -eq 0 ]
then
   echo -e "\n\n========================================="
   echo -e "The Puppet client install was successful."
   echo -e "========================================="

   echo -e "\n\nPuppetFacts:  '${PuppetFacts}'\n\n"
   echo -e "Staging the Puppet Facts in /etc/facter/facts.d/deploy.txt"
   if [ ! -d /etc/facter/facts.d ]
   then
      echo -e "\nThe /etc/facter/facts.d directory does not exist, creating it...\c"
      mkdir -p /etc/facter/facts.d; RC=${?}
      if [ ${RC} -eq 0 ]
      then
         echo -e "successful."
      else
         echo -e "FAILED."
         echo -e "Please Investigate.\n"

         echo -e "\nCopying ${LogFile} to ${Satellite}:/Cloud/troubleshoot"
         scp -qo StrictHostKeyChecking=no -i /data/svcldadm/.ssh/id_dsa -i /data/svcldadm/.ssh/id_rsa ${LogFile} svcldadm@${Satellite}:/Cloud/troubleshoot/${Server}_${Script}.log; RC=${?}
         if [ ${RC} -eq 0 ]
         then
            echo -e "Successful."
         else
            echo -e "FAILED."
            echo -e "The copy of the ${LogFile} from ${Server} to ${Satellite}:/Cloud/troubleshoot failed. Good luck troubleshooting..." | mailx -s "Request ${Request} (${Server}):  Problem running /Cloud/scripts/Cloud_Puppet.sh-2.1 - INVESTIGATE" ${MailList}
         fi

         echo -e "Sending notification email to Cloud Administrators.\n\n"
         echo -e "There was an error encountered creating the /etc/facter/facts.d directory on ${Server}.  Please investigate by reviewing the following log file on ${Satellite}: \n\n   /Cloud/troubleshoot/${Server}_${LogFile}" | mailx -s "Request ${Request} (${Server}):  Error Encountered in /Cloud/scripts/Cloud_Puppet.sh-2.1 on ${Server} - INVESTIGATE" ${MailList}
         exit 99
      fi
   fi

   Line=1
   Lines=$(echo ${PuppetFacts} | awk -F";" '{print NF}')
   > /etc/facter/facts.d/deploy.txt
   while [ ${Line} -le ${Lines} ]
   do
       echo ${PuppetFacts} | cut -d";" -f${Line} >> /etc/facter/facts.d/deploy.txt
       (( Line = ${Line} + 1 ))
   done

   if [ -s /etc/facter/facts.d/deploy.txt ]
   then
      echo -e "\n\n=========================================="
      echo -e "The Puppet facts were staged successfully."
      echo -e "=========================================="

      if [ ${PuppetEnv} != "NONE" ]
      then

         echo -e "\n\nPopulating the environment definition (${PuppetEnv}) and master server (${PuppetMaster}) in puppet.conf."
         echo "[agent]" >> /etc/puppetlabs/puppet/puppet.conf
         echo "environment=${PuppetEnv}" >> /etc/puppetlabs/puppet/puppet.conf
         echo "server=${PuppetMaster}" >> /etc/puppetlabs/puppet/puppet.conf
      else
         echo -e "\n\nPopulating the master server (${PuppetMaster}) in puppet.conf."
         echo "[agent]" >> /etc/puppetlabs/puppet/puppet.conf
         echo "server=${PuppetMaster}" >> /etc/puppetlabs/puppet/puppet.conf
      fi

      echo -e "\n\nInstalling the Puppet bootstrap RPM.\n"
      rpm -ihv /Cloud/scripts/PuppetConfig/bootstrap_server-5.0.3.rpm; RC=${?}

      if [ ${RC} -eq 0 ]
      then
         echo -e "\n\n===================================================="
         echo -e "The Puppet bootstrap RPM was installed successfully."
         echo -e "===================================================="
         echo -e "\n\nCleaning up the Puppet Config Files....\n"
         rm -rf /Cloud/scripts/PuppetConfig

        ###################################################################################################
        # Block added to disable the Puppet client after successfully installing and pulling a config
        # Doug Nelson -- 10/03/2018
        ###################################################################################################
        echo -e "\n\nDisabling the Puppet Agent post install.\n"
        PUPPET_DISABLE=1
        LOOP=0
        while [ ${LOOP} -lt 3 ]
        do
            /opt/puppetlabs/bin/puppet agent -t ; RC=${?}
            #wait
            if [ ${RC} -eq 0 ]
            then
                echo -e "\n\nThe agent has successfully updated and will now be stopped and disabled.\n\n"                
                systemctl disable puppet
                systemctl stop puppet
                systemctl status consul ; CONSUL_CODE=${?}
                if [ ${CONSUL_CODE} -eq 0 ]
                then
                    echo -e "\n\nPuppet successfully installed and updated the Consul agent and is now disabled.\n\n"
                    LOOP=3
                    PUPPET_DISABLE=0
                else
                    echo -e "\n\nPuppet was not able to be disabled. Will try again!!!!\n\n"
                    ((LOOP++))
                fi
            else
                echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                echo -e "There was an issue trying to update the puppet agent. Will try again!!!!"
                echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
                ((LOOP++))
            fi
        done
        
        if [ ${PUPPET_DISABLE} -eq 0 ]
        then
            echo -e "\n\n===================================================="
            echo -e "The Puppet agent successfully updated and is disabled."
            echo -e "===================================================="
        else
            echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo -e "Disabling the Puppet agent FAILED."
            echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo -e "Please Investigate.\n"

            echo -e "\nCopying ${LogFile} to ${Satellite}:/Cloud/troubleshoot"
            scp -qo StrictHostKeyChecking=no -i /data/svcldadm/.ssh/id_dsa -i /data/svcldadm/.ssh/id_rsa ${LogFile} svcldadm@${Satellite}:/Cloud/troubleshoot/${Server}_${Script}.log; RC=${?}
            if [ ${RC} -eq 0 ]
            then
                echo -e "Successful."
            else
                echo -e "FAILED."
                echo -e "The copy of the ${LogFile} from ${Server} to ${Satellite}:/Cloud/troubleshoot failed. Good luck troubleshooting..." | mailx -s "Request ${Request} (${Server}):  Problem running /Cloud/scripts/Cloud_Puppet.sh-2.1 - INVESTIGATE" ${MailList}
            fi

            echo -e "Sending notification email to Cloud Administrators.\n\n"
            echo -e "There was an error encountered disabling the Puppet bootstrap RPM on ${Server}.  Please investigate by reviewing the following log file on ${Satellite}: \n\n   /Cloud/troubleshoot/${Server}_${LogFile}" | mailx -s "Request ${Request} (${Server}):  Error Encountered in /Cloud/scripts/Cloud_Puppet.sh-2.1 on ${Server} - INVESTIGATE" ${MailList}
            exit 87
        fi 
        ###END OF DOUG NELSON'S BLOCK###

      else
         echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
         echo -e "The Puppet bootstrap RPM installation FAILED."
         echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
         echo -e "Please Investigate.\n"

         echo -e "\nCopying ${LogFile} to ${Satellite}:/Cloud/troubleshoot"
         scp -qo StrictHostKeyChecking=no -i /data/svcldadm/.ssh/id_dsa -i /data/svcldadm/.ssh/id_rsa ${LogFile} svcldadm@${Satellite}:/Cloud/troubleshoot/${Server}_${Script}.log; RC=${?}
         if [ ${RC} -eq 0 ]
         then
            echo -e "Successful."
         else
            echo -e "FAILED."
            echo -e "The copy of the ${LogFile} from ${Server} to ${Satellite}:/Cloud/troubleshoot failed. Good luck troubleshooting..." | mailx -s "Request ${Request} (${Server}):  Problem running /Cloud/scripts/Cloud_Puppet.sh-2.1 - INVESTIGATE" ${MailList}
         fi

         echo -e "Sending notification email to Cloud Administrators.\n\n"
         echo -e "There was an error encountered installing the Puppet bootstrap RPM on ${Server}.  Please investigate by reviewing the following log file on ${Satellite}: \n\n   /Cloud/troubleshoot/${Server}_${LogFile}" | mailx -s "Request ${Request} (${Server}):  Error Encountered in /Cloud/scripts/Cloud_Puppet.sh-2.1 on ${Server} - INVESTIGATE" ${MailList}
         exit 93
      fi
   else
      echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      echo -e "Staging the Puppet Facts FAILED."
      echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      echo -e "Please Investigate.\n"
      echo -e "Sending notification email to Cloud Administrators.\n\n"

      echo -e "\nCopying ${LogFile} to ${Satellite}:/Cloud/troubleshoot"
      scp -qo StrictHostKeyChecking=no -i /data/svcldadm/.ssh/id_dsa -i /data/svcldadm/.ssh/id_rsa ${LogFile} svcldadm@${Satellite}:/Cloud/troubleshoot/${Server}_${Script}.log; RC=${?}
      if [ ${RC} -eq 0 ]
      then
         echo -e "Successful."
      else
         echo -e "FAILED."
         echo -e "The copy of the ${LogFile} from ${Server} to ${Satellite}:/Cloud/troubleshoot failed. Good luck troubleshooting..." | mailx -s "Request ${Request} (${Server}):  Problem running /Cloud/scripts/Cloud_Puppet.sh-2.1 - INVESTIGATE" ${MailList}
      fi

      echo -e "There was an error encountered staging the Puppet Facts on ${Server}.  Please investigate by reviewing the following log file on ${Satellite}: \n\n   /Cloud/troubleshoot/${Server}_${LogFile}" | mailx -s "Request ${Request} (${Server}):  Error Encountered in /Cloud/scripts/Cloud_Puppet.sh-2.1 on ${Server} - INVESTIGATE" ${MailList}
      exit 91
   fi

   exit 0

else
   echo -e "\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   echo -e "The Puppet client install FAILED."
   echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   echo -e "Please Investigate.\n"

   echo -e "\nCopying ${LogFile} to ${Satellite}:/Cloud/troubleshoot"
   scp -qo StrictHostKeyChecking=no -i /data/svcldadm/.ssh/id_dsa -i /data/svcldadm/.ssh/id_rsa ${LogFile} svcldadm@${Satellite}:/Cloud/troubleshoot/${Server}_${Script}.log; RC=${?}
   if [ ${RC} -eq 0 ]
   then
      echo -e "Successful."
   else
      echo -e "FAILED."
      echo -e "The copy of the ${LogFile} from ${Server} to ${Satellite}:/Cloud/troubleshoot failed. Good luck troubleshooting..." | mailx -s "Request ${Request} (${Server}):  Problem running /Cloud/scripts/Cloud_Puppet.sh-2.1 - INVESTIGATE" ${MailList}
   fi
   echo -e "Sending notification email to Cloud Administrators.\n\n"
   echo -e "There was an error encountered trying to install the Puppet client on ${Server}.  Please investigate by reviewing the following log file on ${Satellite}: \n\n   /Cloud/troubleshoot/${Server}_${LogFile}" | mailx -s "Request ${Request} (${Server}):  Error Encountered in /Cloud/scripts/Cloud_Puppet.sh-2.1 on ${Server} - INVESTIGATE" ${MailList}
   exit 89
fi

exit
