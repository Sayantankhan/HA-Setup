#!/bin/bash

echo "[INFO] Waiting for Corosync membership..."
expected_peers=3  # Total nodes - 1
for i in {1..30}; do
    connected=$(corosync-cfgtool -s | grep -c "connected")
    if [ "$connected" -ge "$expected_peers" ]; then
        echo "[INFO] Corosync is up. ($connected/$expected_peers peers connected)"
        break
    fi
    echo "[INFO] Waiting for Corosync... ($i) ($connected/$expected_peers connected)"
    sleep 1
done

echo "[INFO] Waiting for Pacemaker to be ready..."
for i in {1..30}; do
    crm_mon -1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "[INFO] Pacemaker is ready!"
        break
    else
        echo "[INFO] Waiting for Pacemaker... ($i)"
        sleep 2
    fi
done

if ! crm_mon -1 > /dev/null 2>&1; then
    echo "[ERROR] Pacemaker not ready after waiting."
    exit 1
fi

echo "[INFO] Setting Pacemaker cluster properties..."
crm configure property stonith-enabled=false
crm configure property no-quorum-policy=ignore

# Create the primitive if not exists
if ! crm_resource --resource flask-api --query >/dev/null 2>&1; then
    echo "[INFO] Creating flask-api primitive..."
    crm configure primitive flask-api ocf:heartbeat:anything \
      params binfile="/usr/local/bin/start-api" \
             pidfile="/var/run/flask-api.pid" \
             logfile="/var/log/flask-api.log" \
      op monitor interval=10s
else
    echo "[INFO] Primitive 'flask-api' already exists. Skipping."
fi

# # Create the clone wrapper if not exists
# if ! crm configure show flask-api-clone >/dev/null 2>&1; then
#     echo "[INFO] Creating clone of flask-api..."
#     crm configure clone flask-api-clone flask-api
# else
#     echo "[INFO] Clone 'flask-api-clone' already exists. Skipping."
# fi

echo "[INFO] Pacemaker configuration complete."
exec "$@"