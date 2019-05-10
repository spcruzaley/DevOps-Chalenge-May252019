#!/bin/bash

function print {
  echo
  echo -n $'\E[36m' $1
  echo $'\E[00m'
}

print "Shutting down Kubernetes services..."
echo

kubectl delete service postgres
kubectl delete deployment postgres
kubectl delete configmap postgres-config
kubectl delete persistentvolumeclaim postgres-pv-claim
kubectl delete persistentvolume postgres-pv-volume
