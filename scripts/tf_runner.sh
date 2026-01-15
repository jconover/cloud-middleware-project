#!/bin/bash
# scripts/tf_runner.sh

# This script wraps Terraform execution in a Podman container.
# It automatically mounts the project root to /workspace and sets the working directory
# to the corresponding path inside the container.
#
# Usage: ./scripts/tf_runner.sh <terraform_command> [args...]
# Example: ./scripts/tf_runner.sh init
# Example: ./scripts/tf_runner.sh apply

set -e

# Detect Project Root (assuming script is in scripts/ subdir)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CURRENT_DIR="$(pwd)"

# Calculate relative path from project root to current dir
if [[ "$CURRENT_DIR" == "$PROJECT_ROOT"* ]]; then
    REL_PATH="${CURRENT_DIR#$PROJECT_ROOT}"
    REL_PATH="${REL_PATH#/}" # remove leading slash
else
    echo "Error: You must be inside the project directory to run this script."
    exit 1
fi

# Define the Terraform image
TF_IMAGE="hashicorp/terraform:latest"

echo "Running Terraform via Podman in: /workspace/$REL_PATH"

# Run Podman
# -v: Mount project root to /workspace
# -w: Set working dir to /workspace/<relative_path>
# -e: Pass AWS credentials and region
podman run --rm -it \
    -v "$PROJECT_ROOT:/workspace" \
    -w "/workspace/$REL_PATH" \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN \
    -e AWS_DEFAULT_REGION \
    -e AWS_REGION \
    "$TF_IMAGE" "$@"
