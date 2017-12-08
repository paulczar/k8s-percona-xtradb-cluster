FROM percona/percona-xtradb-cluster:5.7.19

COPY entrypoint.sh /entrypoint.sh
COPY functions.sh /functions.sh
