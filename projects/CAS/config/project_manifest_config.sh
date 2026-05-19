#!/bin/bash

	# define the database scripts mapping using the pipe character as a delimiter
	# The elements should contain encoded values with the "|" character as the delimiter: sql path (within container)|sql script file|User Secret Name|Password Secret Name|Script Password Secrets (this can be one or more optional pipe-delimited secret names when a password is injected into the script - examples include a CREATE USER command) 

	# create schemas, apex workspaces
	DB_SCRIPTS_MAP+=("${BUILD_PATH}/../../projects/CAS/modules/AAM/CAS/SQL|@dev_container_setup/create_docker_schemas.sql|oracle_admin_user|oracle_pwd|cas_pwd|cas_app_pwd|cas_apx_pwd")
	
	# deploy CAS DB
	DB_SCRIPTS_MAP+=("${BUILD_PATH}/../../projects/CAS/modules/AAM/CAS/SQL|@automated_deployments/deploy_dev_container.sql|cas_user|cas_pwd")

	# deploy CAS Apex app
	DB_SCRIPTS_MAP+=("${BUILD_PATH}/../../projects/CAS/modules/AAM/CAS/SQL|@automated_deployments/deploy_apex_dev_container.sql|cas_app_user|cas_app_pwd")

	# define the array of non-sensitive environment variable names that are exported for use in the container
	# CUSTOM_ENV_VARS+=()

	# define the array of compose files that are used by the individual projects (specify the path relative to the core/build directory
	COMPOSE_FILES+=("../../projects/CAS/build/cas_secrets.yml")
	
	# add the CAS secrets
	# Example:
		SECRET_MAPPING_ARR+=(
			["cas_pwd"]="CAS_DB_PWD"
			["cas_user"]="CAS_DB_USER"
			["cas_app_pwd"]="CAS_APP_PWD"
			["cas_app_user"]="CAS_APP_USER"
			["cas_apx_pwd"]="CAS_APX_PWD"
		)
	
	