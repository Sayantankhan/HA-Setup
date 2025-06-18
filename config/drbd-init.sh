#!/bin/bash

DISK_IMG="/drbd/disk.img"
DRBD_RES="drbddata"

# Create disk image if not exists
if [ ! -f "$DISK_IMG" ]; then
    echo "Creating 100MB disk image at $DISK_IMG..."
    dd if=/dev/zero of=$DISK_IMG bs=1M count=100
fi

# Check if already associated with a loop device
LOOP_DEV=$(losetup -j "$DISK_IMG" | cut -d: -f1)

if [ -z "$LOOP_DEV" ]; then
    # Not yet attached, attach it
    LOOP_DEV=$(losetup --find --show "$DISK_IMG")
    echo "Attached $DISK_IMG to $LOOP_DEV"
else
    echo "$DISK_IMG is already attached to $LOOP_DEV"
fi

# Create metadata if not already created
drbdadm create-md $DRBD_RES

# Bring up the resource
drbdadm up $DRBD_RES

# Promote node1 to primary
if hostname | grep -q node1; then
    drbdadm -- --overwrite-data-of-peer primary $DRBD_RES
fi
