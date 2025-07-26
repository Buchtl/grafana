
#!/bin/bash
IP=192.168.2.72
#$1
STACK_NAME=grafana

docker swarm init --advertise-addr $IP
printf 'app' | docker secret create postgres_password -
printf 'admin' | docker secret create grafana_admin_password -
docker stack deploy -c <(docker-compose config) $STACK_NAME
docker stack ls
docker stack services $STACK_NAME
docker stack ps $STACK_NAME
