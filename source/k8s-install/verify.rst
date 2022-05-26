kubeadm集群验证
=================

三节点环境搭建完成后，可以通过下面的方式快速验证一下环境是否搭建成功。

.. code-block:: bash

    vagrant@k8s-master:~$ kubectl get nodes
    NAME          STATUS   ROLES           AGE     VERSION
    k8s-master    Ready    control-plane   3h49m   v1.24.0
    k8s-worker1   Ready    <none>          3h47m   v1.24.0
    k8s-worker2   Ready    <none>          3h46m   v1.24.0
    vagrant@k8s-master:~$


创建pod
---------

创建一个nginx的pod，pod能成功过running

.. code-block:: bash

    vagrant@k8s-master:~$ kubectl run web --image nginx
    pod/web created
    vagrant@k8s-master:~$ kubectl get pods
    NAME   READY   STATUS    RESTARTS   AGE
    web    1/1     Running   0          5s
    vagrant@k8s-master:~$

创建service
-------------

给nginx pod创建一个service, 通过curl能访问这个service的cluster ip地址。

.. code-block:: bash

    vagrant@k8s-master:~$ kubectl expose pod web  --port=80 --name=web-service
    service/web-service exposed
    vagrant@k8s-master:~$ kubectl get service
    NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
    kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP   3h53m
    web-service   ClusterIP   10.98.102.238   <none>        80/TCP    4s
    vagrant@k8s-master:~$ curl 10.98.102.238
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
