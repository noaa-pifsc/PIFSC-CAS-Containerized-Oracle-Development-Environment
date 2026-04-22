#!/bin/bash

# define the host's source root path
declare HOST_SOURCE_PATH="/tmp/${SOURCE_FOLDER_NAME}"

# define the path to the folder where the host bash scripts are contained
declare HOST_SCRIPTS_PATH="${HOST_SOURCE_PATH}/containerized_oracle_development_environment/deployment_scripts/host_scripts"

# define the privileged container user
declare PRIV_USER="docker-user"