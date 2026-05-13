#!/bin/bash

# function that exports custom environment variable definitions
function proj_client_custom_export_env_vars ()
{
	# export custom environment variables
	echo "exporting custom environment variables"
	
	# example:
	# cds_shared_export_env_vars "VAR1" "VAR2"

}

# function that returns a string with environment variable definition  
function proj_client_custom_string_env_vars ()
{
    local output_str=""

	# example:
	#   output_str+="${var_name}=\"${!var_name}\" "
    
    # echo the result without the trailing space
    echo " ${output_str% }"
}

# function that loads custom scripts that define configuration and/or secret values
function proj_client_custom_load_scripts ()
{
	# load any files that contain required configuration and/or secret values 
	
	echo "loading custom configuration/secret values"

	# examples:
	# source "${BUILD_PATH}/custom_config.sh"
	# source "${BUILD_PATH}/secrets/db_secrets.sh"

}