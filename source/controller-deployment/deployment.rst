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


Scale Deployment
----------------------
