#!/usr/bin/env bash
set -u

pushd ./resources
trap popd EXIT

PVC=image-cache
matching_secrets=`kubectl get pvc -o name | grep $PVC | wc -l`

if test $matching_secrets -eq 1; then
    echo "pvc already exists"
    exit 0
else
    echo "could not find pvc, installing..."
fi

set -e -o pipefail

kubectl apply -f image-cache-pvc.yaml