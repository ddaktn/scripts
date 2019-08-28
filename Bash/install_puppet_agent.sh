#!/bin/bash

numargs=$#
if [[ $numargs -ne 3 ]]
  then
    echo "This script requires three arguments.  See usage:"
    echo " "
    echo "`basename $0` <environment> <rhel_version> <puppet_version>"
    echo "e.g. - deploy to ITG on RHEL v6:  `basename $0` itg 6 5.5.6"
    echo "e.g. - deploy to CAT on RHEL v7:  `basename $0` cat 7 5.5.6"
    exit 1
fi

puppetenv=$1
rhelver=$2
puppetver=$3
yuminstall="yum install -y -q -e 0"

export http_proxy=https://proxy_server:8020
export proxy=https://proxy_server:8020
echo "proxy=https://proxy_server:8020" >> /root/.curlrc

echo ">>>> Installing puppet repo"
echo ">>>>"
if yum list installed puppet5-release.noarch >/dev/null 2>&1; then

  echo ">>>> puppet repo is already installed"

else
  echo ">>>> puppet repo is not installed, so install it"

  rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-el-${rhelver}.noarch.rpm

  if [ $? -eq 0 ]; then

    echo ">>>>"
    echo ">>>> Repo install was successful"

    echo ">>>> Adding proxy reference to the repo"
    cp /etc/yum.repos.d/puppet5.repo /etc/yum.repos.d/puppet5.repo.orig
    awk '/gpgcheck/ { print; print "proxy=https://proxy_server:8020"; next }1' /etc/yum.repos.d/puppet5.repo > /tmp/repo
    mv /tmp/repo /etc/yum.repos.d/puppet5.repo

  else
    echo ">>>>"
    echo ">>>> Repo install was not successful - exiting script"
    exit 1
  fi

fi

echo ">>>>"
echo ">>>> Installing puppet agent"
echo ">>>>"
if yum list installed puppet-agent.x86_64 >/dev/null 2>&1; then

  echo ">>>> puppet agent is already installed"
  exit 1

else
  echo ">>>> puppet agent is not installed, so install it"

  ${yuminstall} puppet-agent-${puppetver}-1.el${rhelver}

  if [ $? -eq 0 ]; then

    echo ">>>>"
    echo ">>>> Puppet agent install was successful"

  else
    echo ">>>>"
    echo ">>>> Puppet agent install was not successful - exiting script"
    exit 1

  fi
fi

echo ">>>>"
echo ">>>> Adding properties to puppet.conf"
echo ">>>>"

pconf="/etc/puppetlabs/puppet/puppet.conf"

if [[ -f ${pconf} ]]; then

  echo "[agent]" | tee -a $pconf
  echo "environment = ${puppetenv}" | tee -a $pconf
  echo "report = true" | tee -a $pconf
  echo "pluginsync = true" | tee -a $pconf

else
  echo ">>>>"
  echo ">>>> File ${pconf} does not exist - exiting script"
  exit 1

fi

echo ">>>>"
echo ">>>> Configuring puppet agent service"
echo ">>>>"

/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

if [ $? -eq 0 ]; then

  echo ">>>>"
  echo ">>>> Puppet agent service configured successfully"

else
  echo ">>>>"
  echo ">>>> Puppet agent service not configured successfully - exiting script"
  exit 1

fi


echo ">>>>"
echo ">>>> Installing version lock if not installed"
echo ">>>>"

if yum list installed yum-plugin-versionlock.noarch >/dev/null 2>&1; then

  echo ">>>> version lock is already installed"

else

  echo ">>>> version lock is not installed, so install it"

  ${yuminstall} yum-plugin-versionlock

  if [ $? -eq 0 ]; then

    echo ">>>>"
    echo ">>>> version lock install was successful"

  else
    echo ">>>>"
    echo ">>>> version lock install was not successful - exiting script"
    exit 1
  fi
fi

echo ">>>>"
echo ">>>> Apply version lock "
echo ">>>>"

yum versionlock puppet-agent

if [ $? -eq 0 ]; then

  echo ">>>>"
  echo ">>>> version lock on puppet-agent was successful"

else

  echo ">>>>"
  echo ">>>> version lock on puppet-agent was not successful - exiting script"
  exit 1

fi

exit 0
