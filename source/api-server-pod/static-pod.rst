Static Pod
=============


参考 https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/


What is Static Pods?
-------------------------

- Managed by the kubelet on Node
- Static Pod manifests,  ``staticPodPath`` in kubelet's configuration, by default is ``/etc/kubernetes/manifests``
- kubelet configuration file:  ``/var/lib/kubelet/config.yaml``
- pod can be 'seen' through API server, but can not be managed by API server


Control plane 的几个static pod

.. code-block:: bash

    vagrant@k8s-master:~$ sudo ls /etc/kubernetes/manifests/
    etcd.yaml  kube-apiserver.yaml	kube-controller-manager.yaml  kube-scheduler.yaml
    vagrant@k8s-master:~$


