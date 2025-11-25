# PIFSC CAS Oracle Developer Environment

## Overview
The PIFSC Centralized Authorization System (CAS) Containerized Oracle Developer Environment (CCODE) project was developed to provide a custom containerized Oracle development environment (CODE) for the CAS.  This repository can be forked to extend the existing functionality to any data systems that depend on the CAS for both development and testing purposes.  

## Resources
-   ### CCODE Version Control Information
    -   URL: https://github.com/noaa-pifsc/PIFSC-CAS-Containerized-Oracle-Development-Environment
    -   Version: 1.1 (git tag: CAS_CODE_v1.1)
    -   Upstream repository:
        -   DSC CODE Version Control Information:
            -   URL: https://github.com/noaa-pifsc/PIFSC-DSC-Containerized-Oracle-Development-Environment
            -   Version: 1.1 (git tag: DSC_CODE_v1.1)
-   ### CAS Version Control Information
    -   URL: https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module
-   ### DSC Version Control Information
    -   URL: https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc

## Prerequisites
-   See the ODE [Prerequisites](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#prerequisites) for details

## Runtime Scenarios
-   See the ODE [Runtime Scenarios](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#runtime-scenarios) for details

## Automated Deployment Process
-   ### Prepare the folder structure
    -   See the ODE [Prepare the folder structure](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#prepare-the-folder-structure) for details
    -   #### DSC Preparation
        -   The [SQL](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/tree/main/SQL?ref_type=heads) folder is copied into a new "DSC" folder within the [docker/src](./docker/src) folder
    -   #### CAS Preparation
        -   The [CAS/SQL](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/tree/master/CAS/SQL?ref_type=heads) folder is copied into the [CAS folder](./docker/src/CAS) folder
        -   The [application_code](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/tree/master/CAS/application_code?ref_type=heads) folder is copied into the [CAS folder](./docker/src/CAS) folder
        -   The [SAM/SQL](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/tree/master/SAM/SQL?ref_type=heads) folder is copied into the [SAM folder](./docker/src/SAM) folder
-   ### Build and Run the Containers 
    -   See the ODE [Build and Run the Containers](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#build-and-run-the-containers) for details
    -   #### DSC Database Deployment
        -   [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/blob/main/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads) is executed by the SYS schema to create the DSC schema and grant the necessary privileges
        -   [deploy_dev_container.sql](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/blob/main/SQL/automated_deployments/deploy_dev_container.sql?ref_type=heads) is executed with the DSC schema to deploy the objects to the DSC schema
    -   #### CAS Database Deployment
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
    -   Update the [custom_prepare_docker_project.sh](./deployment_scripts/custom_prepare_docker_project.sh) bash script to retrieve DB/app files for all dependencies (if any) as well as the DB/app files for the given data system and place them in the appropriate subfolders in the [src folder](./docker/src)
    -   Update the [custom_project_config.sh](./deployment_scripts/sh_script_config/custom_project_config.sh) bash script to specify variables for the respository URL(s) needed to clone the container dependencies
    -   Update the [.env](./docker/.env) environment to specify the configuration values:
        -   ORACLE_PWD is the password for the SYS, SYSTEM database schema passwords, the Apex administrator password, the ORDS administrator password
        -   TARGET_APEX_VERSION is the version of Apex that will be installed
        -   APP_SCHEMA_NAME is the database schema that will be used to check if the database schemas have been installed, this only applies to the [development runtime scenario](#development)
        -   DB_IMAGE is the path to the database image used to build the database contianer (db container)
        -   ORDS_IMAGE is the path to the ORDS image used to build the ORDS/Apex container (ords container)
    -   Update the [custom_db_app_deploy.sh](./docker/src/deployment_scripts/custom_db_app_deploy.sh) bash script to execute a series of SQLPlus scripts in the correct order to create/deploy schemas, create Apex workspaces, and deploy Apex apps that were copied to the /src directory when the [prepare_docker_project.sh](./deployment_scripts/prepare_docker_project.sh) script is executed. This process can be customized for any Oracle data system.
        -   Update the [custom_container_config.sh](./docker/src/deployment_scripts/config/custom_container_config.sh) to specify the variables necessary to authenticate the corresponding SQLPlus scripts when the [custom_db_app_deploy.sh](./docker/src/deployment_scripts/custom_db_app_deploy.sh) bash script is executed
    -   Create additional empty directories for any folders/files dynamically retrieved by [custom_prepare_docker_project.sh](./deployment_scripts/custom_prepare_docker_project.sh) (e.g. docker/src/parr-tools) and save .gitkeep files for them (e.g. docker/src/parr-tools/.gitkeep) so they can be added to version control
        -   Update the [.gitignore](./.gitignore) file at the root of the repository to add entries for any empty directories that have content dynamically retrieved, for example:
        ```
        # Ignore all content in the parr-tools directory
        docker/src/parr-tools/*

        # Do not ignore the .gitkeep file for the parr-tools directory, so the directory itself is tracked.
        !docker/src/parr-tools/.gitkeep
        ```
-   ### Implementation Examples
    -   Database and APEX app with a single database dependency: [PARR Tools CODE project](https://github.com/noaa-pifsc/PIFSC-PARR-Tools-Containerized-Oracle-Development-Environment)

## Container Architecture
-   See the ODE [container architecture documentation](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file/-/blob/main/README.md?ref_type=heads#container-architecture) for details

## Connection Information
-   See the ODE [connection information documentation](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file/-/blob/main/README.md?ref_type=heads#connection-information) for details
-   ### CAS Database Connection Information
    -   Connection information can be found in [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/blob/master/CAS/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads)