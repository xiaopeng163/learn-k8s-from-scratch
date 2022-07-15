ServiceAccount
===================

All Kubernetes clusters have two categories of users:

- service accounts managed by Kubernete, 程序（pod）连接API Server
- normal users. 普通用户，比如通过kubectl连接API Server


Create ServiceAccount
-------------------------


.. code-block:: bash

    $ kubectl create serviceaccount demosa
    $ kubectl describe serviceaccounts demosa
    Name:                demosa
    Namespace:           default
    Labels:              <none>
    Annotations:         <none>
    Image pull secrets:  <none>
    Mountable secrets:   <none>
    Tokens:              <none>
    Events:              <none>
    vagrant@k8s-master:~$

Check ServiceAccount in pod
-----------------------------

Create pod

.. code-block::  yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: client
    spec:
       serviceAccount: demosa
       containers:
       - name: client
         image: busybox
         command:
          - sh
          - -c
          - "sleep 1000000"

查看service account的token,

.. code-block::

  $ kubectl describe pod client

.. code-block:: bash

  $ kubectl exec -it client -- sh
  / #
  / # cd /var/run/secrets/kubernetes.io/serviceaccount
  /var/run/secrets/kubernetes.io/serviceaccount # ls
  ca.crt     namespace  token
  /var/run/secrets/kubernetes.io/serviceaccount # ls -l
  total 0
  lrwxrwxrwx    1 root     root            13 Jul 15 22:49 ca.crt -> ..data/ca.crt
  lrwxrwxrwx    1 root     root            16 Jul 15 22:49 namespace -> ..data/namespace
  lrwxrwxrwx    1 root     root            12 Jul 15 22:49 token -> ..data/token
  /var/run/secrets/kubernetes.io/serviceaccount #


Use ServiceAccount Tokens
----------------------------


.. code-block::  bash

  $ kubectl exec -it client -- sh
  / # cd /var/run/secrets/kubernetes.io/serviceaccount
  /var/run/secrets/kubernetes.io/serviceaccount # TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  /var/run/secrets/kubernetes.io/serviceaccount # CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  /var/run/secrets/kubernetes.io/serviceaccount # curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" -X GET https://kubernetes.default.svc.cluster.local/api
