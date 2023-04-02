FROM postgres:12

# Install patroni
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y -q && apt-get install -y python3 python3-pip wget
RUN pip3 install psycopg[binary]>=3.0.0 patroni[etcd3]==3.0.2

# Install wal-g
RUN wget -O /usr/local/bin/walg https://github.com/wal-g/wal-g/releases/download/v2.0.1/wal-g-fdb-ubuntu-20.04-amd64 && \
    chmod +x /usr/local/bin/walg

# Prepare volumes
VOLUME /opt/postgres
VOLUME /etc/patroni
RUN mkdir /opt/postgres && chown postgres:postgres /opt/postgres
RUN mkdir /etc/patroni  && chown postgres:postgres /etc/patroni

# Start patroni
CMD ["/usr/local/bin/patroni", "/etc/patroni/patroni.yml"]
