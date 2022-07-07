Service Discovery
====================

Kubernetes 服务的自动发现。

DNS
------

.. code-block:: bash

    $ kubectl create deployment demo --image=gcr.io/google-samples/hello-app:1.0 --port=8080
    $ kubectl expose deployment demo

这时不仅有一个clusterIP可供整个cluster访问，同时一个DNS域名也被注册了（类似前面讲过的POD）。

我们可以在集群节点上访问以下域名，（当然要指定DNS server是coredns的地址）

.. code-block:: bash

    $ kubectl get svc --namespace kube-system
    NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
    kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   37d
    $ nslookup demo.default.svc.cluster.local 10.96.0.10
    Server:		10.96.0.10
    Address:	10.96.0.10#53

    Name:	demo.default.svc.cluster.local
    Address: 10.105.71.223

也就是 ``<service name>.<namespace>.svc.cluster.local``

如果在创建一个pod，在pod里可以访问到demo这个service以及后面的deployment

.. code-block:: bash

    $ kubectl run client --image=xiaopeng163/net-box --command -- sh -c "sleep 100000"
    $ kubectl exec -it client -- sh
    /omd # nslookup demo.default.svc.cluster.local
    ;; Truncated, retrying in TCP mode.
    Server:		10.96.0.10
    Address:	10.96.0.10#53

    Name:	demo.default.svc.cluster.local
    Address: 10.105.71.223

    /omd # curl demo.default.svc.cluster.local:8080
    Hello, world!
    Version: 1.0.0
    Hostname: demo-557f884dd8-7n55c
    /omd #


ENV
------

另外一些环境变量也会在集群内注册。这时候如果我们创建另外一个POD

.. code-block:: bash

    $ kubectl run client --image=xiaopeng163/net-box --command -- sh -c "sleep 100000"
    $ kubectl exec -it client -- sh
    /omd # env | grep DEMO
    DEMO_SERVICE_HOST=10.105.71.223
    DEMO_PORT_8080_TCP_ADDR=10.105.71.223
    DEMO_PORT_8080_TCP_PORT=8080
    DEMO_PORT_8080_TCP_PROTO=tcp
    DEMO_PORT=tcp://10.105.71.223:8080
    DEMO_SERVICE_PORT=8080
    DEMO_PORT_8080_TCP=tcp://10.105.71.223:8080
