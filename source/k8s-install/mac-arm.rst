Mac ARM
============


推荐大家使用lima来创建管理虚拟机，参考视频如下

https://www.youtube.com/watch?v=aV4l85XHFGA



创建三台VM
------------

.. code-block:: sh

  limactl start --name=k8s-master  template://ubuntu
  limactl start --name=k8s-worker1  template://ubuntu
  limactl start --name=k8s-worker2  template://ubuntu

查看VM
----------

.. code-block:: sh

  limactl list

.. code-block:: sh

  NAME              STATUS     SSH                ARCH       CPUS    MEMORY    DISK      DIR
  k8s-master        Running    127.0.0.1:64931    aarch64    4       4GiB      100GiB    /Users/XS69ND/.lima/k8s-master
  k8s-worker1       Running    127.0.0.1:64945    aarch64    4       4GiB      100GiB    /Users/XS69ND/.lima/k8s-worker1
  k8s-worker2       Running    127.0.0.1:64965    aarch64    4       4GiB      100GiB    /Users/XS69ND/.lima/k8s-worker2

k8s-master install software
----------------------------------


.. code-block:: bash

    #!/bin/bash

    echo "[TASK 1] Disable and turn off SWAP"
    sed -i '/swap/d' /etc/fstab
    swapoff -a

    echo "[TASK 2] Stop and Disable firewall"
    systemctl disable --now ufw >/dev/null 2>&1

    echo "[TASK 3] Enable and Load Kernel modules"
    cat >>/etc/modules-load.d/containerd.conf<<EOF
    overlay
    br_netfilter
    EOF
    modprobe overlay
    modprobe br_netfilter

    echo "[TASK 4] Add Kernel settings"
    cat >>/etc/sysctl.d/kubernetes.conf<<EOF
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables  = 1
    net.ipv4.ip_forward                 = 1
    EOF
    sysctl --system >/dev/null 2>&1

    echo "[TASK 5] Install containerd runtime"
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt -qq update >/dev/null 2>&1
    apt install -qq -y containerd.io >/dev/null 2>&1
    containerd config default >/etc/containerd/config.toml
    systemctl restart containerd
    systemctl enable containerd >/dev/null 2>&1

    echo "[TASK 6] Add apt repo for kubernetes"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
    apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

    echo "[TASK 7] Install Kubernetes components (kubeadm, kubelet and kubectl)"
    apt install -qq -y kubeadm=1.28.0-00 kubelet=1.28.0-00 kubectl=1.28.0-00 >/dev/null 2>&1


