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
PROVIDER_NAME=$(jq -r '.title // empty' $INPUT)

if [[ -f "$PROVISIONING_YAML" ]]; then
  # Check if file starts with apiVersion: 1
  if head -n1 "$PROVISIONING_YAML" | grep -q '^apiVersion: 1'; then
    # Check if provider with the same name already exists
    if grep -q "name: \"$PROVIDER_NAME\"" "$PROVISIONING_YAML"; then
      echo "Provider '$PROVIDER_NAME' already exists in $PROVISIONING_YAML — skipping append."
    else
      echo "Appending provider '$PROVIDER_NAME' to $PROVISIONING_YAML"
      # Append only the providers part
      cat >> "$PROVISIONING_YAML" <<EOF

  - name: "$PROVIDER_NAME"
    type: file
    disableDeletion: false
    editable: true
    options:
      path: "$DASHBOARDS_TARGET_DIR"
EOF
    fi
  else
    echo "$PROVISIONING_YAML does not start with 'apiVersion: 1' — rewriting full file"
    cat > "$PROVISIONING_YAML" <<EOF
apiVersion: 1
providers:
  - name: "$PROVIDER_NAME"
    type: file
    disableDeletion: false
    editable: true
    options:
      path: "$DASHBOARDS_TARGET_DIR"
EOF
  fi
else
  echo "$PROVISIONING_YAML does not exist — creating file"
  cat > "$PROVISIONING_YAML" <<EOF
apiVersion: 1
providers:
  - name: "$PROVIDER_NAME"
    type: file
    disableDeletion: false
    editable: true
    options:
      path: "$DASHBOARDS_TARGET_DIR"
EOF
fi

echo "Provisioning setup complete."
echo "Dashboard JSON copied to: $DASHBOARD_JSON"
echo "Provisioning config written to: $PROVISIONING_YAML"
