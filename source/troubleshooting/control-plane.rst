Troubleshooting Control Plane
=================================

- Server online
- Network reachability
- systemd
- container runtime
- kubelet
- static pod manifest   

static pod config: /var/lib/kubelet/config.yaml  ``staticPodPath``


control plane
-------------------

.. code-block:: bash

    # check kube-system pods
    kubectl get pods --namespaces kube-system

    # user container runtime
    crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps

    # check static pod configuration
    sudo more /var/lib/kubelet/config.yaml

    sudo ls -l /etc/kubernetes/manifests


Workloads
--------------

check resource , describe, get, event, logs.