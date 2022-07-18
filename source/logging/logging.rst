Logging
===========

Accessing Log Data - Pods and Containers
--------------------------------------------

kubectl logs -> API Server -> kubelet -> container logs

.. code-block:: bash

    $ kubectl logs $POD_NAME
    $ kubectl logs $POD_NAME -c $CONTAINER_NAME
    $ kubectl logs $POD_NAME --all-containers
    $ kubectl logs --selector app=demo 
    $ kubectl logs -f $POD_NAME   # follow latest logs
    $ kubectl logs $POD_NAME --tail 5   # get last 5 entries logs

如果api server不可用，则需要手动去container所在节点查看container Log

.. code-block:: bash

    crictl --runtime-endpoint unix:///run/containerd/containerd.sock logs $CONTAINER_ID

或者

.. code-block:: bash

    tail /var/log/containers/$CONTAINER_NAME_$CONTAINER_ID

Accessing Log Data - Nodes
------------------------------

Node上有两个关键的组件，一个是``kubelet``, 一个是 ``kube-proxy``

.. code-block:: bash

    systemctl status kubelet.service  # check service status

    journalctl -u kubelet.service
    journalctl -u kubelet.service | grep -i ERROR
    journalctl -u kubelet.service --since today --no-pager

Accessing Log Data - Control Plane
---------------------------------------

Run as Pods

.. code-block:: bash

    $ kubectl logs -n kube-system $POD_NAME


Run from systemd

.. code-block:: bash

    systemctl status kubelet.service  # check service status

    journalctl -u kubelet.service