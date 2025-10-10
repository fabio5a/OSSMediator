#!/bin/bash
set -e

version=$(cat VERSION)
heap_size=${heap_size:-4g}
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

  shift
done

if ! [ -x "$(command -v docker)" ]; then
  echo "Docker not installed, please install docker and re-run the script."
	exit 1
fi

echo "Installing OSSMediator $version version"

#OpenSearch
mkdir -p es_data
chmod g+rwx es_data
chgrp 0 es_data
chown 1000:1000 es_data/
docker start ndac_oss_opensearch 2>/dev/null || echo "Building OpenSearch container..." ; docker run --name "ndac_oss_opensearch" --restart=always -t -d -p 9200:9200 -p 9600:9600 --ulimit nofile=65535:65535 -e "discovery.type=single-node" -e 'DISABLE_SECURITY_PLUGIN=true' -e OPENSEARCH_JAVA_OPTS="-Xms$heap_size -Xmx$heap_size" -v $(pwd)/es_data:/usr/share/opensearch/data opensearchproject/opensearch:3.1.0

#Grafana
mkdir -p grafana_storage
chown 472:472 grafana_storage/
docker start ndac_oss_grafana 2>/dev/null || echo "Building Grafana container..." ; docker run -d --name "ndac_oss_grafana" --restart unless-stopped --network host  -e "GF_INSTALL_PLUGINS=grafana-opensearch-datasource" -v $(pwd)/grafana_storage:/var/lib/grafana -v $(pwd)/grafana_data/provisioning/dashboards:/etc/grafana/provisioning/dashboards -v $(pwd)/grafana_data/provisioning/datasources:/etc/grafana/provisioning/datasources -v $(pwd)/grafana_data/dashboards:/etc/grafana/dashboards grafana/grafana-oss:12.1.1

#Collector EMEA
docker start ndac_oss_collector_EMEA 2>/dev/null || echo "Building EMEA collector container..." ; docker run -d --name "ndac_oss_collector_EMEA" --restart unless-stopped --network host -v $(pwd)/reports/EMEA:/reports  -v $(pwd)/collector/logs/EMEA:/collector/log -v $(pwd)/collector/checkpoints/EMEA:/collector/bin/checkpoints -v $(pwd)/config/EMEA/.secret:/collector/bin/.secret -v $(pwd)/config/EMEA/collector_conf.json:/collector/resources/conf.json ossmediatorcollector:$version
#sleep 5


#Collector WEST
docker start ndac_oss_collector_WEST 2>/dev/null || echo "Building WEST collector container..." ; docker run -d --name "ndac_oss_collector_WEST" --restart unless-stopped --network host -v $(pwd)/reports/WEST:/reports  -v $(pwd)/collector/logs/WEST:/collector/log -v $(pwd)/collector/checkpoints/WEST:/collector/bin/checkpoints -v $(pwd)/config/WEST/.secret:/collector/bin/.secret -v $(pwd)/config/WEST/collector_conf.json:/collector/resources/conf.json ossmediatorcollector:$version
#sleep 5

#Collector APAC
docker start ndac_oss_collector_APAC 2>/dev/null || echo "Building APAC collector container..." ; docker run -d --name "ndac_oss_collector_APAC" --restart unless-stopped --network host -v $(pwd)/reports/APAC:/reports  -v $(pwd)/collector/logs/APAC:/collector/log -v $(pwd)/collector/checkpoints/APAC:/collector/bin/checkpoints -v $(pwd)/config/APAC/.secret:/collector/bin/.secret -v $(pwd)/config/APAC/collector_conf.json:/collector/resources/conf.json ossmediatorcollector:$version
#sleep 5


#ElasticSearch Plugin
echo "Building ElasticSearchPlugin container..."
sleep 30

#ElasticSearchPlugin
docker start ndac_oss_elasticsearchplugin 2>/dev/null || docker run -d --name "ndac_oss_elasticsearchplugin" --restart unless-stopped --network host -v $(pwd)/reports/EMEA:/reports/EMEA -v $(pwd)/reports/WEST:/reports/WEST -v $(pwd)/reports/APAC:/reports/APAC -v $(pwd)/plugin/logs:/plugin/log -v $(pwd)/config/ElasticSearchPlugin/plugin_conf.json:/plugin/resources/conf.json elasticsearchplugin:$version


echo "OSSMediator is started, open http://<IP_Address>:3000/dashboards to view the dashboards."
