#!/bin/sh
echo 'Edit hosts file'
cat > /etc/hosts <<EOF
127.0.0.1 localhost localhost.localdomain
::1 localhost6 localhost6.localdomain

10.0.0.111 kube-master1
10.0.0.211 kube-node1
10.0.0.212 kube-node2
EOF

echo 'Disable swap'
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

echo 'Disable SElinux'
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

echo 'Enable iptable kernel parameter'
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
EOF
sysctl -p

echo 'Install requirements'
yum install -y docker wget net-tools nmap-ncat tcpdump

systemctl enable docker && systemctl start docker
