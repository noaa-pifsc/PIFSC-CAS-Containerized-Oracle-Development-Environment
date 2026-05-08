#!/bin/bash

# Define paths
export CONFIG_DIR="/etc/ords/config"
export ORDS_CONFIG="${CONFIG_DIR}"
PW_FILE="/run/secrets/oracle_pwd"

# Read the database secret into the shell environment
if [ ! -f "${PW_FILE}" ]; then
    echo "ERROR: Secret oracle_pwd was not found."
    exit 1
fi

# 2. Wait for the .deploy_ready_${DEPLOY_ID} file
echo "The current deployment ID is: ${DEPLOY_ID}"
echo "Waiting for database deployment to finish..."
while [ ! -f /opt/oracle/ords/static/.deploy_ready_${DEPLOY_ID} ]; do 
  sleep 5
  echo "Still waiting for database deployment to finish..."
done
echo "Handshake received. Manually generating configuration files to ensure stateless reliability..."

# Clean existing config to ensure absolute statelessness
rm -rf "${CONFIG_DIR}/"*
mkdir -p "${CONFIG_DIR}/global"
mkdir -p "${CONFIG_DIR}/databases/default"

# show the ORDS configuration variables
echo "before any changes are made the configuration variables are: "
ords --config "$CONFIG_DIR" config list


# generate the database pool configuration:
echo "generate the database pool configuration"
ords --config "$CONFIG_DIR" config --db-pool default set db.ConnectionType "basic"
ords --config "$CONFIG_DIR" config --db-pool default set db.hostname "${DBHOST}"
ords --config "$CONFIG_DIR" config --db-pool default set db.port "${DBPORT}"
ords --config "$CONFIG_DIR" config --db-pool default set db.servicename "${DBSERVICENAME}"
ords --config "$CONFIG_DIR" config --db-pool default set db.username "ORDS_PUBLIC_USER"

ords --config "$CONFIG_DIR" config --db-pool default set feature.sdw "true"
ords --config "$CONFIG_DIR" config --db-pool default set plsql.gateway.mode "proxied"
ords --config "$CONFIG_DIR" config --db-pool default set restEnabledSql.active "true"
ords --config "$CONFIG_DIR" config --db-pool default set security.requestValidationFunction "ords_util.authorize_plsql_gateway"

# Pipe the password into the command to satisfy the interactive prompt
ords --config "$CONFIG_DIR" config secret --password-stdin db.password < "${PW_FILE}"

# set the global configuration:
ords --config "$CONFIG_DIR" config set database.api.enabled true --global
ords --config "$CONFIG_DIR" config set standalone.static.context.path "/i" --global
ords --config "$CONFIG_DIR" config set standalone.static.path "/opt/oracle/ords/static" --global

# show the ORDS configuration variables
echo "after the changes are made the configuration variables are: "
ords --config "$CONFIG_DIR" config list

echo "Handing off to official docker-entrypoint.sh..."
exec docker-entrypoint.sh --config "$CONFIG_DIR" serve