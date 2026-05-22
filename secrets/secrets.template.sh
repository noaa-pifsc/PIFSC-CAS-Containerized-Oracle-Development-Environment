#--- Credentials ---

# define the default admin user for Oracle
ORACLE_ADMIN_USER="SYS"

# Set your oracle administrator password here: SYS and SYSTEM database schema passwords, APEX administrator password (workspace = INTERNAL, user = ADMIN), and the ORDS_PUBLIC_USER password
ORACLE_PWD='YOUR_PASSWORD'

# define any database/apex credentials necessary to deploy the database schemas and/or applications

# define DSC credentials
DSC_USER="DSC"
DSC_PWD='YOUR_DSC_PASSWORD'

# define CAS data schema credentials
CAS_DB_USER="CAS"
CAS_DB_PWD='YOUR_CAS_USER_PASSWORD'

# define CAS application schema credentials
CAS_APP_USER="CAS_APX_APP"
CAS_APP_PWD='YOUR_CAS_APP_PASSWORD'

# define CAS apex developer account username/password
CAS_APX_USER='CAS_APX_APP_DEV'
CAS_APX_PWD='YOUR_CAS_APEX_PASSWORD'