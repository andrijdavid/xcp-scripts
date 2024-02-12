#!/bin/bash

# List all VMs that are not running and are not control domains
stopped_vms=$(xe vm-list power-state=halted is-control-domain=false --minimal)

# Check if there are stopped VMs to start
if [ -z "$stopped_vms" ]; then
    echo "No stopped VMs found. Exiting."
    exit 0
fi

# Convert comma-separated list of VMs into a space-separated list
IFS=',' read -r -a vm_uuids <<< "$stopped_vms"

# Start each VM
for uuid in "${vm_uuids[@]}"; do
    echo "Starting VM with UUID: $uuid"
    xe vm-start uuid=$uuid
    if [ $? -ne 0 ]; then
        echo "Failed to start VM with UUID: $uuid."
    fi
done

echo "All stopped VMs have been started."
