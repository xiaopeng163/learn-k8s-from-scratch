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


Update Deployment
----------------------


Scale Deployment
----------------------
