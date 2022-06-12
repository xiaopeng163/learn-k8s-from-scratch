kubectl proxy
==================


一种直接访问kubernetes API的方法。

首先通过kubectl获取到API的URL， 例如

.. code-block:: bash

    vagrant@k8s-master:~$ kubectl get namespaces  -v 6
    I0612 21:17:08.143200   65940 loader.go:372] Config loaded from file:  /home/vagrant/.kube/config
    I0612 21:17:08.174927   65940 round_trippers.go:553] GET https://192.168.56.10:6443/api/v1/namespaces?limit=500 200 OK in 18 milliseconds
    NAME              STATUS   AGE
    default           Active   12d
    kube-node-lease   Active   12d
    kube-public       Active   12d
    kube-system       Active   12d


后台执行 ``kubectl proxy &``

.. code-block:: bash

    vagrant@k8s-master:~$ kubectl proxy &
    [1] 66087
    vagrant@k8s-master:~$ Starting to serve on 127.0.0.1:8001

    vagrant@k8s-master:~$

这时候就可以通过proxy来访问API了，例如


.. code-block:: bash

    vagrant@k8s-master:~$ curl http://127.0.0.1:8001/api/v1/namespaces?limit=500
    {
    "kind": "NamespaceList",
    "apiVersion": "v1",
    "metadata": {
        "resourceVersion": "352131"
    },
    "items": [
        {
        "metadata": {
            "name": "default",
            "uid": "9c661b71-38ad-4cdc-b505-0889e88bdb4b",
            "resourceVersion": "197",
            "creationTimestamp": "2022-05-31T18:13:08Z",
            "labels": {
            "kubernetes.io/metadata.name": "default"
            },


如何退出proxy？ 运行fg，然后运行ctrl + c

.. code-block:: bash

    vagrant@k8s-master:~$ fg
    kubectl proxy

    ^C
    vagrant@k8s-master:~$

