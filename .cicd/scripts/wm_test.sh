#!/bin/bash -x
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

(
	cd "${TESTS_DIR}"
	pwd
	ls -al ./rt.sh
)

export GIT_URL=${GIT_URL:-"ufs-weather-model"}
export CHANGE_ID=${CHANGE_ID:-"develop"}

pwd
echo "GIT_URL=${GIT_URL}"
echo "CHANGE_ID=${CHANGE_ID}"
echo "NODE_NAME=${NODE_NAME}"
echo "USER=${USER}"
echo "UFS_PLATFORM=<${UFS_PLATFORM}>"
echo "UFS_COMPILER=<${UFS_COMPILER}>"
echo "WM_REGRESSION_TESTS=<${WM_REGRESSION_TESTS:-""}>"
echo "WM_OPERATIONAL_TESTS=<${WM_OPERATIONAL_TESTS:-""}>"
echo "WM_CREATE_BASELINE=<${WM_CREATE_BASELINE:-""}>"
echo "WM_POST_TEST_RESULTS=<${WM_POST_TEST_RESULTS:-""}>"

machine=${NODE_NAME}
echo "machine=<${machine}>"
machine_id=${UFS_PLATFORM,,}
echo "machine_id=<${machine_id}>"

workspace=$(pwd)
export workspace

status=0


	echo "Pipeline Reqression Tests on ${UFS_PLATFORM} complete. status=${status}" | tee "${workspace}/${UFS_PLATFORM}-status"

exit "${status}"
