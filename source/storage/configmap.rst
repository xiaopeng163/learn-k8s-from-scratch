ConfigMap
=============

https://kubernetes.io/docs/concepts/configuration/configmap/

Key value pairs exposed into a pod used application configuration settings

Decouple application and pod configurations


Create ConfigMaps
----------------------

.. code-block:: bash

    kubectl create configmap mysql-cfg \
      --from-literal=MYSQL_ROOT_PASSWORD=root \
      --from-literal=MYSQL_USER=demo \
      --from-literal=MYSQL_PASSWORD=demo

from a file

.. code-block:: bash

    kubectl create configmap mysql-cfg --from-file=appconfig

from yaml file

.. code-block:: yaml

    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: appconfig
    data:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_USER: demo
      MYSQL_PASSWORD: demo


Using ConfigMaps
--------------------


Environment Variables
~~~~~~~~~~~~~~~~~~~~~~~~~


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
          valueFrom:
            configMapKeyRef:
                name: mysql-secret
                key: MYSQL_ROOT_PASSWORD
        - name: MYSQL_USER
          valueFrom:
            configMapKeyRef:
                name: mysql-secret
                key: MYSQL_USER
        - name: MYSQL_PASSWORD
          valueFrom:
            configMapKeyRef:
                name: mysql-secret
                key: MYSQL_PASSWORD

or

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        envFrom:
          - configMapRef:
              name: appconfig


Volumes
~~~~~~~~~~~


.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: pod-env
    spec:
      volumes:
      - name: appconfig
        configMap:
          name: appconfig
      containers:
      - name: busybox
        image: busybox
        command: ["sh", "-c", "while true; do echo $(date) >> /tmp/index.html; sleep 10; done"]
        volumeMounts:
        - name: appconfig
          mountPath: "/etc/appconfig"
