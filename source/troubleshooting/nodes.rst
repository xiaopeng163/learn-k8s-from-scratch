Troubleshooting Nodes
=========================

- Server online
- Network reachability
- systemd
- container runtime
- kubelet
- kube-proxy


kubelet
----------

.. code-block:: bash

    # get status
    systemctl status kubelet.service --no-pager

    # start on system boot
    systemctl enable kubelet.service

    # start kubelet
    systemctl start kubelet.service

    # journallog
    sudo journalctl -u kubelet.service --no-pager

    # systemd service unit cfg
    /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

    # kubelet config
    /var/lib/kubelet/config.yaml

