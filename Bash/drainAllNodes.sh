#!/usr/bin/env bash
umask 022

#--------------------------------------------------------------#
#       Script Name:    drainAllNodes.sh
#       Author:         Doug Nelson
#       Created         9/12/2018
#--------------------------------------------------------------#

WORKERS=$(grep -i "worker" /Cloud/dockerManifests/${1} | awk -F: '{print $1}')

for WORKER in ${WORKERS}
do
        USER="svcdockr"
        MGR=$(grep -i -m 1 "manager" /Cloud/dockerManifests/${1} | awk -F: '{print $1}')
        
        ping -c -w2 ${WORKER} >/dev/null 2>&1 ; WORKER_PING=${?}
        ping -c -w2 ${MGR} >/dev/null 2>&1 ; MGR_PING=${?}

        if [ ${WORKER_PING} -eq 0 && ${MGR_PING} -eq 0 ]
        then
                ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -qo StrictHostKeyChecking=no ${MGR} "docker node update --availability drain ${WORKER}" ; RC=${?}

                if [ ${RC} -eq 0 ]
                then
                        ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -qo StrictHostKeyChecking=no ${WORKER} "init 6" ; RC=${?}

                        if [ ${RC} -eq 0 ]
                        then
                                sleep 300
                                ping -c -w2 ${WORKER} >/dev/null 2>&1 ; RC=${?}

                                if [ ${RC} -eq 0 ]
                                then
                                        ssh -qo BatchMode=yes -l ${USER} -i /data/${USER}/.ssh/id_rsa -qo StrictHostKeyChecking=no ${MGR} "docker node update --availability active ${WORKER}"

                                else
                                        echo "There was an issue making ${WORKER} an active node in the swarm after reboot! Please investigate!"
                                fi
                        else
                                echo "There was an issue trying to reboot ${WORKER}! Please investigate!"
                        fi
                else
                        echo "There was an issue draining the ${WORKER} node in the swarm! Please investigate!"
                fi
        else
                echo "Some of the nodes in the swarm are not responding to PING! Check that all nodes are up!"
        fi
done
exit
