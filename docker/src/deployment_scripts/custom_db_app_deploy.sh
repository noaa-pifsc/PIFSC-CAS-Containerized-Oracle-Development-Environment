#!/bin/sh

# load the bash configuration file
source ./config/custom_container_config.sh

echo "running the custom database and/or application deployment scripts"

# run each of the sqlplus scripts to deploy the schemas, objects for each schema, applications, etc.
# ... YOUR SCRIPT LOGIC HERE ...

echo "custom deployment scripts have completed successfully"
