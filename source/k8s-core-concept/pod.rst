Pod
======

https://kubernetes.io/docs/concepts/workloads/pods/

What is Pod?
----------------

Pod是k8s里最小的调度单位。

- A group of one or more application containers and their shared resources like volume.
- A pod share the same name spaces like network name spaces (have same IP address.)
- Pod is the smallest unit for K8s scheduling


.. note::

   关于容器，name spaces，欢迎参考另一篇关于Docker的文档 https://dockertips.readthedocs.io/en/latest/single-host-network.html

.. image:: ../_static/k8s-core-concept/pod.png
   :width: 800
   :alt: what is pod


How to create a pod?
-------------------------



1. from ``kubectl run`` command

Create a pod named web with image of nginx:latest

.. code-block:: bash

   $ kubectl run web --image=nginx


2. from yaml file

以下yaml文件是定义一个pod所需的最少字段 (nginx.yml)

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

   $ kubectl create -f nginx.yml
   pod/web created