#!/bin/sh

# define any database/apex credentials necessary to deploy the database schemas and/or applications

# define DSC schema credentials
DB_DSC_USER="DSC"
DB_DSC_PASSWORD="[CONTAINER_PW]"

# define DSC connection string
DSC_CREDENTIALS="$DB_DSC_USER/$DB_DSC_PASSWORD@${DBHOST}:${DBPORT}/${DBSERVICENAME}"

# define the DSC database folder path
DSC_FOLDER_PATH="/usr/src/DSC/SQL"


# define CAS schema credentials
DB_CAS_USER="CAS"
DB_CAS_PASSWORD="[CONTAINER_PW]"

# define CAS connection string
CAS_CREDENTIALS="$DB_CAS_USER/$DB_CAS_PASSWORD@${DBHOST}:${DBPORT}/${DBSERVICENAME}"

# define CAS_APX_APP schema credentials
DB_CAS_APP_USER="CAS_APX_APP"
DB_CAS_APP_PASSWORD="[CONTAINER_PW]"

# define CAS connection string
CAS_APP_CREDENTIALS="$DB_CAS_APP_USER/$DB_CAS_APP_PASSWORD@${DBHOST}:${DBPORT}/${DBSERVICENAME}"

# define the CAS database folder path
CAS_FOLDER_PATH="/usr/src/CAS/SQL"
