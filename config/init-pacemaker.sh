#!/bin/bash

echo "[INFO] Waiting for Pacemaker to be ready..."

# Retry loop until crm_mon runs without transport error
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

# After timeout, if not ready, exit
if [ $? -ne 0 ]; then
    echo "[ERROR] Pacemaker not ready after waiting."
    exit 1
fi

echo "[INFO] Setting Pacemaker properties and primitive..."

crm configure property stonith-enabled=false
crm configure property no-quorum-policy=ignore

crm configure primitive flask-api ocf:heartbeat:anything \
  params binfile="/usr/local/bin/start-api" \
         pidfile="/var/run/flask-api.pid" \
         logfile="/var/log/flask-api.log" \
  op monitor interval=10s

crm configure colocation col_api inf: flask-api
crm configure order order_api inf: flask-api

echo "[INFO] Pacemaker configuration complete."

exec "$@"
