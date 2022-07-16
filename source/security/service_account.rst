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

或者通过jsonpath过滤

.. code-block:: bash

  $ kubectl get pods client -o jsonpath='{.spec.containers[0].volumeMounts}' | python3 -m json.tool
  [
      {
          "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
          "name": "kube-api-access-tvr98",
          "readOnly": true
      }
  ]

.. code-block:: bash

  $ kubectl exec -it client -- sh
  /omd #
  /omd #
  /omd # cd /var/run/secrets/kubernetes.io/serviceaccount
  /run/secrets/kubernetes.io/serviceaccount # ls -l
  total 0
  lrwxrwxrwx    1 root     root            13 Jul 16 14:15 ca.crt -> ..data/ca.crt
  lrwxrwxrwx    1 root     root            16 Jul 16 14:15 namespace -> ..data/namespace
  lrwxrwxrwx    1 root     root            12 Jul 16 14:15 token -> ..data/token
  /run/secrets/kubernetes.io/serviceaccount #

ServiceAccount Authentication
--------------------------------


.. code-block::  bash

  $ kubectl exec -it client -- sh
  /omd # cd /var/run/secrets/kubernetes.io/serviceaccount
  /run/secrets/kubernetes.io/serviceaccount # TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  /run/secrets/kubernetes.io/serviceaccount # CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  /run/secrets/kubernetes.io/serviceaccount #
  /run/secrets/kubernetes.io/serviceaccount # curl --cacert $CACERT -X GET https://kubernetes.default.svc.cluster.local/api
  {
    "kind": "Status",
    "apiVersion": "v1",
    "metadata": {},
    "status": "Failure",
    "message": "forbidden: User \"system:anonymous\" cannot get path \"/api\"",
    "reason": "Forbidden",
    "details": {},
    "code": 403
  }/run/secrets/kubernetes.io/serviceaccount #
  /run/secrets/kubernetes.io/serviceaccount # curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" -X GET https://kubern
  etes.default.svc.cluster.local/api
  {
    "kind": "APIVersions",
    "versions": [
      "v1"
    ],
    "serverAddressByClientCIDRs": [
      {
        "clientCIDR": "0.0.0.0/0",
        "serverAddress": "192.168.56.10:6443"
      }

但是此时service account并没有访问集群资源的权限。

.. code-block:: bash

  /run/secrets/kubernetes.io/serviceaccount # curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" -X GET https://kubern
  etes.default.svc.cluster.local/api/v1/namespaces/default/pods?limit=500
  {
    "kind": "Status",
    "apiVersion": "v1",
    "metadata": {},
    "status": "Failure",
    "message": "pods is forbidden: User \"system:serviceaccount:default:demosa\" cannot list resource \"pods\" in API group \"\" in the namespace \"default\"",
    "reason": "Forbidden",
    "details": {
      "kind": "pods"
    },
    "code": 403
  }/run/secrets/kubernetes.io/serviceaccount #

ServiceAccount Authorization
--------------------------------

.. code-block:: bash

  $ kubectl auth can-i list pods --as=system:serviceaccount:default:demosa
  no
  $ kubectl get pods -v 6 --as=system:serviceaccount:default:demosa
  I0716 14:46:05.735051   61770 loader.go:372] Config loaded from file:  /home/vagrant/.kube/config
  I0716 14:46:05.761522   61770 round_trippers.go:553] GET https://192.168.56.10:6443/api/v1/namespaces/default/pods?limit=500 403 Forbidden in 20 milliseconds
  I0716 14:46:05.762209   61770 helpers.go:222] server response object: [{
    "kind": "Status",
    "apiVersion": "v1",
    "metadata": {},
    "status": "Failure",
    "message": "pods is forbidden: User \"system:serviceaccount:default:demosa\" cannot list resource \"pods\" in API group \"\" in the namespace \"default\"",
    "reason": "Forbidden",
    "details": {
      "kind": "pods"
    },
    "code": 403
  }]
  Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:default:demosa" cannot list resource "pods" in API group "" in the namespace "default"

RBAC
~~~~~~~

.. code-block:: bash

  $ kubectl create role demorole --verb=get,list --resource=pods
  $ kubectl create rolebinding demorolebinding --role=demorole --serviceaccount=default:demosa
  rolebinding.rbac.authorization.k8s.io/demorolebinding created
  $ kubectl auth can-i list pods --as=system:serviceaccount:default:demosa
  yes

现在我们可以进入到一个绑定此service account的pod进行测试了

.. code-block:: bash


  $ kubectl exec -it client -- sh
  /omd # cd /var/run/secrets/kubernetes.io/serviceaccount
  /run/secrets/kubernetes.io/serviceaccount # TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  /run/secrets/kubernetes.io/serviceaccount # CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  /run/secrets/kubernetes.io/serviceaccount #
  /run/secrets/kubernetes.io/serviceaccount # curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" -X GET https://kubern
  etes.default.svc.cluster.local/api/v1/namespaces/default/pods?limit=500
  {
    "kind": "PodList",
    "apiVersion": "v1",
    "metadata": {
      "resourceVersion": "1625465"
    },
    ....
    ....


