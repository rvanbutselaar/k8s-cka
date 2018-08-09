#!/bin/sh

echo 'Install flannel'
yum install -y flannel

echo 'Create flannel config file...'

cat <<EOF | tee /etc/sysconfig/flanneld
# Flanneld configuration options
FLANNEL_ETCD_ENDPOINTS="http://10.0.0.111:2379"
FLANNEL_ETCD_PREFIX="/kube-centos/network"
FLANNEL_OPTIONS="-iface=enp0s8"
EOF

echo 'Enable flannel with host-gw backend'
rm -rf /run/flannel/
systemctl daemon-reload
systemctl enable flanneld
systemctl start flanneld
