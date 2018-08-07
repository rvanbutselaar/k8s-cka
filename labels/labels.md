
Labels on pods

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-dev
  labels:
    app: nginx
    version: "1.14.0"
    environment: dev
    tier: frontend
spec:
  containers:
    - name: nginx
      image: nginx:1.14.0-alpine
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-test
  labels:
    app: nginx
    version: "1.14.0"
    environment: test
    tier: frontend
spec:
  containers:
    - name: nginx
      image: nginx:1.14.0-alpine
EOF
```

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: mysql-dev
  labels:
    app: mysql
    version: "5.5"
    environment: dev
    tier: backend
spec:
  containers:
    - name: mysql
      image: mysql:5.5
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: mysql-test
  labels:
    app: mysql
    version: "5.5"
    environment: test
    tier: backend
spec:
  containers:
    - name: mysql
      image: mysql:5.5
EOF
```

```
kubectl get po --show-labels
kubectl get po -l environment=dev --show-labels
kubectl get po -l tier=frontend --show-labels
```


Labels on node (nodeSelector)


```
kubectl label nodes mon-sk8s-a03 redisMater=yes
```

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: redis-dev
  labels:
    app: redis
    version: "4.0.11"
    environment: dev
    tier: backend
spec:
  containers:
    - name: redis
      image: "redis:4.0.11-alpine"
EOF
```

```
kubectl get po -l app=redis -o wide --show-labels
```

```
kubectl delete pod -l app=redis --grace-period=0 --force

cat <<EOF | kubectl apply -f  -
apiVersion: v1
kind: Pod
metadata:
  name: redis-dev
  labels:
    app: redis
    version: "4.0.11"
    environment: dev
    tier: backend
spec:
  containers:
    - name: redis
      image: "redis:4.0.11-alpine"
  nodeSelector:
    redisMater: "yes"
EOF

kubectl get po --show-labels -l app=redis -o wide
```
