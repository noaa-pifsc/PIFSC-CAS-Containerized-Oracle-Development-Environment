# PIFSC CAS Containerized Oracle Developer Environment

## Overview
The PIFSC Centralized Authorization System (CAS) Containerized Oracle Developer Environment (CCODE) project was developed to provide a custom containerized Oracle development environment (CODE) for the CAS.  This repository can be forked to extend the existing functionality to any data systems that depend on the CAS for both development and testing purposes.  

## Resources
-   ### CCODE Version Control Information
    -   URL: https://github.com/noaa-pifsc/PIFSC-CAS-Containerized-Oracle-Development-Environment
    -   Version: 1.2 (git tag: CAS_CODE_v1.2)
    -   Upstream repository:
        -   DSC CODE (DCODE) Version Control Information:
            -   URL: https://github.com/noaa-pifsc/PIFSC-DSC-Containerized-Oracle-Development-Environment
            -   Version: 1.2 (git tag: DSC_CODE_v1.2)

## Dependencies
\* Note: all dependencies are implemented as git submodules in the [modules](./modules) folder
-   ### CAS Version Control Information
    -   Version Control Information:
        -   URL: <https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module>
        -   Database: 1.2 (Git tag: central_auth_app_db_v1.2)
-   ### DSC Version Control Information
    -   Version Control Information:
        -   URL: <git@picgitlab.nmfs.local:centralized-data-tools/pifsc-dsc.git>
        -   Database: 1.1 (Git tag: dsc_db_v1.1)
-   ### Container Deployment Scripts (CDS) Version Control Information
    -   Version Control Information:
        -   URL: <git@picgitlab.nmfs.local:centralized-data-tools/pifsc-container-deployment-scripts.git>
        -   Database: 1.1 (Git tag: pifsc_container_deployment_scripts_v1.1)

## Prerequisites
-   See the CODE [Prerequisites](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#prerequisites) for details

## Repository Fork Diagram
-   See the CODE [Repository Fork Diagram](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#repository-fork-diagram) for details

## Runtime Scenarios
-   See the CODE [Runtime Scenarios](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#runtime-scenarios) for details

## Automated Deployment Process
-   ### Prepare the project
    -   Recursively clone the [CCODE repository](#ccode-version-control-information) to a working directory
-   ### Build and Run the Containers 
    -   See the CODE [Build and Run the Containers](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#build-and-run-the-containers) for details
    -   #### DSC Database Deployment
        -   [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/blob/main/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads) is executed by the SYS schema to create the DSC schema and grant the necessary privileges
        -   [deploy_dev_container.sql](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/blob/main/SQL/automated_deployments/deploy_dev_container.sql?ref_type=heads) is executed with the DSC schema to deploy the objects to the DSC schema
    -   #### CAS Database Deployment
        -   [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/blob/master/CAS/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads) is executed to create the CAS schemas, roles, and APEX workspace
        -   [deploy_dev_container.sql](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/blob/master/CAS/SQL/automated_deployments/deploy_dev_container.sql?ref_type=heads) is executed with the CAS schema to deploy the objects to the CAS schema
        -   [deploy_apex_dev_container.sql](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/blob/master/CAS/SQL/automated_deployments/deploy_apex_dev_container.sql?ref_type=heads) is executed with the CAS_APX_APP schema to deploy the objects to the CAS_APX_APP schema and the app to the CAS_APX_APP APEX workspace

## Customization Process
-   ### Implementation
    -   \*Note: this process will fork the CCODE parent repository and repurpose it as a project-specific CODE
    -   Fork [this repository](#ccode-version-control-information)
    -   See the CODE [Implementation](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#implementation) for details
-   ### Upstream Updates
    -   See the CODE [Upstream Updates](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#upstream-updates) for details

## Container Architecture
-   See the CODE [container architecture documentation](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file/-/blob/main/README.md?ref_type=heads#container-architecture) for details
-   ### CCODE Customizations:
    -   [docker/.env](./docker/.env) was updated to define an appropriate APP_SCHEMA_NAME valu and to specify an TARGET_APEX_VERSION to re-enable Apex
    -   [custom_deployment_functions.sh](./deployment_scripts/functions/custom_deployment_functions.sh) was updated to add the [CODE-ords.yml](./docker/CODE-ords.yml) configuration file to enable the ords container
    -   [custom-docker-compose.yml](./docker/custom-docker-compose.yml) was updated to define CODE-specific mounted volume overrides for the database and application deployments
    -   [custom_db_app_deploy.sh](./docker/src/deployment_scripts/custom_db_app_deploy.sh) was updated to deploy the CAS database schemas and the Apex app
    -   [custom_container_config.sh](./docker/src/deployment_scripts/config/custom_container_config.sh) was updated to define DB credentials and mounted volume file paths for the CAS SQL scripts

## Connection Information
-   See the CODE [connection information documentation](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file/-/blob/main/README.md?ref_type=heads#connection-information) for details
-   ### DSC Database Connection Information
    -   Connection information can be found in [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/blob/main/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads)
-   ### CAS Database Connection Information
    -   Connection information can be found in [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/authorization-application-module/-/blob/master/CAS/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads)