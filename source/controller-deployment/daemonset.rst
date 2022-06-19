DaemonSet
==================

https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/

确保所有或者部分Kubernetes集群节点上运行一个pod。当有新节点加入时，pod也会运行在上面。

常见例子：

- kube-proxy 网络相关
- log collectors
- metric servers
- Resource monitoring agent
- storage daemons


语法
---------

.. code-block:: yaml

    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: hello-ds
    spec:
      selector:
        matchLabels:
          app: hello-world
      template:
        metadata:
          labels:
            app: hello-world
        spec:
          containers:
          - name: hello-world
            image: nginx:1.14

可以指定Node，通过 ``nodeSelector``

.. code-block:: yaml

    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: hello-ds
    spec:
      selector:
        matchLabels:
          app: hello-world
      template:
        metadata:
          labels:
            app: hello-world
        spec:
          nodeSelector:
            node: hello-world
          containers:
          - name: hello-world
            image: nginx:1.14


Update Strategy
-----------------------------------

- RollingUpdate
- OnDelete