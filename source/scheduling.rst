Scheduling
==============

Scheduling 就是找到一个合适的node去运行pod的过程，这个寻找主要是通过 ``kube-scheduler`` 实现的.

以创建Pod为例

- 通过api server获取node信息
- node选择：
  - 过滤 （各种filter过滤，硬件的限制）
  - Scoring （过滤出的节点，进一步评分筛选）
  - Bind (选择出一个节点，最后和API object绑定)
- 更新pod的信息，包括在哪个node上
- 被选节点的kubelet通过监控api-server得知自己被选择创建一个pod
- kubelet驱动container runtime创建container并启动

https://www.alibabacloud.com/blog/getting-started-with-kubernetes-%7C-scheduling-process-and-scheduler-algorithms_596299


.. toctree::
   :maxdepth: 2
   :caption: Contents:

   scheduling/node-selector
   scheduling/affinity
   scheduling/taints
   scheduling/cordoning
