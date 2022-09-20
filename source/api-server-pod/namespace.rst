Namespace
===================


Basic
---------


.. code-block:: bash

  # get all namespaces
  kubectl get namespaces

  # get list of all api resources and if they can/not be namespaced
  kubectl api-resources --namespaced=true | head
  kubectl api-resources --namespaced=false | head

  kubectl describe namespaces

  kubectl get pods --all-namespaces

  # get all resources all
  kubectl get all --all-namespaces

  # create namespace with cli
  kubectl create namespace playground1

  kubectl create namespace Playground1   # will be error

  # create namespace with yaml
  vagrant@k8s-master:~$ kubectl create namespace demo --dry-run=client -o yaml > demo.yaml
  vagrant@k8s-master:~$ more demo.yaml
  apiVersion: v1
  kind: Namespace
  metadata:
    creationTimestamp: null
    name: demo
  spec: {}
  status: {}
  vagrant@k8s-master:~$ kubectl apply -f demo.yaml
  namespace/demo created


  # delete namespaces
  vagrant@k8s-master:~$ kubectl delete namespaces demo
  namespace "demo" deleted


Pod with namespace
---------------------

.. code-block:: bash

  # get all pod in all namespaces
  $ kubectl get pod -A

  # get pod in default namespaces
  $ kubectl get pods

  # get pod in demo namespaces
  $ kubectl get pods --namespace=demo

  # create a pod in demo namespace
  $ kubectl run web --namespace=demo --image=nginx

  # or with yaml file
  $ more web.yml
  apiVersion: v1
  kind: Pod
  metadata:
    name: web
    namespace: demo
  spec:
    containers:
    - image: nginx
      name: web
  $ kubectl apple -f web.yml

Change default namespace
-----------------------------

.. code-block:: bash

  vagrant@k8s-master:~$ kubectl create namespace demo
  namespace/demo created
  vagrant@k8s-master:~$ kubectl run web --namespace demo --image nginx
  pod/web created
  vagrant@k8s-master:~$ kubectl get pods
  No resources found in default namespace.
  vagrant@k8s-master:~$ kubectl get pods --namespace demo
  NAME   READY   STATUS    RESTARTS   AGE
  web    1/1     Running   0          10s


如何切换当前默认的namespace从default到demo

.. code-block:: bash

  vagrant@k8s-master:~$ kubectl config get-contexts
  CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
  *         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

  vagrant@k8s-master:~$ kubectl config set-context --current --namespace demo
  Context "kubernetes-admin@kubernetes" modified.
  vagrant@k8s-master:~$ kubectl config get-contexts
  CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
  *         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   demo
  vagrant@k8s-master:~$ kubectl get pods
  NAME   READY   STATUS    RESTARTS   AGE
  web    1/1     Running   0          2m44s
