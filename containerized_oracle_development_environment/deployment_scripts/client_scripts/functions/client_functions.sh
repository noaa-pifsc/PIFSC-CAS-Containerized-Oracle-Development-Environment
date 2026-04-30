#!/bin/bash

# function that executes the specified script action on the CODE containers
# the function accepts the following arguments:
# 1: passed script_action value (deploy, shutdown)
# 2: environment name (dev, test)
# 3: deploy destination (local, server)
# 4: rem_vol flag: (optional) remove the volumes associated with the docker stack name (yes) or retain them (no). This defaults to "no"
function proj_client_execute_container_scripts ()
{
	# build the list of compose files:
	local script_action="${1}"
	local env_name="${2}"
	local deploy_dest="${3}"
	local rem_vol="${4:-no}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "script_action" "env_name" "deploy_dest" "BUILD_PATH" "ORDS_ENABLED"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# declare variable to store the list of included .yml files when docker compose runs
	local compose_file

	# construct the COMPOSE_FILE value of included .yml files
	proj_client_construct_compose_file_string "compose_file" "${env_name}" "${deploy_dest}" "${ORDS_ENABLED}"
	
	# check if this is a deployment, if so load the local secret file so the container secret(s) can be created
	if [[ "${script_action}" == "deploy" ]]; then
		# Check if the secret file exists:
		if [ -f "${BUILD_PATH}/secrets/secrets.sh" ]; then
			# load the secrets
			source "${BUILD_PATH}"/secrets/secrets.sh

			# load any custom scripts that define configuration/secret variables
			proj_client_custom_load_scripts
			
		else
			echo "Error: ${FUNCNAME[0]}() function could not load the secrets/secrets.sh file" >&2
			return 1
		fi
	fi
	
	# check if this is a local or server deployment:
	if [[ "${deploy_dest}" == "local" ]]; then
		echo "This is a local deployment"

		# export the environment variables used directly in the docker compose files:
		cds_shared_export_env_vars "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "DBPORT" "DBHOST" "DBSERVICENAME" "STACK_NAME" "NETWORK_NAME"

		# export additional custom environment variables
		proj_client_custom_export_env_vars 

		# check the script_action value to determine if this is a deployment or shutdown script
		if [[ "${script_action}" == "deploy" ]]; then
			# this is a deployment

			# declare the function arguments
			local -A deploy_args=(
				["stack_name"]="${STACK_NAME}"
				["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
				["network_name"]="${NETWORK_NAME}"
				["deploy_dest"]="${deploy_dest}"
				["build_image"]="yes"
				["compose_path"]="${compose_file}"
				["build_path"]="${BUILD_PATH}" 
				["secret_name_prefix"]="${COMPOSE_PROJECT_NAME}_"
				["rem_vol"]="${rem_vol}"
			)

			# deploy the containers locally:
			cds_shared_deploy_container_stack "deploy_args"
		else
			# this is a shutdown script

			# shutdown the CODE containers to the host server associated with the $STACK_NAME
			cds_shared_remove_container_stack "${STACK_NAME}" "${NETWORK_NAME}" "${rem_vol}"
		fi
	else
		echo "This is a server deployment"
		
		# validate the bash variable values
		if ! cds_shared_validate_required_vars "CONFIG_DIR" "HOSTNAME" "HOST_SOURCE_PATH" "GIT_URL" "HOST_SCRIPTS_PATH" "SECRET_DATA_VAR_NAME" "SECRET_MAPPING_VAR_NAME"; then
			echo "Error: ${FUNCNAME[0]}() function required bash variable validation for server deployments failed" >&2
			return 1
		fi

		# declare global variables for the rem_vol, compose_file, and script_action values so they can be passed to the server script as environment variables
		REM_VOL="${rem_vol}"
		COMPOSE_FILE="${compose_file}"
		SCRIPT_ACTION="${script_action}"

		# declare environment variable string for the environment variables to be passed to the container host via the ssh call
		local env_var_string="$(cds_shared_generate_ssh_env_vars_string "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "PRIV_USER" "COMPOSE_FILE" "STACK_NAME" "NETWORK_NAME" "REM_VOL" "SCRIPT_ACTION")"

		# add the custom environment variables to the env_var_string variable
		env_var_string+="$(proj_client_custom_string_env_vars)"

#		echo "The value of the env_var_string is: ${env_var_string}"

		# assign the value of the process_secrets variable based on the script action value
		if [[ "${script_action}" == "deploy" ]]; then
			local process_secrets="yes"
		else
			local process_secrets="no"
		fi

		# declare the function arguments
		local -A remote_deploy_args=(
				["target_host"]="${HOSTNAME}"
				["source_path"]="${HOST_SOURCE_PATH}"
				["git_url"]="${GIT_URL}"
				["ssh_cmd"]="${env_var_string} bash ${HOST_SCRIPTS_PATH}/host_execute_CODE_scripts.sh"
				["secret_var"]="${SECRET_DATA_VAR_NAME}"
				["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
				["process_secrets"]="${process_secrets}"
			)
			
		# deploy the containers to the remote server
		cds_client_execute_remote_deployment "remote_deploy_args"
	fi
}
