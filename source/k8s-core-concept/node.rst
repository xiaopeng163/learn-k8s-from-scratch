Node
========

Node的一些基本操作

https://kubernetes.io/docs/concepts/architecture/nodes/


Node列表
--------------

.. code-block:: bash

  $ kubectl get nodes   # 获取node列表
  $ kubectl get nodes -o wide|yaml   # 获取node列表及node基本信息（OS，kernel，container runtime等）
  $ kubectl get nodes -o wide --show-labels   # 额外显示node的label信息


单个Node信息
---------------------

.. code-block:: bash

  $ kubectl describe nodes node1  # 显示单个节点的详细信息


添加删除label
---------------


kubectl label node <node name>  <label=value>

.. code-block:: bash

  $ kubectl label node master color=red   # 添加 label
  $ kubectl get nodes --show-labels
  $ kubectl label node master color-      # delete color label



update node role, 节点的role是一个特殊的label

.. code-block:: bash

  $ kubectl get nodes
  NAME    STATUS   ROLES                  AGE   VERSION
  node1   Ready    control-plane,master   79m   v1.24
  node2   Ready    <none>                 76m   v1.24
  node3   Ready    <none>                 117m  v1.24
  $ $ kubectl label nodes node2 node-role.kubernetes.io/worker=
  $ kubectl get nodes
  NAME    STATUS   ROLES                  AGE    VERSION
  node1   Ready    control-plane,master   120m   v1.24
  node2   Ready    worker                 117m   v1.24
  node3   Ready    <none>                 117m   v1.24
