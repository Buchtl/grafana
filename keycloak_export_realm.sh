#!/bin/bash
container_id=$(docker ps --filter "label=com.docker.swarm.service.name=grafana_keycloak" --format "{{.ID}}")
container_name=$(docker ps --filter "label=com.docker.swarm.service.name=grafana_keycloak" --format "{{.Names}}")

docker exec -it $container_name /opt/keycloak/bin/kc.sh export \
  --dir /opt/keycloak/data/export \
  --realm grafana \
  --users realm_file

docker exec -it $container_name cat /opt/keycloak/data/export/grafana-realm.json > ./config/keycloak/grafana-realm.json
