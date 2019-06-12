FROM percona/percona-xtradb-cluster:5.7.25

COPY entrypoint.sh /entrypoint.sh
COPY functions.sh /functions.sh
