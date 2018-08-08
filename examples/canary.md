
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-dev-stable
  labels:
    app: nginx-canary
    version: "1.14.0"
    environment: dev
    tier: frontend
    track: stable
spec:
  containers:
    - name: nginx
      image: nginx:1.14.0-alpine
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-dev-canary
  labels:
    app: nginx-canary
    version: "1.15.2"
    environment: dev
    tier: frontend
    track: canary
spec:
  containers:
    - name: nginx
      image: nginx:1.15.2-alpine
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: nginx-svc-canary
  name: nginx-svc-canary
spec:
  ports:
  - name: http
    port: 8181
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-canary
    tier: frontend
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
EOF
```

After all good you can update nginx-dev-stable to the latest version and remove nginx-dev-canary.
