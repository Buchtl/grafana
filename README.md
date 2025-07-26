
# Postgres
## Dump
```
#pg_dump -U app -d appdb -F c -f /tmp/appdb.dump
container_name=$(docker ps --filter "label=com.docker.swarm.service.name=grafana_postgres" --format "{{.Names}}")
docker exec -it ${container_name} pg_dump -U app -d appdb -F c -f /tmp/appdb.dump
docker cp ${container_name}:/tmp/appdb.dump ./data/postgres/
```


## Fix backup made with pgadmin4
`sed -i '/transaction_timeout/d' ./data/postgres/appdb.sql`

# Grafana
## Export Dashboard
```
curl -H "Authorization: Bearer <API_KEY>" \
  http://<grafana-host>:<PORT>/api/dashboards/uid/<DASHBOARD_UID> \
  | jq '.'
```

Add another aggregated column to the same query:

```sql
SELECT
  $__timeGroupAlias(creation_date, '1d'),
  sum(size)   AS total_size,
  count(*)    AS entry_count          -- or count(size) if you only want non‑NULL sizes
FROM grafana_file
WHERE $__timeFilter(creation_date)
GROUP BY 1
ORDER BY 1;
```

Grafana will return two series per day: **total\_size** and **entry\_count**.
If you also want the **average size per entry**:

```sql
SELECT
  $__timeGroupAlias(creation_date, '1d'),
  sum(size)                AS total_size,
  count(*)                 AS entry_count,
  sum(size)::double precision / NULLIF(count(*), 0) AS avg_size
FROM grafana_file
WHERE $__timeFilter(creation_date)
GROUP BY 1
ORDER BY 1;
```

Make sure the panel is **Format: Time series** (or Panel type: Time series).
