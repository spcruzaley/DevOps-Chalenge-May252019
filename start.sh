#!/bin/bash
clear
sleep 1

function banner {
echo -n $'\E[32m'
echo '   _____   ____  _    _    _____ _           _ _'
echo '  |  __ \ / __ \| |  | |  / ____| |         | | |'
echo '  | |  | | |  | | |  | | | |    | |__   __ _| | | ___ _ __   __ _  ___'
echo "  | |  | | |  | | |  | | | |    | '_ \ / _\` | | |/ _ \ '_ \ / _\` |/ _ \ "
echo '  | |__| | |__| | |__| | | |____| | | | (_| | | |  __/ | | | (_| |  __/'
echo '  |_____/ \____/ \____/   \_____|_| |_|\__,_|_|_|\___|_| |_|\__, |\___|'
echo '                                                             __/ |'
echo '                                                            |___/'
echo -n $'\E[00m'

}

function print {
  echo
  echo -n $'\E[36m' $1
  echo $'\E[00m'
}

function clean {
  if [ -d "/tmp/scripts/" ] ; then
    rm -rf /tmp/scripts
    print "/tmp/scripts directory cleaned"
  fi
}

function kubernetesConfig {
  print "Starting Kubernetes config"
  echo
  # Set DB data
  kubectl apply -f ./config/configmap.yml

  # Create the persistence storage
  kubectl apply -f ./config/storage.yml

  # Create postgres deploy and service
  kubectl create -f ./config/deployment.yml

  # Create postgres service
  kubectl create -f ./config/service.yml
}

function copyScripts {
  #create scripts directory if not exist
  if [ ! -d "/tmp/scripts/" ] ; then
    mkdir /tmp/scripts/
  fi

  #Copy needed files to execute SQL querys
  print "Copying files..."
  chmod +x ./db/script-db.sh
  cp ./db/create.sql /tmp/scripts/
  cp ./db/script-db.sh /tmp/scripts/

  #Copy needed files to send email alert
  chmod +x ./email/gmail.py
  chmod +x ./email/sendEmail.sh
  cp ./email/credentials.json /tmp/scripts/
  cp ./email/gmail.py /tmp/scripts/
  cp ./email/sendEmail.sh /tmp/scripts/
  cp ./email/token.pickle /tmp/scripts/
}

banner

# In case that /tmp/data directory exist, delete it
clean

# Kubernetes config
kubernetesConfig

# Copy neccesary scripts
copyScripts

print "Done !!!"
echo
