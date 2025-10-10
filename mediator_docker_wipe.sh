#!/bin/bash

# Function to display help
show_help() {
    echo "Usage: $0 [options]"
    echo "Deletes OSS Mediator Setup"
    echo "If no option is provied will delete all containers and data"
    echo "Options:"
    echo "  -h, --help, help    Show help"	Show help
    echo "  -os, --opensearch, os"			Delete OpenSearch data   
    echo "  -g, --grafana, grafana"			Delete OpenSearch data   
	echo "  -p, --plugin, plugin"			Delete ElasticSearch plugin 
	echo "  -EMEA, --EMEA, EMEA"					Delete EMEA Collector
	echo "  -WEST, --WEST, WEST"					Delete WEST Collector					
	echo "  -APAC, --APAC, APAC"					Delete APAC Collector
	echo
}

# Function to delete all containers
deleteDeployment(){
	echo "Removing OSS Mediator containers..."
	#docker stop $(docker ps -a -q)
	#docker rm $(docker ps -a -q)
	deleteElasticSearchPlugin
	deleteOpenSearch
	deleteGrafana
	deleteEMEA
	deleteWEST
	deleteAPAC
	rm -rf $(pwd)/collector/ $(pwd)/plugin/ $(pwd)/es_data/ $(pwd)/grafana_storage/ $(pwd)/reports
	echo "OSS Mediator deployment deleted!"
}

# Function to delete EMEA collector
deleteEMEA(){
	echo "Removing EMEA collector..."
	docker stop ndac_oss_collector_EMEA
	docker rm ndac_oss_collector_EMEA
	echo "Removing EMEA collector data..."
	rm -rf $(pwd)/collector/logs/EMEA
	rm -rf $(pwd)/collector/checkpoints/EMEA
	rm -rf $(pwd)/reports/EMEA
}

# Function to delete WEST collector
deleteWEST(){
	echo "Removing WEST collector..."
	docker stop ndac_oss_collector_WEST
	docker rm ndac_oss_collector_WEST
	echo "Removing WEST collector data..."
	rm -rf $(pwd)/collector/logs/WEST
	rm -rf $(pwd)/collector/checkpoints/WEST
	rm -rf $(pwd)/reports/WEST
}

# Function to delete APAC collector
deleteAPAC(){
	echo "Removing APAC collector..."
	docker stop ndac_oss_collector_APAC
	docker rm ndac_oss_collector_APAC
	echo "Removing APAC collector data..."
	rm -rf $(pwd)/collector/logs/APAC
	rm -rf $(pwd)/collector/checkpoints/APAC
	rm -rf $(pwd)/reports/APAC
}

# Function to delete dc7 collector
#deleteDC7(){
#	docker stop ndac_oss_collector_dc7
#	docker rm ndac_oss_collector_dc7
#	rm -rf $(pwd)/collector/logs/dc7/
#	rm -rf $(pwd)/collector/checkpoints/dc7/
#	rm -rf $(pwd)/reports/dc7/
#}

# Function to delete ES Plugin 
deleteElasticSearchPlugin(){
	echo "Removing ElasticSearch plugin..."
	docker stop	ndac_oss_elasticsearchplugin
	docker rm ndac_oss_elasticsearchplugin
	echo "Removing ElasticSearch plugin data..."
	rm -rf $(pwd)/plugin/
}


# Function to delete OpenSearch and storage
deleteOpenSearch(){
	echo "Removing OpenSearch plugin..."
	docker stop ndac_oss_opensearch
	docker rm ndac_oss_opensearch
	echo "Removing OpenSearch data..."
	rm -rf $(pwd)/es_data/
}

# Function to delete Grafan and storage
deleteGrafana(){
	echo "Removing Grafana..."
	docker stop ndac_oss_grafana
	docker rm ndac_oss_grafana
	echo "Removing Grafana data..."
	rm -rf $(pwd)/grafana_storage/
}


# Check if there are any containers running
#if [ -z "$(docker ps -qa)" ]; then
#	echo "There are no containers deployed!"
#	show_help
#	exit 1
#
#fi

# Check if there are any arguments
if [ $# -eq 0 ]; then
    # No arguments, wipe everything.
    deleteDeployment
else
	# Handle arguments
    # Wipe specific component
	    case $1 in
        -h|--help|help)
            show_help
            ;;
		-os|--opensearch|os)
			deleteOpenSearch
			;;
		-p|--plugin|plugin)
			deleteElasticSearchPlugin
			;;
		-g|--grafana|grafana)	
			deleteGrafana
			;;	
		-EMEA|--EMEA|EMEA)
			deleteEMEA
			;;
		-WEST|--WEST|WEST)
			deleteWEST
			;;
		-APAC|--APAC|APAC)
			deleteAPAC
			;;
		*)
            echo "Invalid command. Use -h or --help for usage information."
            exit 1
            ;;
    esac
fi
