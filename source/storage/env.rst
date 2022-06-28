Environment Variables
========================

Configuring application in pods:

- command Line Arguments
- Environment Variables
- ConfigMaps


Environment Variables inside Pods
-----------------------------------

- User defined
- System defined


.. warning::

    Environment Variables can't be updated once the pod is created


Defining Environment Variables
---------------------------------

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: pod-env
    spec:
      containers:
      - name: producer
        image: busybox
        command: ["sh", "-c", "while true; do echo $NAME >> /tmp/index.html; sleep 10; done"]
        env:
        - name: NAME
          value: Hello World

apply and check the file

.. code-block:: bash

    vagrant@k8s-master:~$ kubectl apply -f pod-env.yml
    pod/pod-env created
    vagrant@k8s-master:~$ kubectl get pods
    NAME      READY   STATUS    RESTARTS   AGE
    pod-env   1/1     Running   0          17s
    vagrant@k8s-master:~$ kubectl exec pod-env -- more /tmp/index.html
    Hello World
    Hello World
    Hello World
    Hello World


Another example for MySQL containers

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: root
