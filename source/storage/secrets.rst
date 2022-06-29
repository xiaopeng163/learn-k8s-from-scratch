Secrets
=========

https://kubernetes.io/docs/concepts/configuration/secret/

- Store sensitive information as Object
- Retrieve for later use
- passwords, API tokens, keys and certificates
- safer,flexible


Properties of Secrets
-------------------------

- base64 encoded
- Encryption can be configured
- Stored in etcd
- Namepaced
- Pod can not start if reference unavaiable Secrets


Create Secrets
-------------------


from kubectl
~~~~~~~~~~~~~~~

.. code-block:: bash

    kubectl create secret generic mysql-secret \
      --from-literal=MYSQL_ROOT_PASSWORD=root \
      --from-literal=MYSQL_USER=demo \
      --from-literal=MYSQL_PASSWORD=demo

from yaml
~~~~~~~~~~~~~

or from yaml, secret的值是经过base64的编码的

.. code-block:: yaml

    apiVersion: v1
    kind: Secret
    metadata:
      name: mysql-secret
    type: Opaque
    data:
      MYSQL_PASSWORD: ZGVtbw==
      MYSQL_ROOT_PASSWORD: cm9vdA==
      MYSQL_USER: ZGVtbw==


encode:

.. code-block::  bash

    vagrant@k8s-master:~$ echo root | base64
    cm9vdAo=
    vagrant@k8s-master:~$ echo demo | base64
    ZGVtbwo=

decode:

.. code-block::  bash

    $ echo ZGVtbw== | base64 --decode
    demo

from config file
~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    apiVersion: v1
    kind: Secret
    metadata:
      name: mysecret
    type: Opaque
    stringData:
      config.yaml: |
        MYSQL_ROOT_PASSWORD: root
        MYSQL_PASSWORD: demo
        MYSQL_USER: demo



Using Secrets in Pods
------------------------

Environment Variables
~~~~~~~~~~~~~~~~~~~~~~~




Volumes or Files
~~~~~~~~~~~~~~~~~~



type of Secrets
------------------

- updatable
- Immutable


