# Forked from https://github.com/nokia/OSSMediator (4.6.0)

# Project Structure
    .  
    ├── pkg       	  				 	# Source files (nokia/OSSMediator v4.6.0)
    ├── grafana_data   				 	# Grafana Data
    ├── config         					# config folders/files
		├── EMEA						
		├── WEST
		├── APAC
		├── ElasticSearcPlugin			
    ├── mediator_docker_startup.sh		#Startup script		
	├── mediator_docker_wipe.sh			#Deployment wipe script
	├── mediator_docker_rebuild.sh		#Deployment rebuild script
	├── VERSION            
    └── README.md  


# Table of contents
1. [Introduction](#introduction)
2. [OSSMediator Installation](#installation)
   1. [System Requirements](#system_req)
   2. [Installation with Docker](#docker_install)
4. [Steps to modify NDAC dashboards](#dashboard_update)

## Introduction <a name="introduction"></a>

MediatorSetup includes scripts and Grafana template dashboards and datasource files used for installation and creation of Grafana dashboards for the PM/FM data collected using OSSMediatorCollector and ElasticsearchPlugin.  
MediatorSetup contents:

| Directory/file Name              | Description                                                                                             |
|----------------------------------|---------------------------------------------------------------------------------------------------------|
| mediator_docker_startup.sh       | OSSMediator startup script to run inside docker.                                                        |
| mediator_docker_wipe.sh          | OSSMediator script to wipe deployment.                                                                  |
| mediator_docker_rebuild.sh       | OSSMediator script to rebuild deployment.                                                               |
| collector_conf.json              | OSSMediatorCollector configuration file, default configuration file with the basic FM/PM APIs.          |
| plugin_conf.json                 | ElasticsearchPlugin configuration file.                                                                 |

### System Requirements <a name="system_req"></a>

* Docker: You can find the right version of Docker for your flavour of linux and install them from the following site.
  https://docs.docker.com/engine/install/

### Installation with Docker <a name="docker_install"></a>

1. Extract official pakage in `pkg` folder, then move to `OSSMediator` base directory and run `make all` command. It will create two docker images `ossmediatorcollector:<VERSION>` and `elasticsearchplugin:<VERSION>`.
2. Update config folders collector_conf.json templates with the correct `base_url`, `users` section with the credentials (`email_id`, `auth_type`) provided by NDAC Operations/Helpdesk team.  
   To download access token login to `Nokia NDAC Manager Portal` -> From User detail section -> Access Info -> Download token  
   Update the authorization type for the user - either `PASSWORD` or `ADTOKEN`. `ADTOKEN` is for ABAC users where the users will get the sso azure login token from the user management. `PASSWORD` is for the usual RBAC users.
   Update the `response_dest` with `/reports` value.  
4. Configure the passwords/authorization token for the users configured in collector_conf.json file for API access by executing `storesecret`. 
   Check if execute permissions are there for the `storesecret` binary, if not set it as `chmod 777 storesecret`, then execute `sudo ./storesecret -c collector_conf.json` command to store the user passwords/token.
   * To download Azure token from NDAC Manager please follow `Steps to Download SSO Azure token` section. 
5. Update config ElasticSearchPlugin plugin_conf.json template file for the field `<SOURCE DIRECTORY PATH>` with `/reports` value (Remove duplicate values).  
6. Check if execute permissions are there for the `mediator_docker_startup.sh` script, then execute `sudo ./mediator_docker_startup.sh` script to start the OSSMediator modules inside docker.

`mediator_docker_startup.sh` script will create following docker containers:
* ndac_oss_opensearch: OpenSearch instance for storing KPI data.
* ndac_grafana: Grafana instance for dashboards.
* ndac_oss_collector_EMEA: OSSMediatorCollector for collecting PM/FM data.
* ndac_oss_collector_WEST: OSSMediatorCollector for collecting PM/FM data.
* ndac_oss_collector_APAC: OSSMediatorCollector for collecting PM/FM data.
* ndac_oss_elasticsearchplugin: ElasticsearchPlugin to push collected data to OpenSearch.

The setup should be ready, and you can access the PM and FM dashboards from your browser at `http://<your_Ip_address>:3000/dashboards`, all the NDAC dashboards will be created inside `Nokia-DAC` directory.  
The Grafana dashboards will appear with login prompt and default credentials are `admin` with password `admin`.

* To update the user’s password/token, execute `sudo ./storesecret -c collector_conf.json` and input the updated password, then stop and remove `ndac_oss_collector` docker container and execute `sudo ./mediator_docker_startup.sh` to restart the modules again.

* By default, OpenSearch will be started with 2GB heap memory.  
  To increase the heap memory execute `sudo ./mediator_docker_startup.sh --heap_size <HEAP_SIZE>`.  
  Ex:
    * `To start OpenSearch with 4GB heap memory: sudo ./mediator_docker_startup.sh --heap_size 4g`
    * `To start OpenSearch with 500MB heap memory: sudo ./mediator_docker_startup.sh --heap_size 500m`

## Steps to modify NDAC dashboards <a name="dashboard_update"></a>

1. Make a copy of dashboard and save the dashboard title with prefix other than `NDAC`.
2. Update the new dashboard as per the requirement.

````
NOTE: Please don't update NDAC dashboards, any modifications will be lost after package update.
````
