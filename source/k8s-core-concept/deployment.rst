Deployment
============

本节参考官方即可，以下内容均摘抄于https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

A Deployment provides declarative updates for Pods and ReplicaSets.

You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments.

.. image:: ../_static/k8s-core-concept/deployment.svg
   :width: 400
   :alt: wechat


Creating a Deployment
---------------------------

The following is an example of a Deployment. It creates a ReplicaSet to bring up three nginx Pods:


.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: nginx-deployment
    labels:
        app: nginx
    spec:
    replicas: 3
    selector:
        matchLabels:
        app: nginx
    template:
        metadata:
        labels:
            app: nginx
        spec:
        containers:
        - name: nginx
            image: nginx:1.14.2
            ports:
            - containerPort: 80

