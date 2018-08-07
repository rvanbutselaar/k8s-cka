BGP based, creates routes based on information from K8s / etcd. Create's a caliXXX interface for every pod. Calico knows where the 192/26 lives because this information is in etcd. For example:

```10.233.91.192/26 via 10.144.31.41 dev tunl0 proto bird onlink```

```
cat /etc/etcd.env

export ETCDCTL_CACERT=/etc/ssl/etcd/ssl/ca.pem
export ETCDCTL_CERT=/etc/ssl/etcd/ssl/member-mon-mk8s-a01.pem
export ETCDCTL_KEY=/etc/ssl/etcd/ssl/member-mon-mk8s-a01-key.pem
export ETCDCTL_API=3

etcdctl --debug --endpoints=https://10.144.31.36:2379  endpoint status

ETCDCTL_API=2 etcdctl --key-file=/etc/ssl/etcd/ssl/member-mon-mk8s-a01-key.pem --ca-file=/etc/ssl/etcd/ssl/ca.pem --cert-file=/etc/ssl/etcd/ssl/member-mon-mk8s-a01.pem --endpoints=https://10.144.31.36:2379 ls /calico -r

ETCDCTL_API=2 etcdctl --key-file=/etc/ssl/etcd/ssl/member-mon-mk8s-a01-key.pem --ca-file=/etc/ssl/etcd/ssl/ca.pem --cert-file=/etc/ssl/etcd/ssl/member-mon-mk8s-a01.pem --endpoints=https://10.144.31.36:2379 get /calico/bgp/v1/host/mon-sk8s-a03/ip_addr_v4
10.144.31.41

ETCDCTL_API=2 etcdctl --key-file=/etc/ssl/etcd/ssl/member-mon-mk8s-a01-key.pem --ca-file=/etc/ssl/etcd/ssl/ca.pem --cert-file=/etc/ssl/etcd/ssl/member-mon-mk8s-a01.pem --endpoints=https://10.144.31.36:2379 get /calico/ipam/v2/assignment/ipv4/block/10.233.91.192-26
{"cidr":"10.233.91.192/26","affinity":"host:mon-sk8s-a03" ...
```
