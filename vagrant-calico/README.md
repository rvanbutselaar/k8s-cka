First genereate some certs

```
cd pki
./generate-certs.sh
```

At this moment we only support 1 master and 2 worker nodes

```
sudo cp /var/lib/kubernetes/admin.kubeconfig .kube/config
kubectl get cs,no -o wide
kubectl run nginx --image=nginx --replicas=2
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get all -o wide

kubectl -n kube-system expose deployment kubernetes-dashboard --port=443 --type=NodePort --name=kubernetes-dashboard-nodeport
```

kube-node2: `ip route add 10.200.10.0/24 via 10.0.0.211 dev enp0s8`
kube-node1: `ip route add 10.200.20.0/24 via 10.0.0.212 dev enp0s8`


```
vagrant up
kubectl --kubeconfig=admin.kubeconfig -n kube-system describe secret `kubectl --kubeconfig=admin.kubeconfig  -n kube-system get secret|grep admin-token|cut -d " " -f1`|grep "token:"|tr -s " "|cut -d " " -f2
kubectl --kubeconfig=admin.kubeconfig proxy
http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login
```


Flannel:

vim /etc/systemd/system/kube-controller-manager.service
--allocate-node-cidrs=true \

echo 'Create flannel'
/usr/local/bin/kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
