# CAS PIFSC Oracle Developer Environment

## Overview
The Centralized Authorization System (CAS) PIFSC Oracle Developer Environment (ODE) project was developed to provide a custom containerized Oracle development environment for the CAS.  This repository can be forked to extend the existing functionality to any data systems that depend on the CAS for both development and testing purposes.  

## Resources
-   ### CAS ODE Version Control Information
    -   URL: https://picgitlab.nmfs.local/oracle-developer-environment/cas-pifsc-oracle-developer-environment
    -   Version: 1.0 (git tag: CAS_ODE_v1.0)
    -   Upstream repository:
        -   DSC ODE Version Control Information:
            -   URL: https://picgitlab.nmfs.local/oracle-developer-environment/dsc-pifsc-oracle-developer-environment
            -   Version: 1.0 (git tag: DSC_ODE_v1.0)
-   ### CAS Version Control Information
    -   URL: https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module
-   ### DSC Version Control Information
    -   URL: https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc

## Prerequisites
-   See the ODE [Prerequisites](https://picgitlab.nmfs.local/oracle-developer-environment/pifsc-oracle-developer-environment#prerequisites) for details

## Automated Preparation Process
-   \*Note: The [prepare_docker_project.sh](./deployment_scripts/prepare_docker_project.sh) bash script retrieves the necessary files from the corresponding repositories and copies them into the docker image directory structure
-   ### Database Dependencies
    -   DSC
        -   The [SQL](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/tree/main/SQL?ref_type=heads) folder is copied into a new "DSC" folder within the [docker/src](./docker/src) folder
-   ### CAS Database Deployment
    -   The Standalone Authorization Module (SAM) [SQL](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/tree/master/SAM/SQL?ref_type=heads) folder is copied into a new "SAM" folder within the [docker/src](./docker/src) folder
    -   The CAS [SQL](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/tree/master/CAS/SQL?ref_type=heads) folder is copied into a new "CAS" folder within the [docker/src](./docker/src) folder
-   ### CAS APEX Deployment
    -   The CAS [application_code](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/tree/master/CAS/application_code?ref_type=heads) folder is copied into a new "CAS" folder within the [docker/src](./docker/src) folder

## Automated Deployment Process
-   \*Note: The [run_db_app_deployments.sh](./docker/src/run_db_app_deployment.sh) bash script runs the necessary commands within the docker container to execute the scripts within the docker image to deploy schemas, objects, and APEX apps.
-   ### DSC
    -   [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/blob/main/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads) is executed by the SYS schema to create the DSC schema and grant the necessary privileges
    -   [deploy_dev_container.sql](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/blob/main/SQL/automated_deployments/deploy_dev_container.sql?ref_type=heads) is executed with the DSC schema to deploy the objects to the DSC schema
-   ### CAS
    -   [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/blob/master/CAS/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads) is executed to create the CAS schemas, roles, and APEX workspace
    -   [deploy_dev_container.sql](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/blob/master/CAS/SQL/automated_deployments/deploy_dev_container.sql?ref_type=heads) is executed with the CAS schema to deploy the objects to the CAS schema
    -   [deploy_apex_dev_container.sql](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/blob/master/CAS/SQL/automated_deployments/deploy_apex_dev_container.sql?ref_type=heads) is executed with the CAS_APX_APP schema to deploy the objects to the CAS_APX_APP schema and the app to the CAS_APX_APP APEX workspace

## Customization Process
-   \*Note: this process will fork the CAS ODE parent repository and repurpose it as a project-specific ODE
-   Fork the [project](#cas-ode-version-control-information)
    -   Update the name/description of the project to specify the data system that is implemented in CAS ODE
-   Clone the forked project to a working directory
-   Update the forked project in the working directory
    -   Update the [documentation](./README.md) to reference all of the repositories that are used to build the image and deploy the container
    -   Update the [prepare_docker_project.sh](./deployment_scripts/prepare_docker_project.sh) bash script to retrieve DB/app files for all dependencies (if any) as well as the DB/app files for the given data system and place them in the appropriate subfolders in the [src folder](./docker/src)
    -   Update the [project_config.sh](./deployment_scripts/sh_script_config/project_config.sh) bash script to specify the variable values that will be used to identify the repositories to clone for the container dependencies and to specify the root folder and the prepared project folder
    -   Specify the password for the SYS and SYSTEM database accounts
        -   Update the [conn_string.txt](./docker/variables/conn_string.txt) to specify the password for the SYS and SYSTEM database accounts.
             -   CONN_STRING=sys/[PASSWORD]@database:1521/XEPDB1 where [PASSWORD] is the specified password
        -   Update the docker-compose.yml files to specify the password for the SYS and SYSTEM database accounts in the following line: "ORACLE_PWD=[PASSWORD]" where [PASSWORD] is the specified password
            -   Development scenario: [docker-compose-dev.yml](./docker/docker-compose-dev.yml)
            -   Test scenario: [docker-compose-test.yml](./docker/docker-compose-test.yml)
    -   Update [run_db_app_deployment.sh](./docker/src/run_db_app_deployment.sh) bash script to automatically deploy the database schemas, schema objects, APEX workspaces, and APEX applications.  This process can be customized for any Oracle data system.
        -   Update the check_database_initialized() function definition to specify a schema (e.g. DSC) that will exist if the database has been provisioned
        -   Update the Database connection details (DB_PASSWORD variable) to match the [PASSWORD] value specified in the .yml and conn_string.txt files
        -   Specify any additional variables to store database connection details and evaluate them when executing the individual DB/app deployment SQLPlus scripts
        -   Update the bash script to execute the SQLPlus scripts in the proper order to deploy schemas, APEX workspaces, and APEX apps that were copied to the /src directory when the [prepare_docker_project.sh](./deployment_scripts/prepare_docker_project.sh) script is executed.
-   ### Implementation Examples
    -   Database and APEX app with two levels of database dependencies and an application dependency: [PARR Tools ODE project](https://picgitlab.nmfs.local/oracle-developer-environment/parr-tools-pifsc-oracle-developer-environment)

## Deployment Process
-   See the [ODE Deployment Process documentation](https://picgitlab.nmfs.local/oracle-developer-environment/pifsc-oracle-developer-environment/-/blob/main/README.md?ref_type=heads#deployment-process) for details

## Container Architecture
-   See the ODE [container architecture documentation](https://picgitlab.nmfs.local/oracle-developer-environment/pifsc-oracle-developer-environment/-/blob/main/README.md?ref_type=heads#container-architecture) for details

## Connection Information
-   See the ODE [connection information documentation](https://picgitlab.nmfs.local/oracle-developer-environment/pifsc-oracle-developer-environment/-/blob/main/README.md?ref_type=heads#connection-information) for details
