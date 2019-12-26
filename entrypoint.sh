#!/bin/bash
set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

. /functions.sh

ipaddr=$(hostname -i | awk ' { print $1 } ')
hostname=$(hostname)
echo "I AM $hostname - $ipaddr"

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
	CMDARG="$@"
fi

curl -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT_HTTPS/apis/apps/v1/namespaces/data/statefulsets/percona-galera | jq .status

ready=$(curl -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT_HTTPS/apis/apps/v1/namespaces/data/statefulsets/percona-galera | jq .status.readyReplicas)

if [[ "$ready" = "null" ]]; then
  echo "I am the Primary Node"
  init_mysql
  write_password_file
  exec mysqld --user=mysql --wsrep_cluster_name=$CLUSTER_NAME --wsrep_node_name=$hostname \
    --wsrep_cluster_address=gcomm:// --wsrep_sst_method=xtrabackup-v2 \
    --wsrep_sst_auth="xtrabackup:$XTRABACKUP_PASSWORD" \
    --wsrep_node_address="$ipaddr" $CMDARG
else
  echo "I am not the Primary Node"
  cluster_join=$(resolveip -s "${K8S_SERVICE_NAME}" || echo "")
  write_password_file
  exec mysqld --user=mysql --wsrep_cluster_name=$CLUSTER_NAME --wsrep_node_name=$hostname \
    --wsrep_cluster_address="gcomm://$cluster_join" --wsrep_sst_method=xtrabackup-v2 \
    --wsrep_sst_auth="xtrabackup:$XTRABACKUP_PASSWORD" \
    --wsrep_node_address="$ipaddr" $CMDARG
fi
