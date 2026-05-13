#!/bin/bash

# this function loads the standard and default CODE configuration files and if the .active_project file is defined it will load the active project configuration
# the function accepts the following arguments:
# 1: include_directory path, this will be used to load the resources based on their relative paths
# 2: execution_type: (client, host, container) to indicate if the function is being executed on a client which loads the bash variables defined in default_CODE_config.sh and the project-specific runtime configuration files, or on the host which loads only the project hierarchy configuration and pre/post CODE configuration files, or on the container that loads only the project hierarchy configuration and pre CODE configuration files

function code_shared_load_CODE_config()
{
	local include_dir_path="${1}"
	local execution_type="${2}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "include_dir_path" "execution_type"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi


	# check if the .active_project is defined
	if [[ -f "${include_dir_path}/../../../../projects/.active_project" ]]; then
		# the .active_project is defined, load the corresponding project-specific configuration files

		# include the projects/.active_project to define which project folder is the active project (defines ACTIVE_PROJECT_NAME variable)
		source "${include_dir_path}/../../../../projects/.active_project"
	fi

	# include the container configuration variables
	source "${include_dir_path}/../../config/pre_CODE_config.sh"

	# check if this function is running on the client, if so load the runtime configuration
	if [[ "${execution_type}" == "client" ]]; then
		# load the default CODE runtime configuration
		source "${include_dir_path}/../../config/default_CODE_runtime_config.sh"

		# check if there is an ACTIVE_PROJECT_NAME defined and if the corresponding project runtime configuration file exists
		if [[ -n "${ACTIVE_PROJECT_NAME}" && -f "${include_dir_path}/../../../../projects/${ACTIVE_PROJECT_NAME}/config/project_runtime_config.sh" ]]; then

			echo "The active project configuration file exists and this function is running on the client, load ${ACTIVE_PROJECT_NAME}/config/project_runtime_config.sh"
			# load the configuration from the active project preceded by all projects it depends on
			source "${include_dir_path}/../../../../projects/${ACTIVE_PROJECT_NAME}/config/project_runtime_config.sh"
		fi
	fi

	# check if there is an ACTIVE_PROJECT_NAME defined and if the corresponding project hierarchy configuration file exists
	if [[ -n "${ACTIVE_PROJECT_NAME}" && -f "${include_dir_path}/../../../../projects/${ACTIVE_PROJECT_NAME}/config/project_hierarchy_config.sh" ]]; then
		echo "The active project configuration file exists, load ${ACTIVE_PROJECT_NAME}/config/project_hierarchy_config.sh"
	
		# load the configuration from the active project preceded by all projects it depends on
		source "${include_dir_path}/../../../../projects/${ACTIVE_PROJECT_NAME}/config/project_hierarchy_config.sh"
	fi

	# check if this function is running on the host, if so load the runtime configuration
	if [[ "${execution_type}" != "container" ]]; then

		# include the CODE configuration that requires the project-specific configurations to be declared first
		source "${include_dir_path}/../../config/post_CODE_config.sh"
	fi
}