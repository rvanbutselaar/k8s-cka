#!/bin/sh
KUBERNETES_PUBLIC_ADDRESS=10.0.0.111
POD_CIDR=10.200.`hostname|tail -c2`0.0/24

echo 'Create dirs'
mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

echo 'Install Kubernetes'
if [[ ! -f cni-plugins-amd64-v0.6.0.tgz || ! -f kubectl || ! -f kube-proxy || ! -f kubelet ]]; then
    echo "Files not found!"
    wget -q \
      https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz \
      https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubectl \
      https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kube-proxy \
      https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubelet
fi

chmod +x kubectl kube-proxy kubelet
cp kubectl kube-proxy kubelet /usr/local/bin/
tar -xvf cni-plugins-amd64-v0.6.0.tgz -C /opt/cni/bin/

echo 'Copy certificates'
cd /vagrant/pki/
cp ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
cp ca.pem /var/lib/kubernetes/

echo 'Generate config'
/usr/local/bin/kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=/var/lib/kubelet/kubeconfig

/usr/local/bin/kubectl config set-credentials system:node:${HOSTNAME} \
  --client-certificate=${HOSTNAME}.pem \
  --client-key=${HOSTNAME}-key.pem \
  --embed-certs=true \
  --kubeconfig=/var/lib/kubelet/kubeconfig

/usr/local/bin/kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:node:${HOSTNAME} \
  --kubeconfig=/var/lib/kubelet/kubeconfig

/usr/local/bin/kubectl config use-context default --kubeconfig=/var/lib/kubelet/kubeconfig

/usr/local/bin/kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=/var/lib/kubernetes/kube-proxy.kubeconfig

/usr/local/bin/kubectl config set-credentials system:kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=/var/lib/kubernetes/kube-proxy.kubeconfig

/usr/local/bin/kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-proxy \
  --kubeconfig=/var/lib/kubernetes/kube-proxy.kubeconfig

/usr/local/bin/kubectl config use-context default --kubeconfig=/var/lib/kubernetes/kube-proxy.kubeconfig

echo 'Configure CNI'
cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

cat <<EOF | sudo tee /etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.3.1",
    "type": "loopback"
}
EOF

echo 'Configure kubelet'
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF

cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Wants=docker.socket

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --allow-privileged \\
  --cgroup-driver=systemd \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


echo 'Configure kube-proxy'
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-proxy.kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo 'Start kubernetes'
systemctl daemon-reload
systemctl enable kubelet kube-proxy
systemctl start kubelet kube-proxy


# echo 'Configure routing'
# case $HOSTNAME in
#   (kube-node1) ip route add 10.200.20.0/24 via 10.0.0.212 dev enp0s8; ip route add 10.200.90.0/24 via 10.0.0.111 dev enp0s8 || true;;
#   (kube-node2) ip route add 10.200.10.0/24 via 10.0.0.211 dev enp0s8; ip route add 10.200.90.0/24 via 10.0.0.111 dev enp0s8 || true;;
#   (*)   echo "not adding any rules";;
# esac
