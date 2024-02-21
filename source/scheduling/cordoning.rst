Cordoning
=============


Cordoning
-----------

Cordoning 是把一个节点标记为 unschedulabel， 一旦标记后，就不会有新的pod被部署到这个节点上了。
但已经运行在这个节点的pod不受影响。


.. code-block:: bash

    $ kubectl cordon <node_name>

当我们要维护一个节点时，一般会通过cordon标记这个节点。

drain
---------

drain可以gracefully的停止一个节点上的Pod


.. code-block:: bash

    $ kubectl drain <node name> --ignore-daemonsets

uncordon
------------

重新标记一个节点为schedulable
