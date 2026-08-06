#!/bin/bash
set -eu
export UFS_PLATFORM=${UFS_PLATFORM:-${NODE_NAME,,}}
export UFS_COMPILER=${UFS_COMPILER:-intel}

SCRIPT_REALPATH=$(realpath "${BASH_SOURCE[0]}")
SCRIPTS_DIR=$(dirname "${SCRIPT_REALPATH}")
UFS_MODEL_DIR=$(realpath "${SCRIPTS_DIR}/../..")
readonly UFS_MODEL_DIR
echo "UFS MODEL DIR: ${UFS_MODEL_DIR}"

export CC=${CC:-mpicc}
export CXX=${CXX:-mpicxx}
export FC=${FC:-mpif90}

BUILD_DIR=${BUILD_DIR:-${UFS_MODEL_DIR}/build}
TESTS_DIR=${TESTS_DIR:-${UFS_MODEL_DIR}/tests}

cd "${UFS_MODEL_DIR}"
echo "UFS_PLATFORM=<${UFS_PLATFORM}>"
echo "UFS_COMPILER=<${UFS_COMPILER}>"

pwd
echo "NODE_NAME=${NODE_NAME}"
echo "UFS_PLATFORM=${UFS_PLATFORM}"
echo "UFS_COMPILER=${UFS_COMPILER}"
workspace=$(pwd)
export workspace
machine=${NODE_NAME}
echo "machine=<${machine}>"
machine_id=${UFS_PLATFORM,,}
if [[ ${UFS_PLATFORM} =~ clusternoaa ]] ; then
	machine_id="noaacloud"
fi
echo "machine_id=<${machine_id}>"

/usr/bin/time -p \
	-o "${WORKSPACE:-$(pwd)}/${UFS_PLATFORM}-${UFS_COMPILER}-time-wm_init.json" \
	-f '{\n  "cpu": "%P"\n, "memMax": "%M"\n, "mem": {"text": "%X", "data": "%D", "swaps": "%W", "context": "%c", "waits": "%w"}\n, "pagefaults": {"major": "%F", "minor": "%R"}\n, "filesystem": {"inputs": "%I", "outputs": "%O"}\n, "time": {"real": "%e", "user": "%U", "sys": "%S"}\n}' \
	pwd

OWNER="ufs-community"
REPO="ufs-weather-model"
PR_NUMBER="123"
LABEL="${NODE_NAME}-CI-RUNNING"
TOKEN="${GITHUB_TOKEN}"

# Check if the node-CI-RUNNING label already exists on the PR
HAS_LABEL=$(curl -s -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://github.com" \

  | jq --arg lbl "$LABEL" '[.[] | select(.name == $lbl)] | length')

# If length is 0, the label does not exist, so add it
if [ "$HAS_LABEL" -eq 0 ]; then
  curl -s -X POST -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -d "{\"labels\": [\"$LABEL\"]}" \
    "https://github.com"
  echo "Label '$LABEL' added."
else
  echo "Label '$LABEL' already exists on PR."
fi

