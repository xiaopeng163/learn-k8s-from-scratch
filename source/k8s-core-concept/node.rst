Node
========

Node的一些基本操作

https://kubernetes.io/docs/concepts/architecture/nodes/

Node列表
--------------

.. code-block:: bash

  $ kubectl get nodes   # 获取node列表
  $ kubectl get nodes -o wide   # 获取node列表及node基本信息（OS，kernel，container runtime等）
  $ kubectl get nodes -o wide --show-labels   # 额外显示node的label信息
  
 
单个Node信息
---------------------
 
.. code-block:: bash
 
  $ kubectl describe nodes node1  # 显示单个节点的详细信息

