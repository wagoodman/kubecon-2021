#!/usr/bin/env bash
set -eu -o pipefail

pushd ./tasks
trap popd EXIT

# install all tasks defined locally
for FILE in * ; do
    if [[ ${FILE} != *"-refs.yaml" ]];then
        echo "● installing custom task $FILE"
        kubectl apply -f ${FILE}
    fi
done