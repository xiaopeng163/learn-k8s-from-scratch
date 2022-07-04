Cluster DNS
=============

https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/

DNS is available as a Service in a Cluster, Pods are configured to use this DNS.


Cluster DNS configuration
-------------------------------


- 1 deployment (1 replicaset) with 2 pods running on master node.

- 1 kube-dns service

.. code-block:: bash

    vagrant@k8s-master:~$ kubectl get all -A -o wide | grep dns
    kube-system   pod/coredns-6d4b75cb6d-26qqw             1/1     Running   15 (4d23h ago)   34d     10.244.0.36     k8s-master    <none>           <none>
    kube-system   pod/coredns-6d4b75cb6d-lhkng             1/1     Running   15 (4d23h ago)   34d     10.244.0.37     k8s-master    <none>           <none>
    kube-system   service/kube-dns     ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   34d   k8s-app=kube-dns
    kube-system   deployment.apps/coredns   2/2     2            2           34d   coredns      k8s.gcr.io/coredns/coredns:v1.8.6   k8s-app=kube-dns
    kube-system   replicaset.apps/coredns-6d4b75cb6d   2         2         2       34d   coredns      k8s.gcr.io/coredns/coredns:v1.8.6   k8s-app=kube-dns,pod-template-hash=6d4b75cb6d
    vagrant@k8s-master:~$


.. code-block:: bash

    $ kubectl describe configmaps coredns --namespace kube-system
    Name:         coredns
    Namespace:    kube-system
    Labels:       <none>
    Annotations:  <none>

    Data
    ====
    Corefile:
    ----
    .:53 {
        errors
        health {
        lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
        pods insecure
        fallthrough in-addr.arpa ip6.arpa
        ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
        max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }


    BinaryData
    ====

    Events:  <none>


Pod DNS settings
---------------------


.. code-block:: bash

    $ kubectl run client --image=xiaopeng163/net-box --command -- sh -c "sleep 100000"
    $ kubectl exec -it client -- cat /etc/resolv.conf
    search default.svc.cluster.local svc.cluster.local cluster.local kpn
    nameserver 10.96.0.10
    options ndots:5


Pod A/AAAA records

In general a Pod has the following DNS resolution:

``pod-ip-address.my-namespace.pod.cluster-domain.example``


.. code-block:: bash

    $ nslookup 10-244-1-194.default.pod.cluster.local 10.96.0.10
    Server:		10.96.0.10
    Address:	10.96.0.10#53

    Name:	10-244-1-194.default.pod.cluster.local
    Address: 10.244.1.194
