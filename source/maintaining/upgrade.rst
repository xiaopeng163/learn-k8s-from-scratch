Upgrading an existing Cluster
==============================

upgrade kubeadm-based Cluster
----------------------------------

- 只能小版本更新

    - 1.21 -> 1.22 |:white_check_mark:|
    - 1.21 -> 1.23 |:x:|

- 一定要阅读changelog https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG

检查当前版本：

- kubectl version --short
- kubectl get nodes
- kubeadm version

Upgrade Control Plane
--------------------------

- update kubeadm package
- Drain the control plane/master node
- kubeadm upgrade plan
- kubeadm upgrade apply
- Uncordon the control plan/master node
- update kubelet and kubectl

以Ubuntu为例

.. code-block:: bash

    # update kubeadm
    sudo apt-mark unhold kubeadm
    sudo apt-get update
    sudo apt-cache policy kubeadm
    sudo apt-get install -y kubeadm=$TARGET_VERSION
    sudo apt-mark hold kubeadm

    # drain master node
    kubectl drain k8s-master --ignore-daemonsets

    sudo kubeadm upgrade plan
    sudo kubeadm upgrade apply v$TARGET_VERSION

    # uncordon
    kubectl uncordon k8s-master

    # update kubelet and kubectl
    sudo apt-mark unhold kubelet kubectl
    sudo apt-get update
    sudo apt-get install -y kubelet=$TARGET_VERSION kubectl=$TARGET_VERSION
    sudo apt-mark hold kubelet kubectl



Upgrade work node
--------------------------

以Ubuntu为例

.. code-block:: bash

    # go to master node
    kubectl drain k8s-worker1 --ingore-daemonsets

    # update kubeadm
    sudo apt-mark unhold kubeadm
    sudo apt-get update
    sudo apt-get install -y kubeadm=$TARGET_VERSION
    sudo apt-mark hold kubeadm

    sudo kubeadm upgrade node

    # update kubelet and kubectl
    sudo apt-mark unhold kubelet
    sudo apt-get update
    sudo apt-get install -y kubelet=$TARGET_VERSION
    sudo apt-mark hold kubelet

    # go to master node, uncordon this node
    kubectl uncordon k8s-worker1


Worker Node Maintenance
----------------------------

os update and hardware upgrade

Drain/Cordon the Node.