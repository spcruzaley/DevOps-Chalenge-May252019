#!/bin/bash

function logger {
  echo
  echo $'\E[36mINFO: '$1
  echo $'\E[00m\n'
}

# IMPORTANT NOTE: The app name should be the same as the deployment.yml
# file has on app tag
pod=`kubectl get pods -l app=postgres -o custom-columns=:metadata.name`
# Remove return
pod=$(echo $pod|tr -d '\n')

if [ -z $pod ] ; then
  logger "POD don't exist"
  exit 0
fi

logger "Shutting down Kubernetes services..."

kubectl delete service postgres >> log 2>/dev/null
kubectl delete deployment postgres >> log 2>/dev/null
kubectl delete configmap postgres-config >> log 2>/dev/null
kubectl delete persistentvolumeclaim postgres-pv-claim >> log 2>/dev/null
kubectl delete persistentvolume postgres-pv-volume >> log 2>/dev/null

lastStatus='0'
tag='Terminating'
status=''
spin='-\|/'

i=0
while [ $lastStatus != 1 ]
do
  i=$(( (i+1) %4 ))
  printf "\E[33m\r$tag ${spin:$i:1}"
  sleep .1
  kubectl get pod $pod -o jsonpath="{.status.containerStatuses[*].state.waiting.reason}" >> log 2>/dev/null
  lastStatus=$?
done

echo
logger "Shutdown completed !"
