#! /bin/bash

# define a list of configuration variables that drive the behavior of the database container deployment scripts 

	# determine current folder path (containerized_oracle_development_environment/deployment_scripts/config)
	CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# determine where the designated container subfolder in the local filesystem is (/containerized_oracle_development_environment):
	BUILD_PATH="${CONFIG_DIR}/../../"
