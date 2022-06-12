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


vagrant@k8s-master:~$ kubectl get pods -v 6
I0612 15:12:37.373428   34615 loader.go:372] Config loaded from file:  /home/vagrant/.kube/config
I0612 15:12:37.400727   34615 round_trippers.go:553] GET https://192.168.56.10:6443/api/v1/namespaces/default/pods?limit=500 200 OK in 14 milliseconds
NAME   READY   STATUS    RESTARTS   AGE
web    2/2     Running   0          3h44m


curl http://127.0.0.1:8001/api/v1/namespaces/default/pods?limit=500




# watch

kubectl get pods --watch -v 6

kubectl delete pods hello-world

kubectl apply -f pod.yml

kubectl logs <pod name>

kubectl logs <pod name> -v 6
