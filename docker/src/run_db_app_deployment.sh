#!/bin/bash

echo "Running the custom database/apex deployment process"

# Database connection details
DB_HOST="${DBHOST}"
DB_PORT="${DBPORT}"
DB_SID="${DBSERVICENAME}"
DB_USER="sys"
DB_PASSWORD="${ORACLE_PWD}"
DB_ROLE="SYSDBA"
APP_SCHEMA_NAME="${APP_SCHEMA_NAME}"

# --- Validations ---
if [ -z "${DB_PASSWORD}" ]; then
  echo "ERROR: ORACLE_PWD environment variable is not set. Halting."
  exit 1
fi
if [ -z "${DB_HOST}" ]; then
  echo "ERROR: DB_HOSTNAME environment variable is not set. Halting."
  exit 1
fi
if [ -z "${APP_SCHEMA_NAME}" ]; then
  echo "ERROR: APP_SCHEMA_NAME environment variable is not set. Halting."
  exit 1
fi

SYS_CREDENTIALS="$DB_USER/$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_SID as $DB_ROLE"

# define a query to check if APEX is installed
APEX_QUERY="SELECT COUNT(*) FROM DBA_REGISTRY WHERE COMP_ID = 'APEX' AND STATUS = 'VALID';"

echo "The value of APEX_QUERY is: $APEX_QUERY"

# === APEX UPGRADE CONFIGURATION ===
# Reads the version from the environment variable set in docker-compose.yml
# Defaults to 24.2 if not set
TARGET_APEX_VERSION=${TARGET_APEX_VERSION:-"24.2"}

# Define paths for the dynamic download
APEX_ZIP_FILE_NAME="apex_${TARGET_APEX_VERSION}.zip"
APEX_ZIP_PATH="/tmp/${APEX_ZIP_FILE_NAME}"
APEX_DOWNLOAD_URL="https://download.oracle.com/otn_software/apex/${APEX_ZIP_FILE_NAME}"
APEX_STATIC_DIR="/apex-static" # This is the mount path for our shared volume
# === END APEX UPGRADE CONFIGURATION ===

# Function to check if the database is initialized
check_database_initialized() {
    # --- REMINDER: Update [SCHEMA_NAME] ---
    # Check if your custom schema (e.g., 'MY_APP_SCHEMA') exists
    echo "SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME = '${APP_SCHEMA_NAME}';" | sqlplus -s $SYS_CREDENTIALS | grep -q '1'
}

# Wait until the database is available
echo "Waiting for Oracle Database to be ready..."
until echo "exit" | sqlplus -s $SYS_CREDENTIALS > /dev/null; do
    echo "Database not ready, waiting 5 seconds..."
    sleep 5
done
echo "Database is ready!"

# === APEX UPGRADE LOGIC ===
echo "========================================="
echo "STEP 1: Checking APEX Version"
echo "========================================="
echo "Target version: ${TARGET_APEX_VERSION}"

echo "Checking database for APEX version..."
CURRENT_VERSION_CHECK=$(sqlplus -s -l ${SYS_CREDENTIALS} <<EOF
  set heading off feedback off pagesize 0
  select version_no from apex_release;
  exit;
EOF
)
CURRENT_VERSION_CHECK=$(echo $CURRENT_VERSION_CHECK | xargs)

if echo "${CURRENT_VERSION_CHECK}" | grep -q "${TARGET_APEX_VERSION}"; then
  echo "APEX is already at the target version (${CURRENT_VERSION_CHECK})."
  
  # --- NEW CHECK ---
  # Check if static files are also in place
  if [ -f "${APEX_STATIC_DIR}/i/apex_version.js" ]; then
    echo "Static files are in place. No upgrade needed."
    SKIP_LOGIC_BLOCK=1
  else
    echo "APEX DB is upgraded, but static files are missing."
    echo "Will attempt to download/unzip/copy static files..."
    # Set flag to skip DB install
    SKIP_DB_INSTALL=1
  fi
  # --- END NEW CHECK ---
else
  echo "APEX version mismatch. Found: '${CURRENT_VERSION_CHECK}'"
  echo "Starting APEX upgrade to ${TARGET_APEX_VERSION}..."
  SKIP_DB_INSTALL=0
fi

# This block now runs if an upgrade is needed OR if static files are missing
if [[ $SKIP_LOGIC_BLOCK -ne 1 ]]; then

  # --- DYNAMIC DOWNLOAD ---
  if [ ! -f "${APEX_ZIP_PATH}" ]; then
    echo "Downloading ${APEX_DOWNLOAD_URL}..."
    curl -L -o ${APEX_ZIP_PATH} ${APEX_DOWNLOAD_URL}
    if [ $? -ne 0 ]; then
      echo "ERROR: Download of APEX zip file failed."
      exit 1
    fi
    echo "Download complete."
  else
    echo "APEX zip file already found at ${APEX_ZIP_PATH}."
  fi
  
  echo "Unzipping ${APEX_ZIP_PATH}..."
  unzip -q ${APEX_ZIP_PATH} -d /tmp
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to unzip APEX file."
    exit 1
  fi
  cd /tmp/apex
  # --- END DYNAMIC DOWNLOAD ---
  
  # --- PARALLEL EXECUTION START ---
  DB_INSTALL_PID=0
  DB_INSTALL_STATUS=0
  FILE_COPY_STATUS=0
  
  if [ $SKIP_DB_INSTALL -eq 0 ]; then
    echo "Starting APEX DB installer (in background)..."
    # Run the DB install in the background by adding '&'
    sqlplus -s -l ${SYS_CREDENTIALS} <<EOF &
      WHENEVER SQLERROR EXIT SQL.SQLCODE
      ALTER SESSION SET CONTAINER = XEPDB1;
      @apexins.sql SYSAUX SYSAUX TEMP /i/
      exit;
EOF
    DB_INSTALL_PID=$! # Save the Process ID of the background job
  else
    echo "Skipping database install as version is already correct."
  fi

  # --- COPY TO SHARED VOLUME (Runs in foreground) ---
  echo "Copying APEX static images to shared volume (in foreground)..."
  
  # Clear out any old 'images' folder and move the new one in.
  rm -rf ${APEX_STATIC_DIR}/images
  mv /tmp/apex/images ${APEX_STATIC_DIR}/
  FILE_COPY_STATUS=$? # Save the exit code of the file copy
  if [ $FILE_COPY_STATUS -eq 0 ]; then
  	echo "Static files copied successfully."
  else
    echo "ERROR: Static file copy failed."
  fi
  # --- END COPY ---

  # --- Wait for background DB install to finish ---
  if [ $DB_INSTALL_PID -ne 0 ]; then
    echo "Waiting for APEX DB install (PID: $DB_INSTALL_PID) to finish..."
    wait $DB_INSTALL_PID
    DB_INSTALL_STATUS=$?
    if [ $DB_INSTALL_STATUS -eq 0 ]; then
      echo "APEX database upgrade successful."
      
      # run this code only if the APEX upgrade just finished, unlock the APEX_PUBLIC_USER account
      echo "Unlocking APEX accounts..."
      sqlplus -s -l ${SYS_CREDENTIALS} <<EOF
        WHENEVER SQLERROR EXIT SQL.SQLCODE
        ALTER SESSION SET CONTAINER = XEPDB1;
        -- Use the same password for all internal accounts for simplicity
        ALTER USER APEX_PUBLIC_USER IDENTIFIED BY "${DB_PASSWORD}" ACCOUNT UNLOCK;
        exit;
EOF
      if [ $? -eq 0 ]; then
        echo "APEX_PUBLIC_USER unlocked successfully."
      else
        echo "ERROR: Failed to unlock APEX_PUBLIC_USER."
        exit 1
      fi
      
    else
      echo "ERROR: Background APEX database upgrade failed."
    fi
  fi
  
  # --- Final check for all parallel jobs ---
  if [ $DB_INSTALL_STATUS -ne 0 ] || [ $FILE_COPY_STATUS -ne 0 ]; then
    echo "FATAL: One or more upgrade tasks failed. Halting."
    exit 1
  fi
  # --- PARALLEL EXECUTION END ---

  echo "Cleaning up installer files..."
  rm -rf /tmp/apex ${APEX_ZIP_PATH}
fi
# === END APEX UPGRADE LOGIC ===

# Loop until APEX is in a VALID state
echo "Waiting for APEX to be in a VALID state..."
until echo "$APEX_QUERY" | sqlplus -S $SYS_CREDENTIALS <<EOF | grep -P -o '^\s*(1)\s*$'
SET HEADING OFF
$APEX_QUERY
EXIT;
EOF
do
    echo "APEX not in a VALID state, waiting 5 seconds..."
    sleep 5
done
echo "APEX is installed and ready!"

echo "Checking if the database has been initialized (schema: ${APP_SCHEMA_NAME})..."
# Check if the database is initialized by querying DBA_USERS
if ! check_database_initialized; then
    echo "Database is not initialized. Running the SQL scripts..."

	# run each of the sqlplus scripts to deploy the schemas, objects for each schema, applications, etc.
    # ... YOUR SCRIPT LOGIC HERE ...

    echo "SQL scripts executed successfully!"
else
    echo "Database already initialized. Skipping deployment script."
fi

echo "All deployment steps complete."