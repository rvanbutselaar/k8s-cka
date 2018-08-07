```kubectl drain mon-sk8s-a03 --ignore-daemonsets```

Change url of API server inside /etc/kubernetes/node-kubeconfig.yaml to: http://localhost:8080

Temp disable cloud-provider config

```sudo systemctl daemon-reload && sudo systemctl restart kubelet && sudo systemctl status kubelet```

```
CONFIG_DIR=/etc/kubernetes/manifests
LOG_DIR=/var/log

sudo docker run -it --rm --privileged --net=host \
  -v /:/rootfs -v $CONFIG_DIR:$CONFIG_DIR -v $LOG_DIR:/var/result \
  k8s.gcr.io/node-test:0.2

sudo docker run -it --rm --privileged --net=host \
  -v /:/rootfs -v $CONFIG_DIR:$CONFIG_DIR -v $LOG_DIR:/var/result \
  -e FOCUS=MirrorPod \
  k8s.gcr.io/node-test:0.2
```

https://v1-10.docs.kubernetes.io/docs/setup/node-conformance/
