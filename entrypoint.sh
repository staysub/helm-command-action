#!/usr/bin/env bash

set -e
set -x

if [ -z "$CHART_DIR_PATH_LIST" ]; then
  echo "CHART_DIR_PATH_LIST is not set. Quitting."
  exit 1
fi

if [ -z "$REGISTRY_URL" ]; then
  echo "REGISTRY_URL is not set. Quitting."
  exit 1
fi

if [[ -z "$REGISTRY_USER" ]]; then
  echo "no authentication"
else
   if [ -z "$REGISTRY_PASSWORD" ]; then
      echo "REGISTRY_PASSWORD required if REGISTRY_USER is set. Quitting."
      exit 1
    fi
fi

PROTOCOL=""
CAN_REPO_ADD=1
if [ "$OCI_ENABLED_REGISTRY" == "1" ] || [ "$OCI_ENABLED_REGISTRY" == "True" ] || [ "$OCI_ENABLED_REGISTRY" == "TRUE" ]; then
  PROTOCOL="oci://"
  #helm dont support add for oci registries
  CAN_REPO_ADD=0
  OCI_ENABLED_REGISTRY="True"
fi

helm version -c

if [[ $REGISTRY_USER ]]; then
  if [[ $CAN_REPO_ADD == 1 ]]; then
    if [ -z "$REGISTRY_REPO_NAME" ]; then
      REGISTRY_REPO_NAME="SS_SOME_REPO_NAME"
    fi
    echo ${REGISTRY_PASSWORD} | helm repo add ${REGISTRY_REPO_NAME} ${REGISTRY_URL} --username ${REGISTRY_USER} --password-stdin ${HELM_REPO_ADD_FLAGS}
  else
    echo ${REGISTRY_PASSWORD} | helm registry login --username ${REGISTRY_USER} --password-stdin ${REGISTRY_URL}
  fi
fi

SOURCE_DIR=""

#Package all charts
TMP_DIR_PREFIX="/tmp/charts/"
while IFS= read -r I_CHART_DIR_PATH_LIST; do
  I_CHART_DIR_PATH="${SOURCE_DIR}/${I_CHART_DIR}"

  helm inspect chart ${I_CHART_DIR_PATH} ${HELM_INSPECT_FLAGS}
  helm dependency update ${I_CHART_DIR_PATH} ${HELM_DEPENDENCY_UPDATE_FLAGS}

  TMP_PACKAGE_DIR="${TMP_DIR_PREFIX}/${I_CHART_DIR}"
  mkdir -p ${TMP_PACKAGE_DIR}

  helm package . -d ${TMP_PACKAGE_DIR} ${HELM_PACKAGE_FLAGS}
done <<<"$CHART_DIR_PATH_LIST"

COMPLETE_REGISTRY_URL="${PROTOCOL}${REGISTRY_URL}"

HELM_SUPPORTS_PROTOCOL=1

if [[ $COMPLETE_REGISTRY_URL == http:* ]]; then
  HELM_SUPPORTS_PROTOCOL=0
fi
#push all generated charts
while IFS= read -r I_CHART_DIR_PATH_LIST; do
  I_CHART_DIR_PATH="${SOURCE_DIR}/${I_CHART_DIR}"
  TMP_PACKAGE_DIR="${TMP_DIR_PREFIX}/${I_CHART_DIR}"

  for FILE_PATH in $(ls -1 ${TMP_PACKAGE_DIR}/*.tgz); do
    if [[ "${OCI_ENABLED_REGISTRY}" == "True" ]]; then
      helm push ${FILE_PATH} ${COMPLETE_REGISTRY_URL} ${HELM_PUSH_FLAGS}
    else
      helm cm-push ${FILE_PATH} ${COMPLETE_REGISTRY_URL} ${HELM_PUSH_FLAGS}
    fi
  done
done <<<"$CHART_DIR_PATH_LIST"
echo "done"