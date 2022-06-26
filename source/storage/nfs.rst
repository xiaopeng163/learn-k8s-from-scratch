NFS Server setup
=========================


.. list-table:: Kubeadm环境主机(+ NFS Server)
   :header-rows: 1

   * - hostname
     - IP
     - system
     - memory
   * - k8s-master
     - 192.168.56.10
     - Ubuntu 20.04 LTS
     - 4GB
   * - k8s-worker1
     - 192.168.56.11
     - Ubuntu 20.04 LTS
     - 2GB
   * - k8s-worker2
     - 192.168.56.12
     - Ubuntu 20.04 LTS
     - 2GB
   * - nfs-server
     - 192.168.56.20
     - Ubuntu 20.04 LTS
     - 2GB


以Ubuntu为例

NFS server setup
-----------------------

.. code-block:: bash

    # install NFS server and create directory for our exports

    sudo apt-get install -y nfs-kernel-server
    sudo mkdir -p /export/volumes
    sudo mkdir -p /export/volumes/pod

    # config NFS export

    sudo bash -c 'echo "/export/volumes *(rw,no_root_squash,no_subtree_check)" > /etc/exports'
    cat /etc/exports
    sudo systemctl restart nfs-kernel-server.service


NFS client test
-------------------

install NFS client

.. warning::

    注意，需要在Kubernetes集群的所有节点上安装NFS Client

.. code-block:: bash

    $ sudo apt-get install -y nfs-common


.. code-block:: bash

    $ sudo mount -t nfs nfs-server-address:/export/volumes /mnt/
    $ mount | grep nfs
    $ sudo umount /mnt
