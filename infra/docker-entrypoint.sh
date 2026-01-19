#!/bin/bash
set -e

# Resolve mogilefs-infra service IP and add it to /etc/hosts
MOGILEFS_IP=$(getent hosts mogilefs-infra | awk '{ print $1 }')
if [ -z "$MOGILEFS_IP" ]; then
    echo "ERROR: Could not resolve mogilefs-infra service IP"
    exit 1
fi

echo "Adding DNS entry: $MOGILEFS_IP qbert.guba.com"
echo "$MOGILEFS_IP qbert.guba.com" >> /etc/hosts

# Execute any passed command
exec "$@"
