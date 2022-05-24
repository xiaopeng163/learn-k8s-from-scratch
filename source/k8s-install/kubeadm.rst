kubeadm
==============


环境准备
~~~~~~~~~

准备三台Linux机器（本文以Ubuntu22.04LTS系统为例），三台机器之间能相互通信。

以下是本文使用的三台Ubuntu 22.04LTS：


.. list-table:: Kubeadm环境主机
   :header-rows: 1

   * - hostname
     - IP
     - system
   * - k8s-master
     - 192.168.56.10
     - Ubuntu 22.04 LTS
   * - k8s-worker1
     - 192.168.56.11
     - Ubuntu 22.04 LTS
   * - k8s-worker2
     - 192.168.56.12
     - Ubuntu 22.04 LTS


.. warning::

   请注意上面准备的机器必须能够访问互联网，中国大陆的朋友要确保机器能访问Google

.. warning::

   如果你使用的是云服务提供的虚拟机，请确保把安全策略组配置好，确保三台机器之间可以访问任意端口，



安装containerd, kubeadm, kubelet, kubectl
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


把下面的shell脚本保存成一个文件，比如叫master.sh，放到三台机器里。

然后分别在三台机器上执行sudo sh master.sh 运行脚本。

.. note::

   如果要修改Kubernetes版本，请修改下面脚本的最后一行，当前我们使用的版本是 ``1.24.0``, 可以通过命令 ``apt list -a kubeadm`` 查看可用版本

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


脚本结束以后，可以检查下kubeadm，kubelet，kubectl的安装情况,如果都能获取到版本号，说明安装成功。


.. code-block:: bash

    vagrant@k8s-master:~$ kubeadm version
    kubeadm version: &version.Info{Major:"1", Minor:"24", GitVersion:"v1.24.0", GitCommit:"4ce5a8954017644c5420bae81d72b09b735c21f0", GitTreeState:"clean", BuildDate:"2022-05-03T13:44:24Z", GoVersion:"go1.18.1", Compiler:"gc", Platform:"linux/amd64"}
    vagrant@k8s-master:~$ kubelet --version
    Kubernetes v1.24.0
    vagrant@k8s-master:~$ kubectl version
    WARNING: This version information is deprecated and will be replaced with the output from kubectl version --short.  Use --output=yaml|json to get the full version.
    Client Version: version.Info{Major:"1", Minor:"24", GitVersion:"v1.24.0", GitCommit:"4ce5a8954017644c5420bae81d72b09b735c21f0", GitTreeState:"clean", BuildDate:"2022-05-03T13:46:05Z", GoVersion:"go1.18.1", Compiler:"gc", Platform:"linux/amd64"}
    Kustomize Version: v4.5.4
    The connection to the server localhost:8080 was refused - did you specify the right host or port?
    vagrant@k8s-master:~$



初始化master节点
~~~~~~~~~~~~~~~~~~~~~~

.. warning::

    以下操作都在master节点上进行。

可以先拉取集群所需要的images（可做可不做）

.. code-block:: bash

    vagrant@k8s-master:~$ sudo kubeadm config images pull
    [config/images] Pulled k8s.gcr.io/kube-apiserver:v1.24.0
    [config/images] Pulled k8s.gcr.io/kube-controller-manager:v1.24.0
    [config/images] Pulled k8s.gcr.io/kube-scheduler:v1.24.0
    [config/images] Pulled k8s.gcr.io/kube-proxy:v1.24.0
    [config/images] Pulled k8s.gcr.io/pause:3.7
    [config/images] Pulled k8s.gcr.io/etcd:3.5.3-0
    [config/images] Pulled k8s.gcr.io/coredns/coredns:v1.8.6

初始化Kubeadm

- ``--apiserver-advertise-address``  这个地址是本地用于和其他节点通信的IP地址
- ``--pod-network-cidr``  这个是pod会分配的IP地址池，注意不要和本地其他地址冲突。

.. code-block:: bash

    vagrant@k8s-master:~$ sudo kubeadm init --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=10.1.0.0/16

最后一段的输出要保存好

.. code-block:: bash

    Your Kubernetes control-plane has initialized successfully!

    To start using your cluster, you need to run the following as a regular user:

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    Alternatively, if you are the root user, you can run:

    export KUBECONFIG=/etc/kubernetes/admin.conf

    You should now deploy a pod network to the cluster.
    Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    https://kubernetes.io/docs/concepts/cluster-administration/addons/

    Then you can join any number of worker nodes by running the following on each as root:

    kubeadm join 192.168.56.10:6443 --token plw88t.oixwg6yvfro2vmbu \
            --discovery-token-ca-cert-hash sha256:34632b139fce93d7e4b231a1e4e4efdcc90216ce5d55c255ea43b9236843d1c0

配置 .kube

.. code-block:: bash

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config