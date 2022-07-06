Services
=========

https://kubernetes.io/docs/concepts/services-networking/service/

- Persistent endpoint access for clients
- Adds persistency to the ephemerality of Pods
- Networking abstration providing persistent virutal IP and DNS
- Load balances to the backend Pods
- Automatically updated during pod controller operations


How Services Work
---------------------

Services match pods using Labels and Selectors

Creates and registers Endpoints in the Service (Pod IP and port pair)

Implemented in the kube-proxy on the Node in iptables

Kube-proxy watches the API Server and Endpoints

.. image:: ../_static/network/service.gif
   :alt: pod-network


Lab
-----

创建一个Deployment

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: hello-world
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: hello-world
      template:
        metadata:
          labels:
            app: hello-world
        spec:
          containers:
          - name: hello-world
            image: gcr.io/google-samples/hello-app:1.0
            ports:
            - containerPort: 8080

Service Types
---------------

ClusterIP(Default)
~~~~~~~~~~~~~~~~~~~~~~

when application deson't need to be accessed by out side of the cluster, 会分配到一个内部的cluster IP。

.. code-block:: bash

    $ kubectl expose deployment hello-world --port=80 --target-port=8080
    $ kubectl get svc
    NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
    hello-world   ClusterIP   10.107.138.203   <none>        80/TCP    119s
    kubernetes    ClusterIP   10.96.0.1        <none>        443/TCP   36d
    $ curl 10.107.138.203
    Hello, world!
    Version: 1.0.0
    Hostname: hello-world-55594b4d48-nmtvd
    $ curl 10.107.138.203
    Hello, world!
    Version: 1.0.0
    Hostname: hello-world-55594b4d48-st7fx

yaml format

.. code-block:: bash

    $ kubectl get svc hello-world -o yaml


How it works (deep dive)

.. code-block::  bash

    $ sudo iptables -t nat -L KUBE-SERVICES -n  | column -t
    Chain                      KUBE-SERVICES  (2   references)
    target                     prot           opt  source       destination
    KUBE-SVC-JD5MR3NA4I4DYORP  tcp            --   0.0.0.0/0    10.96.0.10      /*  kube-system/kube-dns:metrics  cluster  IP          */     tcp   dpt:9153
    KUBE-SVC-NPX46M4PTMTKRN6Y  tcp            --   0.0.0.0/0    10.96.0.1       /*  default/kubernetes:https      cluster  IP          */     tcp   dpt:443
    KUBE-SVC-DZ6LTOHRG6HQWHYE  tcp            --   0.0.0.0/0    10.107.138.203  /*  default/hello-world           cluster  IP          */     tcp   dpt:80
    KUBE-SVC-TCOU7JCQXEZGVUNU  udp            --   0.0.0.0/0    10.96.0.10      /*  kube-system/kube-dns:dns      cluster  IP          */     udp   dpt:53
    KUBE-SVC-ERIFXISQEP7F7OF4  tcp            --   0.0.0.0/0    10.96.0.10      /*  kube-system/kube-dns:dns-tcp  cluster  IP          */     tcp   dpt:53
    KUBE-NODEPORTS             all            --   0.0.0.0/0    0.0.0.0/0       /*  kubernetes                    service  nodeports;  NOTE:  this  must      be  the  last  rule  in  this  chain  */  ADDRTYPE  match  dst-type  LOCAL

    $ sudo iptables -t nat -L KUBE-SVC-DZ6LTOHRG6HQWHYE  -n | column -t
    Chain                      KUBE-SVC-DZ6LTOHRG6HQWHYE  (1   references)
    target                     prot                       opt  source          destination
    KUBE-MARK-MASQ             tcp                        --   !10.244.0.0/16  10.107.138.203  /*  default/hello-world  cluster  IP                 */  tcp        dpt:80
    KUBE-SEP-W2IFVPZJILTBGJON  all                        --   0.0.0.0/0       0.0.0.0/0       /*  default/hello-world  ->       10.244.1.199:8080  */  statistic  mode    random  probability  0.50000000000
    KUBE-SEP-QWI4LEXVO5GRYADO  all                        --   0.0.0.0/0       0.0.0.0/0       /*  default/hello-world  ->       10.244.2.190:8080  */


NodePort
~~~~~~~~~~~

This makes the service accessible on a static port on each Node in the cluster.

LoadBalancer
~~~~~~~~~~~~~

The service becomes accessible externally through a cloud provider's load balancer functionality. GCP, AWS, Azure, and OpenStack offer this functionality.

