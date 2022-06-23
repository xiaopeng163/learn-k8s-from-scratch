Taints and Tolerations
=========================

https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

Taints
--------

Node affinity 使得pod有选择node的能力.

Taints 正好相反-- 它允许Node排斥特定的Pod。也就是用在node上的。

Tolerations
--------------

Tolerations are applied to pods.
Tolerations allow the scheduler to schedule pods with matching taints


Demo
--------

给Node添加一个taint, 一个taint包含一个key和value，以及效果。
比如下面这个意味着没有任何一个pod能够schedule到这个node上，除非这个pod有一个matching toleration.

.. code-block:: bash

    $ kubectl taint nodes k8s-worker1 key1=value1:NoSchedule   # to add
    $ kubectl taint nodes k8s-worker1 key1=value1:NoSchedule-  # to delete


create a deployment with replica=3 (no pod will be scheduled on k8s-worker1)

.. code-block:: bash

    $ kubectl taint nodes k8s-worker1 color=red:NoSchedule
    $ kubectl create deployment web --image=nginx --replicas=3


add Tolerations

.. code-block::  yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: web
      template:
        metadata:
          labels:
            app: web
        spec:
          containers:
          - image: nginx
            name: nginx
          tolerations:
          - key: "color"
            operator: "Equal"
            value: "red"
            effect: "NoSchedule"
