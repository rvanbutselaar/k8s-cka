Normal deployment:

```
cat <<EOF | kubectl apply --record -f -
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    run: nginx-prod
    app: nginx
    environment: prod
  name: nginx-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      run: nginx-prod
      app: nginx
      environment: prod
  minReadySeconds: 10
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate      
  template:
    metadata:
      labels:
        run: nginx-prod
        app: nginx
        environment: prod
        version: "1.14.0-alpine"
    spec:
      containers:
      - image: nginx:1.14.0-alpine
        name: nginx-prod
EOF
```

Update version of nginx


```
cat <<EOF | kubectl apply --record -f -
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    run: nginx-prod
    app: nginx
    environment: prod
  name: nginx-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      run: nginx-prod
      app: nginx
      environment: prod
  minReadySeconds: 10
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate      
  template:
    metadata:
      labels:
        run: nginx-prod
        app: nginx
        environment: prod
        version: "1.15.2-alpine"
    spec:
      containers:
      - image: nginx:1.15.2-alpine
        name: nginx-prod
EOF
```

Failed update (version typo):


```
cat <<EOF | kubectl apply --record -f -
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    run: nginx-prod
    app: nginx
    environment: prod
  name: nginx-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      run: nginx-prod
      app: nginx
      environment: prod
  minReadySeconds: 10
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate      
  template:
    metadata:
      labels:
        run: nginx-prod
        app: nginx
        environment: prod
        version: "2"
    spec:
      containers:
      - image: nginx:2
        name: nginx-prod
EOF
```

```
kubectl rollout history deployment/nginx-prod
kubectl rollout history deployment/nginx-prod --revision=2
kubectl rollout undo deployment/nginx-prod
kubectl rollout undo deployment/nginx-prod --to-revision=2
```

Recreate update strategy

```
cat <<EOF | kubectl apply --record -f -
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    run: redis-prod
    app: redis
    environment: prod
  name: redis-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      run: redis-prod
      app: redis
      environment: prod
  minReadySeconds: 10
  strategy:
    type: Recreate      
  template:
    metadata:
      labels:
        run: redis-prod
        app: redis
        environment: prod
        version: "3.2.12-alpine"
    spec:
      containers:
      - image: redis:3.2.12-alpine
        name: redis-prod
EOF
```

Recreate update strategy

```
cat <<EOF | kubectl apply --record -f -
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    run: redis-prod
    app: redis
    environment: prod
  name: redis-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      run: redis-prod
      app: redis
      environment: prod
  minReadySeconds: 10
  strategy:
    type: Recreate      
  template:
    metadata:
      labels:
        run: redis-prod
        app: redis
        environment: prod
        version: latest
    spec:
      containers:
      - image: redis:latest
        name: redis-prod
EOF
```
