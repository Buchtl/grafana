
# Grafana
## Export Dashboard
```
curl -H "Authorization: Bearer <API_KEY>" \
  http://<grafana-host>:<PORT>/api/dashboards/uid/<DASHBOARD_UID> \
  | jq '.'
```