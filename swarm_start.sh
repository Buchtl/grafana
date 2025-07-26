#!/bin/bash

# -e: Exit on Error 
# -u: Unset variables lead to error and exit the script
# -o: pipefail -> pipeline returns a failure if any command in the pipeline fails
#set -euo pipefail

#IP="${1:-}"
#if [[ -z "$IP" ]]; then
#  read -rp "Enter the IP to use for --advertise-addr: " IP
#  [[ -z "$IP" ]] && { echo "Error: IP is required."; exit 1; }
#fi

IP=`hostname -I | awk '{print $1}'`
USER_UID="1000"
USER_GID="1000"

STACK_NAME=grafana

WORKING_DIR=/home/$USER/git/grafana

docker swarm init --advertise-addr $IP

printf 'app' | docker secret create postgres_password -
printf 'admin' | docker secret create grafana_admin_password -

docker stack deploy -c docker-compose.yml $STACK_NAME
docker stack ls
docker stack services $STACK_NAME
docker stack ps $STACK_NAME
