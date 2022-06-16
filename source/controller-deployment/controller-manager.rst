Controller Manager
====================

https://kubernetes.io/docs/concepts/architecture/controller/


- kube controller Manager
- cloud controller Manager


.. image:: ../_static/controller-manager-on-master.png
   :alt: controller-manager


Controllers
--------------

Pod Controllers

- ReplicaSet
- Deployment
- DaemonSet
- StatefulSet
- Job
- CronJob


Other Controllers

- Node
- Service
- Endpoint


System Pods
------------------


.. code-block:: bash

   $ kubectl get all -A

   $ kubectl get deployment coredns --namespace kube-system

   $ kubectl get daemonset --namespace kube-system

