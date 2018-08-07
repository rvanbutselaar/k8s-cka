```
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"
```


```
export ETCDCTL_API="3"
export ETCDCTL_CACERT="/etc/calico/certs/ca_cert.crt"
export ETCDCTL_CERT="/etc/calico/certs/cert.crt"
export ETCDCTL_KEY="/etc/calico/certs/key.pem"
export ETCD_TRUSTED_CA_FILE="/etc/ssl/etcd/ssl/ca.pem"

etcdctl  --endpoints=https://10.144.31.36:2379 get /registry/secrets/kube-system/kubernetes-the-hard-way | hexdump -C
```
