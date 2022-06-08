API Server and API Object
================================

参考：

- https://kubernetes.io/docs/reference/using-api/
- https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/
- https://kubernetes.io/docs/reference/kubernetes-api/

API Server
--------------

Kubernetes的API Server是一个client/server的架构

- 通过HTTP对外提供RESTful　API服务，client提交请求，server回复
- 是无状态的stateless，所有的状态都存储在cluster　store里（etcd）
  
.. image:: ../_static/introduction/kubernetes_architecture.jpg
   :alt: kubernetes_architecture


Clients
~~~~~~~~~~~

- kubectl
- RESTful API
- other clients


API Object
-------------

API Object是通过API server可以操作的Kubernetes对象，它们代表了整个集群的状态，比如：

- What containerized applications are running (and on which nodes)
- The resources available to those applications
- The policies around how those applications behave, such as restart policies, upgrades, and fault-tolerance

API Object通过以下字段组织起来

- Kind (Pod, Deployment, Service, etc.)
- Group (core, apps, storage), see https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#-strong-api-groups-strong-
- Version (v1, beta, alpha) see https://kubernetes.io/docs/reference/using-api/#api-versioning


如何操作API Object
~~~~~~~~~~~~~~~~~~~~~~

两种模式

- Imperative Configuration (直接通过命令行去创建，操作)
- Declarative Configuration (通过YAML/JSON格式定义Manifest，把期望状态定义在文件中, 然后把文件传给API server)


.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
   name: web
   spec:
      containers:
      - name: nginx-container
         image: nginx:latest


.. code-block:: bash

   $ kubectl apply -f nginx.yml


kubectl dry-run
------------------


Server-side
~~~~~~~~~~~~~~~~

和正常情况一样处理客户端发送过来的请求，但是并不会把Object状态持久化存储到storage中


.. code-block:: bash

   $ kubectl apply -f nginx.yml --dry-run=server

Client-side
~~~~~~~~~~~~~~~~

- 把要操作的Object通过标准输出stdout输出到terminal
- 验证manifest的语法
- 可以用于生成语法正确的Yaml manifest

.. code-block:: bash

   $ kubectl apply -f nginx.yml --dry-run=client
   $ kubectl run web --image=nginx --dry-run=client -o yaml
   $ kubectl run web --image=nginx --dry-run=client -o yaml > nginx.yml


kubectl diff
----------------

显示当前要部署的manifest和集群中运行的有和不同，这样就知道如果apply会发生什么。

.. code-block:: bash

   $ kubectl diff -f new-nginx.yml


kubectl cluster-info


kubectl api-resources | more

kubectl api-resources --api-group=apps | more

kubectl api-versions | sort | more

kubectl explain pods | more

kubectl explain pod.spec | more

kubectl explain pod.spec.containers | more

kubectl get pod hello-world -v 6  (7,8,9)

kubectl proxy & 
then 

curl http://127.0.0.1:8001/api/xxxxxxxx | head -n 20


how to kill the proxy?    fg and ctrl + c


# watch

kubectl get pods --watch -v 6 

kubectl delete pods hello-world

kubectl apply -f pod.yml

kubectl logs <pod name>
 
kubectl logs <pod name> -v 6
