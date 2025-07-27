#!bin/bash
STACK_NAME=grafana
docker stack rm $STACK_NAME
docker secret rm postgres_password
docker swarm leave --force
docker system prune
#docker volume rm ${STACK_NAME}_${STACK_NAME}
docker volume prune
