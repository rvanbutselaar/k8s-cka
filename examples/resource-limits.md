```
kubectl create namespace rslimits

cat <<EOF | kubectl apply -f  -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: rslimits
spec:
  hard:
    pods: "2"
    requests.cpu: "10"
    requests.memory: 4Gi
    limits.cpu: "10"
    limits.memory: 5Gi
EOF

cat <<EOF | kubectl apply -f  -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
  namespace: rslimits
spec:
  hard:
    configmaps: "10"
    persistentvolumeclaims: "4"
    replicationcontrollers: "20"
    secrets: "10"
    services: "10"
    services.loadbalancers: "2"
EOF
kubectl get quota --namespace=rslimits
```

```
kubectl run nginx --image=nginx --replicas=2 --namespace=rslimits --limits='cpu=200m,memory=512Mi' --requests='cpu=100m,memory=256Mi'
kubectl -n rslimits get po,deployment,rs
kubectl -n rslimits scale deployment/nginx --replicas=3
```
