#!/bin/bash
set -e

# Note: With host networking, DNS and port forwarding are automatic!
# All services are accessible via localhost directly.

echo "Using Docker host networking - no special configuration needed"

# Execute any passed command
set +e  # Don't exit on errors from the passed command
exec "$@"

