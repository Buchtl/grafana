#!/bin/bash
container_name=$(docker ps --filter "label=com.docker.swarm.service.name=grafana_postgres" --format "{{.Names}}")
docker exec -it ${container_name} pg_dump -U app -d appdb -F c -f /tmp/appdb.dump
docker cp ${container_name}:/tmp/appdb.dump ./data/postgres/
