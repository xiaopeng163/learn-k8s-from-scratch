Manual Scheduling
===================

所谓manual Scheduling人工调度，就是直接指定pod运行的Node。


比如下面指定pod运行在 k8s-worker1 节点上。

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: web
   spec:
      nodeName: 'k8s-worker1'
      containers:
       - name: nginx-container
         image: nginx:latest


两个问题：

- 1. taint的node是否可以接受这种pod？  答案是yes
- 2. cordon的node是否可以接受这种pod？ 答案是yes


