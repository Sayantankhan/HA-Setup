> docker compose build
> docker compose up -d

Inside Each Node
> docker exec -it node1 bash
> systemctl start corosync
> systemctl start pacemaker

```bash
crm configure property stonith-enabled=false
crm configure property no-quorum-policy=ignore

crm configure primitive flask-api ocf:heartbeat:anything \
  params binfile="/usr/local/bin/start-api" \
         pidfile="/var/run/flask-api.pid" \
         logfile="/var/log/flask-api.log" \
  op monitor interval=10s

crm configure colocation col_api inf: flask-api
crm configure order order_api inf: flask-api

```

crm status

watch crm status

-- PaceMaker Rules ---

# Make node1 preferred (active)
crm configure location prefer-node1 flask-api 100: node1

# Lower priority for node2 (hot standby)
crm configure location prefer-node2 flask-api 50: node2

# Even lower for node3 (cold standby)
crm configure location prefer-node3 flask-api 10: node3

# Cold Standby
crm configure location avoid-node3 flask-api -INFINITY: node3

# Remove the rule
# Clear Old Constraints
crm configure delete avoid-node3

# Set Resource Location Constraint - Manually promote a node
crm configure location force-api-on-node2 flask-api inf: node2
# This tells Pacemaker: "Run flask-api on node2 no matter what."

# Manually Stop on Current Node
crm resource stop flask-api
