#!/bin/bash

# function that deploys the containers for a development environment
# the function accepts the following arguments:
# 1: environment name (dev, test)
# 2: deploy destination (local, server)
function proj_client_build_deploy_dev_environment ()
{
	# build the list of compose files:
	local env_name="${1}"
	local deploy_dest="${2}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "env_name" "deploy_dest" "BUILD_PATH" "ORDS_ENABLED"; then
        echo "Error: proj_client_build_deploy_dev_environment() function required bash variable validation failed" >&2
        return 1
	fi

	# change to the defined build_path so the docker commands can be run relative to the build path directory
	cd "${BUILD_PATH}"
	
	
	# Determine the correct OS path separator for the COMPOSE_FILE environment variable for linux server deployments and for local Mac/Linux deployments
	local compose_sep=":"

	# check if the deployment destination is local
	if [[ "${deploy_dest}" == "local" ]]; then	
		# this is a local deployment, check if this is a windows machine
		case "$(uname -s)" in
			MINGW*|CYGWIN*|MSYS*)
				# this is a windows machine for a local deployment, use the semicolon separator
				compose_sep=";"
				;;
		esac
	fi
	
	# build the list of compose files using $compose_sep as the separator for the target deployment machine:
	# include the code-db and code-db-ords-deploy services, and custom docker compose to integrate additional services
	declare COMPOSE_FILE="./CODE-db-deploy.yml${compose_sep}./custom-docker-compose.yml"

	# check if this is intended for a dev environment (retain database and ords volumes across container restarts) 
	if [ "${env_name}" == "dev" ]; then
		# add in the named volume for the db service
		COMPOSE_FILE="${COMPOSE_FILE}${compose_sep}./CODE-db-named-volume.yml"
	fi
	
	# check if the ORDS/Apex service is enabled
	if [ "${ORDS_ENABLED}" == "yes" ]; then
		# include the ORDS service
		COMPOSE_FILE="${COMPOSE_FILE}${compose_sep}./CODE-ords.yml"
	fi

	# check if this is a local or server deployment:
	if [[ "${deploy_dest}" == "local" ]]; then
		echo "This is a local deployment"
	
		# declare COMPOSE_FILE as an environment variable
		export COMPOSE_FILE
		
		echo "the value of COMPOSE_FILE is: ${COMPOSE_FILE}"

		# Execute natively for local Desktop Deployments using the injected COMPOSE_FILE
		docker compose --env-file ./.env up -d --build
	else
		echo "This is a server deployment"

		# For Server Deployments, we route through the CDS Engine.
		local target_host=""
		read -rp "Enter target container hostname: " target_host < /dev/tty

		# Define array for remote deployment using the CDS standard vocabulary
		local -A remote_deploy_args=(
			["container_hostname"]="${target_host}"
			["container_host_project_path"]="${CONTAINER_HOST_SOURCE_PATH:-/opt/code-deployment}"
			["container_git_url"]="${GIT_URL:-git@github.com:your-repo.git}"
			["config_data_var_name"]="CONFIG_DATA"
			["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
			["parse_config_data"]="yes"
			# Inject the COMPOSE_FILE variable to the remote host natively
			["remote_ssh_cmd"]="export COMPOSE_FILE='${COMPOSE_FILE}'; bash deployment_scripts/host_scripts/host_deploy_CODE.sh"
		)

		# Route to the remote deployment engine
		cds_client_execute_remote_deployment "remote_deploy_args"
	fi
}