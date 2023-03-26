#!/usr/bin/env bash

set -e
set -x

if [ -z "$COMMANDS" ]; then
  echo "COMMANDS is not set. Quitting."
  exit 1
fi

if [ -z "$REGISTRY_URL" ]; then
  echo "REGISTRY_URL is not set. Quitting."
  exit 1
fi

if [ -z "$REGISTRY_USER" ]; then
  echo "no authentication"
else
  if [ -z "$REGISTRY_PASSWORD" ]; then
    echo "REGISTRY_PASSWORD required if REGISTRY_USER is set. Quitting."
    exit 1
  fi
fi

PROTOCOL=""
CAN_REPO_ADD=1
if [ -z "$OCI_ENABLED_REGISTRY" ]; then
  echo "NOT OCI registry"
elif [ "$OCI_ENABLED_REGISTRY" == "1" ] || [ "$OCI_ENABLED_REGISTRY" == "True" ] || [ "$OCI_ENABLED_REGISTRY" == "TRUE" ]; then
  PROTOCOL="oci://"
  #helm dont support add for oci registries
  CAN_REPO_ADD=0
  OCI_ENABLED_REGISTRY="True"
fi

helm version -c

if ! [ -z "$REGISTRY_USER" ]; then
  if [[ $CAN_REPO_ADD == 1 ]]; then
    if [ -z "$REGISTRY_REPO_NAME" ]; then
      REGISTRY_REPO_NAME="SS_SOME_REPO_NAME"
    fi
    echo ${REGISTRY_PASSWORD} | helm repo add ${REGISTRY_REPO_NAME} ${REGISTRY_URL} --username ${REGISTRY_USER} --password-stdin ${HELM_REPO_ADD_FLAGS}
  else
    echo ${REGISTRY_PASSWORD} | helm registry login --username ${REGISTRY_USER} --password-stdin ${REGISTRY_URL}
  fi
fi

IFS=';' read -ra COMMANDS_ARRAY <<< "$COMMANDS"

#executes
for I_COMMAND in "${COMMANDS_ARRAY[@]}"; do
  printf 'execute %s\n' "${I_COMMAND}"
  helm ${I_COMMAND}
done
