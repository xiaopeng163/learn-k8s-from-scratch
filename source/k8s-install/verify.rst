kubeadm集群验证
=================

三节点环境搭建完成后，可以通过下面的方式快速验证一下环境是否搭建成功。

.. code-block:: bash

    kubectl get nodes -o wide

.. code-block:: bash

    NAME          STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
    k8s-master    Ready    control-plane   38m   v1.29.2   10.211.55.4   <none>        Ubuntu 22.04.2 LTS   5.15.0-76-generic   containerd://1.6.28
    k8s-worker1   Ready    <none>          21m   v1.29.2   10.211.55.5   <none>        Ubuntu 22.04.2 LTS   5.15.0-97-generic   containerd://1.6.28
    k8s-worker2   Ready    <none>          21m   v1.29.2   10.211.55.6   <none>        Ubuntu 22.04.2 LTS   5.15.0-76-generic   containerd://1.6.28


创建pod
---------

创建一个nginx的pod，pod能成功过running

.. code-block:: bash

    kubectl run web --image nginx

.. code-block:: bash

    pod/web created

.. code-block:: bash

    kubectl get pods -o wide

.. code-block:: bash

    NAME   READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
    web    1/1     Running   0          63s   10.244.1.2   k8s-worker1   <none>           <none>

创建service
-------------

给nginx pod创建一个service, 通过curl能访问这个service的cluster ip地址。

.. code-block:: bash

    kubectl expose pod web  --port=80 --name=web-service

.. code-block:: bash

    service/web-service exposed

.. code-block:: bash

    kubectl get service

.. code-block:: bash

    NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
    kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP   3h53m
    web-service   ClusterIP   10.98.102.238   <none>        80/TCP    4s

.. code-block:: bash

    curl 10.98.102.238
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
    html { color-scheme: light dark; }
    body { width: 35em; margin: 0 auto;
    font-family: Tahoma, Verdana, Arial, sans-serif; }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>

    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>
    vagrant@k8s-master:~$


环境清理
-----------

.. code-block:: bash

    $ kubectl delete service web-service
    $ kubectl delete pod web
