#!/usr/bin/env bash
set -u

export SECRET_NAME=gh-container-registry-secret
export CONTAINER_REGISTRY_SERVER='https://ghcr.io'
# set the following variables (NOT HERE THOUGH, since this gets checked in)
# export CONTAINER_REGISTRY_USER='<your registry user>'
# export CONTAINER_REGISTRY_PASSWORD='<your registry user password>'

matching_secrets=`kubectl get secret -o name | grep $SECRET_NAME | wc -l`

if test $matching_secrets -eq 1; then
    echo "secrets already exists"
    exit 0
else
    echo "could not find secrets, installing..."
fi

set -e -o pipefail

kubectl create secret docker-registry $SECRET_NAME \
  --docker-server=$CONTAINER_REGISTRY_SERVER \
  --docker-username=$CONTAINER_REGISTRY_USER \
  --docker-password=$CONTAINER_REGISTRY_PASSWORD


kubectl create sa build-bot

kubectl patch serviceaccount build-bot -p "{\"secrets\": [{\"name\": \"$SECRET_NAME\"}]}"

kubectl get sa -o yaml
