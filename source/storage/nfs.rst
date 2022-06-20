NFS Server setup
=========================

以Ubuntu为例

NFS server setup
-----------------------

.. code-block:: bash

    # install NFS server and create directory for our exports

    sudo apt-get install -y nfs-kernel-server
    sudo mkdir /export/volumes
    sudo mkdir /export/volumes/pod

    # config NFS export 

    sudo bash -c 'echo "/export/volumes *(rw,no_root_squash,no_subtree_check)" > /etc/exports'
    cat /etc/exports
    sudo systemctl restart nfs-kernel-server.service


NFS client test
-------------------

install NFS client

.. code-block:: bash

    $ sudo apt-get install -y nfs-common


.. code-block:: bash

    $ sudo mount -t nfs4 username@nfs-server-address:/export/volumes /mnt/
    $ mount | grep nfs
    $ sudo umount /mnt
