#!/bin/bash

# function that processes user runtime arguments and executes the specified script action (deploy or shutdown)
# the function accepts the following arguments:
# 1: passed script_action value (deploy, shutdown)
# 2: passed env_name value (dev, test)
# 3: passed deploy_dest: deployment destination value (local, server)
# 4: rem_vol flag: (optional) remove the volumes associated with the docker stack name (yes) or retain them (no). This defaults to "no"
function code_client_process_arguments_execute_container_scripts ()
{
	local script_action_name="script_action"
	local env_var_name="env_name"
	local dest_var_name="deploy_dest"
	local rem_vol_var_name="rem_vol"
	local passed_script_action="${1:-}"
	local passed_env_value="${2:-}"
	local passed_deploy_value="${3:-}"
	local passed_rem_vol_value="${4:-no}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"script_action_name" "env_var_name" "dest_var_name"; then
		echo "Error: ${FUNCNAME[0]}() function required function argument validation failed" >&2
		return 1
	fi

	# save/prompt for script action type into the specified local variable
	cds_client_set_script_action_var "${script_action_name}" "${passed_script_action}"

	# save/prompt for environment name into the specified local variable
	cds_client_set_env_name_var "${env_var_name}" "${passed_env_value}" 

	# save/prompt for deployment destination (local, server) for Dual-Target capability
	cds_client_set_deploy_dest_var "${dest_var_name}" "${passed_deploy_value}"

	# save/prompt for remove volume flag (yes, no)
	cds_client_set_rem_vol_var "${rem_vol_var_name}" "${passed_rem_vol_value}"

	# notify the user of the user-defined runtime value
	echo "Runtime Argument Values:"
	echo "script_action: ${!script_action_name}"
	echo "env_name: ${!env_var_name}"
	echo "deploy_dest: ${!dest_var_name}"
	echo "rem_vol: ${!rem_vol_var_name}"

	# execute the specified script action on the CODE containers 
	proj_client_execute_container_scripts "${!script_action_name}" "${!env_var_name}" "${!dest_var_name}" "${!rem_vol_var_name}"

	# notify the user that the script action has finished executing
	echo "The ${!script_action_name} action was successfully executed on the docker container(s) - environment name: ${!env_var_name}, deployment destination: ${!dest_var_name}, remove volume: ${!rem_vol_var_name}"
}

# the function returns the compose separator character based on the container deployment environment
function code_client_get_compose_separator()
{
	local compose_sep_name="${1}"
	local deploy_dest="${2}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars "compose_sep_name" "deploy_dest"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# define the reference to the local variable
	local -n compose_sep_ref="${compose_sep_name}"

	# Determine the correct OS path separator for the COMPOSE_FILE environment variable for linux server deployments and for local Mac/Linux deployments
	compose_sep_ref=":"

	# check if the deployment destination is local
	if [[ "${deploy_dest}" == "local" ]]; then	
		# this is a local deployment, check if this is a windows machine
		case "$(uname -s)" in
			MINGW*|CYGWIN*|MSYS*)
				# this is a windows machine for a local deployment, use the semicolon separator
				compose_sep_ref=";"
				;;
		esac
	fi
}