#!/bin/bash

#-----------------------------------------------------------------------------
# shared_functions.sh:
# this file defines shared functions that are used for this specific 
# container application for container deployments
#-----------------------------------------------------------------------------

# function to deploy the CODE containers
function proj_deploy_CODE_containers ()
{
	local build_path="${1}"
	local compose_file="${2}"

	if ! cds_shared_validate_required_vars "build_path" "compose_file"; then 
        echo "Error: proj_deploy_CODE_containers() function argument validation failed" >&2
        return 1
    fi

	# change to the designated build path so the containers can be stopped (if running) and started
	cd "${build_path}"

	# declare COMPOSE_FILE as an environment variable
	export COMPOSE_FILE="${compose_file}"

	# export ORACLE_PWD so it can be used for the code-db and code-ords containers
	export ORACLE_PWD

	# remove the containers if they are already running using the injected COMPOSE_FILE
	docker compose down

	# Execute natively for local Desktop Deployments using the injected COMPOSE_FILE
	docker compose up -d --build

	# unset the ORACLE_PWD secret value
	unset ORACLE_PWD
}


# function that defines the environment variable bash block that will define the environment variables for inclusion when the build/run container bash scripts execute
# Accepts 2 parameters: 
# 1: the environment name
# 2: the compose path include file string
function proj_shared_define_env_vars_block()
{
	local env_name="${1}"
	local compose_file="${2}"

	# echo the strictly local runtime variables natively
	echo "export ENV_NAME='${env_name}'"
	echo "export COMPOSE_FILE='${compose_file}'"
}
