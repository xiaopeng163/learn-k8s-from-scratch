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
  apt update -qq >/dev/null 2>&1
  apt install -qq -y containerd apt-transport-https >/dev/null 2>&1
  mkdir /etc/containerd
  containerd config default > /etc/containerd/config.toml
  systemctl restart containerd
  systemctl enable containerd >/dev/null 2>&1

  echo "[TASK 6] Add apt repo for kubernetes"
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
  apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

  echo "[TASK 7] Install Kubernetes components (kubeadm, kubelet and kubectl)"
  apt install -qq -y kubeadm=1.24.0-00 kubelet=1.24.0-00 kubectl=1.24.0-00 >/dev/null 2>&1




lima@lima-k8s-master:~$ kubectl version
WARNING: This version information is deprecated and will be replaced with the output from kubectl version --short.  Use --output=yaml|json to get the full version.
Client Version: version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.4", GitCommit:"872a965c6c6526caa949f0c6ac028ef7aff3fb78", GitTreeState:"clean", BuildDate:"2022-11-09T13:36:36Z", GoVersion:"go1.19.3", Compiler:"gc", Platform:"linux/arm64"}
Kustomize Version: v4.5.7
The connection to the server localhost:8080 was refused - did you specify the right host or port?
lima@lima-k8s-master:~$
lima@lima-k8s-master:~$ kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.4", GitCommit:"872a965c6c6526caa949f0c6ac028ef7aff3fb78", GitTreeState:"clean", BuildDate:"2022-11-09T13:35:06Z", GoVersion:"go1.19.3", Compiler:"gc", Platform:"linux/arm64"}
lima@lima-k8s-master:~$ kubelet --version
Kubernetes v1.25.4

