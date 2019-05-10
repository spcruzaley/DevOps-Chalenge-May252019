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
  echo -n $'\E[36mINFO: '$1
  echo $'\E[00m'
}

function loading {
  spin='-\|/'

  i=0
  while [ $1 == 0 ]
  do
    i=$(( (i+1) %4 ))
    printf "\E[33m\r$2 ${spin:$i:1}"
    sleep .1
  done
}

function clean {
  if [ -d "/tmp/scripts/" ] ; then
    rm -rf /tmp/scripts
    print "/tmp/scripts directory cleaned"
  fi
}

function kubernetesConfig {
  print "Starting Kubernetes config"
  # Set DB data
  kubectl apply -f ./config/configmap.yml > log 2>/dev/null

  # Create the persistence storage
  kubectl apply -f ./config/storage.yml >> log 2>/dev/null

  # Create postgres deploy and service
  kubectl create -f ./config/deployment.yml >> log 2>/dev/null

  # Create postgres service
  kubectl create -f ./config/service.yml >> log 2>/dev/null

  #Copy scripts needed (for DB & email)
  copyScripts
}

function copyScripts {
  #create scripts directory if not exist
  if [ ! -d "/tmp/scripts/" ] ; then
    mkdir /tmp/scripts/
  fi

  #Copy needed files to execute SQL querys
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

function podStatus {
  # IMPORTANT NOTE: The app name should be the same as the deployment.yml
  # file has on app tag
  pod=`kubectl get pods -l app=postgres -o custom-columns=:metadata.name`
  # Remove return
  pod=$(echo $pod|tr -d '\n')
  print "pod/${pod} created"

  lastStatus=''
  spin='-\|/'
  ready='---'
  statusForRunning=''
  statusForError=''

  print "This task could be take some time."
  echo 
  i=0
  while [[ ( ! $statusForError =~ "rror" && -z $statusForRunning) ]]
  do
    i=$(( (i+1) %4 ))
    printf "\r$ready - Status: $phaseStatus $statusForError $statusForRunning ${spin:$i:1}"
    sleep .1
    statusForError=`kubectl get pod $pod -o jsonpath="{.status.containerStatuses[*].state.waiting.reason}"`
    statusForRunning=`kubectl get pod $pod -o jsonpath="{.status.containerStatuses[*].state.running.startedAt}"`
    ready=`kubectl get pod $pod -o jsonpath="\E[33m[Ready: {.status.containerStatuses[*].ready}]"`
    phaseStatus=`kubectl get pod $pod -o jsonpath="{.status.phase}"`
  done
  if [[ $statusForError =~ "rror" ]] ;  then
    reason=`kubectl get pod $pod -o jsonpath="Status: {.status.containerStatuses[*].state.waiting.reason}"`
    printf "\n\E[41m\n"
    printf "Something wrong happened\n"
    printf "Status: $statusForError\n"
    printf "Reason: $reason\E[00m\n"
    sh ./stop.sh
    exit 0
  fi
  echo
  startedAt=`kubectl get pod $pod -o jsonpath="{.status.containerStatuses[*].state.running.startedAt}"`
  printf "\r$ready - $phaseStatus started at: $startedAt\E[00m\n"
  print "Pod Running successfully !"
}

banner

# In case that /tmp/data directory exist, delete it
clean

# Kubernetes config
kubernetesConfig
podStatus
