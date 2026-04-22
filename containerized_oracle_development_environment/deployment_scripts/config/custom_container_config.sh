#!/bin/sh

# define any database/apex credentials necessary to deploy the database schemas and/or applications

# declare an associative array with the secret name as the array element and the bash variable name as the array value
declare -A SECRET_MAPPING_ARR=(
	["sys_password"]="ORACLE_PWD"
)

# declare if the ORDS service is enabled (required for Apex/ORDS functionality)
declare ORDS_ENABLED="yes"

# declare the source folder name, this must be unique to run more than one instance of CODE on a given container host machine
declare SOURCE_FOLDER_NAME="CODE_JDA"

# define the container git project URL
declare GIT_URL="git@github.com:noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment.git"

# define the container server hostname configuration information
declare HOSTNAME="pifsc-dev-docker-01-as"
