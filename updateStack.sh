

USER_UID="1000"
USER_GID="1000"

docker stack deploy -c docker-compose.yml grafana
docker system prune
