#!/usr/bin/env bash
set -eu -o pipefail

pushd ./tasks
trap popd EXIT

install_refs() {
    echo "● installing task references from $1"
    while IFS= read -r LINE; do
        IFS=":" read NAME VERSION <<< "$LINE"

        matching_tasks=`kubectl get task/$NAME -o name | wc -l`
        if test $matching_tasks -eq 0; then
            tkn hub install task $NAME --version $VERSION
        else
            tkn hub reinstall task $NAME --version $VERSION
        fi
    done < $1
}

export -f install_refs

# install any tasks from references
find . -name '*-refs.yaml' | xargs -I {} bash -c 'install_refs "{}"'
