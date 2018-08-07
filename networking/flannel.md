Based on UDP encapsulation and storages information inside etcd. By default, every K8s node has it's own /24 private ip range and one public/private ip address. Etcd is used to store this information so flanneld knows how to route traffic.


```admin@ip-172-20-33-102:~$ etcdctl ls /coreos.com/network/subnets
/coreos.com/network/subnets/100.96.1.0-24
/coreos.com/network/subnets/100.96.2.0-24
/coreos.com/network/subnets/100.96.3.0-24

admin@ip-172-20-33-102:~$ etcdctl get /coreos.com/network/subnets/100.96.2.0-24
{"PublicIP":"172.20.54.98"}```
