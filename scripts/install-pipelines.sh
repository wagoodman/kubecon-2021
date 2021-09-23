#!/usr/bin/env bash
set -eu -o pipefail

pushd ./pipelines
trap popd EXIT

# install all pipelines defined locally
for FILE in * ; do
    echo "● installing pipeline $FILE"
    kubectl apply -f ${FILE}
done