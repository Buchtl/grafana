#!/bin/bash

INPUT=$1

# Paths (adjust if needed)
DASHBOARDS_DIR="./config/grafana/provisioning/dashboards/"
DASHBOARDS_TARGET_DIR="/etc/grafana/provisioning/dashboards"
DASHBOARD_JSON="$DASHBOARDS_DIR/export.json"
PROVISIONING_YAML="./config/grafana/provisioning/dashboards/dashboards.yaml"
SOURCE_JSON=$INPUT  # your exported JSON file in current dir


# Create dashboards directory if not exists
mkdir -p "$DASHBOARDS_DIR"

# Copy exported dashboard JSON file into dashboards directory
cp "$SOURCE_JSON" "$DASHBOARD_JSON"

# Write provisioning config YAML file
cat > "$PROVISIONING_YAML" <<EOF
apiVersion: 1
providers:
  - name: "Provisioned Dashboards"
    type: file
    disableDeletion: false
    editable: true
    options:
      path: "$DASHBOARDS_TARGET_DIR"
EOF

echo "Provisioning setup complete."
echo "Dashboard JSON copied to: $DASHBOARD_JSON"
echo "Provisioning config written to: $PROVISIONING_YAML"
