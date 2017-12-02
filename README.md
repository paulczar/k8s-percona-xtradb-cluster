# k8s-percona-pxc

Extends the official [Percona XtraDB Cluster image](https://github.com/percona/percona-docker/tree/master/pxc-57) to work natively in Kubernetes.

The Percona image supports specifying a peer to join or ETCD as service discovery. However etcd is unecessary with Kubernetes as Kubernetes already knows enough about what is running to provide similar functionality.

# How does it work?

If the environment variable `DISCOVERY_SERVICE` is set to `kubernetes` it simply exploits the nature of the Kubernetes **StatefulSet** and headless **Service** resources to determine if there is already
a primary MySQL server to cluster to.

There is an example [Kubernetes manifest](kubernetes/percona-galera-xtradb.yaml) included that is written to be as compatible as possible
so it doesn't do any volume mapping or fancy. If you want to use it for real workloads you'll want
to spend some time making the manifest production ready.

# Demo

This assumes you already have kubernetes running.

Deploy a 3 node Percona XtraDB Cluster:

```
$ kubectl create -f kubernetes
```

Wait a few minute and then check that all three pods are running:

```
$ kubectl get pods
NAME               READY     STATUS    RESTARTS  AGE
percona-galera-0   1/1       Running   4         5m
percona-galera-1   1/1       Running   4         3m
percona-galera-2   1/1       Running   4         1m
```

Check that they have clustered correctly:

```
$ kubectl exec -ti percona-galera-0 -- \
    mysql -pnot-a-secure-password -e "SHOW GLOBAL STATUS LIKE 'wsrep_cluster_size'"
mysql: [Warning] Using a password on the command line interface can be insecure.
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| wsrep_cluster_size | 3     |
+--------------------+-------+
```
