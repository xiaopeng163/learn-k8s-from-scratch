

$ kubectl get events --watch
$ kubectl apply -f pod.yml



static pod
----------------


sudo cat /var/lib/kubelet/config.yaml


static pod in /etc/kubernetes/manifests/ 


multi-container pod
-----------------------------

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: multicontainer-pod
    spec:
      containers:
      - name: producer
        image: busybox
        command: ["sh", "-c", "while ture; do echo $(hostname) $(date) >> /var/log/index.html; sleep 10; done"]
        volumeMounts:
        - name: webcontent
          mountPath: /var/log
      - name: consumer
        image: nginx
        ports:
          - containerPort: 80
        volumeMounts:
        - name: webcontent
          mountPath: /user/share/nginx/html
      volumes:
      - name: webcontent
        emptyDir: {}


kubectl port-forward multicontainer-pod 8080:80 &

curl http://127.0.0.1:8080


Pod with init containers
---------------------------

.. code-block:: yaml

  apiVersion: v1
  kind: Pod
  metadata:
    name: pod-with-init-containers
  spec:
    initContainers:
    - name: init-service
      image: busybox
      command: ["sh", "-c", "echo waiting for sercice; sleep 2"]
    - name: init-database
      image: busybox
      command: ["sh", "-c", "echo waiting for database; sleep 2"]
    containers:
    - name: app-container
      image: nginx
        image: busybox




Pod Lifecycle
--------------------


Pod Health
-------------

LivenessProbes
~~~~~~~~~~~~~~~~~~

- Runs a diagnostic check on a container
- Per container setting
- On failure, the kubelet restarts the container
- Container Restart Policy
- Give Kubernetes a better understanding of our applications

readinessProbes
~~~~~~~~~~~~~~~~~~~~~~

- Runs a diagnostic check on a container
- Per container setting
- Won't receive traffic from a service until it succeeds
- On failure, remove Pod from load balancing
- Applications that temporarily can't respond to a request
- Prevents users from seeting errors

type of Diagnostic Checks for Probes

- Exec
- tcpSocket
- httpGet