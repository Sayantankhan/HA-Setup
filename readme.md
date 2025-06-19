# HA-Setup: High Availability with Pacemaker + Corosync + Docker

This repository sets up a simple high-availability (HA) cluster using **Pacemaker** and **Corosync** across multiple Docker containers. It includes an example service (`flask-api`) managed as a cluster resource.

---

## 🚀 Quick Start

### Build and Start Cluster
```bash
docker compose build
docker compose up -d
```

---

## 🐧 Inside Each Node

Run this 
```bash
docker exec -it node1 /usr/local/bin/init-pacemaker.sh
```

Once the containers are running, you can access and configure each node:

```bash
docker exec -it node1 bash
systemctl start corosync
systemctl start pacemaker
```

---

## 🛠️ Cluster Configuration

### Disable STONITH and Quorum Check
```bash
crm configure property stonith-enabled=false
crm configure property no-quorum-policy=ignore
```

### Add the Flask API as a Cluster Resource
```bash
crm configure primitive flask-api ocf:heartbeat:anything \
  params binfile="/usr/local/bin/start-api" \
         pidfile="/var/run/flask-api.pid" \
         logfile="/var/log/flask-api.log" \
  op monitor interval=10s

crm configure colocation col_api inf: flask-api
crm configure order order_api inf: flask-api
```

### Monitor Resource Status
```bash
crm status
watch crm status
```

---

## 🎯 Pacemaker Rules

### Set Node Preferences

- **Prefer `node1` (Active)**
```bash
crm configure location prefer-node1 flask-api 100: node1
```

- **Set Lower Priority for Standby Nodes**
```bash
crm configure location prefer-node2 flask-api 50: node2
crm configure location prefer-node3 flask-api 10: node3
```

- **Cold Standby (Avoid a Node Completely)**
```bash
crm configure location avoid-node3 flask-api -INFINITY: node3
```

- **Remove a Rule**
```bash
crm configure delete avoid-node3
```

---

### Manual Overrides

- **Force Resource to Run on node2**
```bash
crm configure location force-api-on-node2 flask-api inf: node2
```

- **Manually Stop the Resource**
```bash
crm resource stop flask-api
```

---
## DRBD Configuration

Correct Host-Side Commands to Install DRBD
```bash
sudo apt update
sudo apt install -y curl gnupg

# 5. Update apt and install DRBD
sudo apt update
sudo apt install -y drbd-dkms drbd-utils

# 6. Load the DRBD module
sudo modprobe drbd
```

```bash 
drbdadm --version
lsmod | grep drbd
```


```bash
docker exec -it node1 /usr/local/bin/drbd-init.sh
docker exec -it node2 /usr/local/bin/drbd-init.sh
```

Then on node1 to promote:
```bash
drbdadm -- --overwrite-data-of-peer primary drbddata
mkfs.ext4 /dev/drbd0
mount /dev/drbd0 /mnt/drbddata
```

---
## 🧩 Components

- **Pacemaker**: Cluster resource manager
- **Corosync**: Messaging layer to sync cluster state
- **Docker**: Lightweight environment to simulate multiple HA nodes
- **Anything OCF Agent**: Used to wrap arbitrary scripts/services

---

## 📁 Project Structure

```
HA-Setup/
├── docker-compose.yml
├── setup files
├── Dockerfile
└── README.md
```

---

## 📌 Notes

- This setup is ideal for **learning**, **testing**, and **POCs**.
- For production-grade HA, consider shared storage, fencing/STONITH, and secure authentication.

---

## 📜 License

MIT License
