# Filename: Dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    pacemaker corosync crmsh resource-agents iputils-ping \
    python3 python3-pip systemd systemd-sysv vim net-tools \
    && apt-get clean

RUN pip3 install flask

COPY app.py /usr/local/bin/app.py

COPY config/init-pacemaker.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-pacemaker.sh

# Optional wrapper to run under Pacemaker control
RUN echo -e '#!/bin/bash\npython3 /usr/local/bin/app.py' > /usr/local/bin/start-api && chmod +x /usr/local/bin/start-api

CMD ["/sbin/init"]

