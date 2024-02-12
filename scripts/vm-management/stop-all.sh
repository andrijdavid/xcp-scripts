#!/bin/bash

# Check for --force argument
FORCE_SHUTDOWN=false
if [ "$1" == "--force" ]; then
    FORCE_SHUTDOWN=true
fi

# List all running VMs
running_vms=$(xe vm-list power-state=running is-control-domain=false --minimal)

# Check if any VMs are running
if [ -z "$running_vms" ]; then
    echo "No running VMs found. Exiting."
    exit 0
fi

# Convert comma-separated list of VMs into a space-separated list
IFS=',' read -r -a vm_uuids <<< "$running_vms"

# Shutdown each VM cleanly
for uuid in "${vm_uuids[@]}"; do
    echo "Attempting to shut down VM with UUID: $uuid"
    xe vm-shutdown uuid=$uuid
    if [ $? -ne 0 ] && [ "$FORCE_SHUTDOWN" == "true" ]; then
        echo "Clean shutdown failed for VM with UUID: $uuid, attempting forced shutdown."
        xe vm-shutdown uuid=$uuid --force
    elif [ $? -ne 0 ]; then
        echo "Failed to shutdown VM with UUID: $uuid. Consider using --force option."
    fi
done

echo "All requested VMs have been processed for shutdown."
