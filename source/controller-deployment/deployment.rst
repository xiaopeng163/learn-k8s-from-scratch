Deployment
============================

https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

You describe a ``desired state`` in a Deployment, and the Deployment Controller changes the actual state
to the desired state at a controlled rate. You can define Deployments to create new ``ReplicaSets``,
or to remove existing Deployments and adopt all their resources with new Deployments.


Create Deployment
----------------------

Imperatively
~~~~~~~~~~~~~~~

.. code-block:: bash

    $ kubectl create deployment web --image=nginx:1.14.2
    $ kubectl scale deployment web --replicas=5


Declaratively
~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: web
      name: web
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: web
      template:
        metadata:
          labels:
            app: web
        spec:
          containers:
          - image: nginx:1.14.2
            name: nginx


ReplicaSets and Failures
----------------------------

Pod Failures
~~~~~~~~~~~~~~~~~~

Rescheduled and a new Pod is created


Node Failures
~~~~~~~~~~~~~~~~~~~

- Transient failure
- permanent failure

kube-contorller-manager 有一个timeout的设置

pod-eviction-timeout （默认5min） Node如果失联超过5分钟，就会触发在其上运行的Pod的终止和重建。


Update Deployment
----------------------

Update Strategy
~~~~~~~~~~~~~~~~~~~

https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy

``RollingUpdate`` (Default)

A new ReplicaSet starts scaling up and the old ReplicaSet starts scaling down

创建一个deployment

.. code-block:: bash

  $ kubectl create deployment web --image=nginx:1.14 --replicas 3

Update image

.. code-block:: bash

  $ kubectl set image deployment web nginx=nginx:1.14.2


Rolling Back

查看rollout history

.. code-block:: bash

  $ kubectl rollout history deployment web

查看revision history

.. code-block:: bash

  $ kubectl rollout history deployment web --revision=1

rollout

.. code-block:: bash

  $ kubectl rollout undo deployment web --to-revision=1

``Recreate``

Terminates all pods in the current ReplicaSet, set prior to scaling up the new ReplicaSet

(used when applications  don't support running different versions concurrently)



Restarting a Deployment
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

  $ kubectl rollout restart deployment hello-world


Scale Deployment
----------------------

.. code-block:: bash

  $ kubectl scale deployment web --replicas 5
