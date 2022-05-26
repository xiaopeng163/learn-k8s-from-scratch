kubeadm
==============

参考文档 https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/


环境准备
~~~~~~~~~

准备三台Linux机器（本文以Ubuntu22.04LTS系统为例），三台机器之间能相互通信。

以下是本文使用的三台Ubuntu 22.04LTS：


.. list-table:: Kubeadm环境主机
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


.. warning::

   请注意上面准备的机器必须能够访问互联网，中国大陆的朋友要确保机器能访问Google

.. warning::

   如果你使用的是云服务提供的虚拟机，请确保把安全策略组配置好，确保三台机器之间可以访问任意端口，https://kubernetes.io/docs/reference/ports-and-protocols/



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
- ``--pod-network-cidr``  pod network 地址空间

.. code-block:: bash

    vagrant@k8s-master:~$ sudo kubeadm init --apiserver-advertise-address=192.168.56.10  --pod-network-cidr=10.244.0.0/16

最后一段的输出要保存好, 这一段指出后续需要做什么配置。

- 1. 准备 .kube
- 2. 部署pod network方案
- 3. 添加worker节点

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

  kubeadm join 192.168.56.10:6443 --token 0pdoeh.wrqchegv3xm3k1ow \
    --discovery-token-ca-cert-hash sha256:f4e693bde148f5c0ff03b66fb24c51f948e295775763e8c5c4e60d24ff57fe82

1. 配置 .kube

.. code-block:: bash

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

检查状态：

.. code-block:: bash

    $ kubectl get nodes
    $ kubectl get pods -A

shell 自动补全

.. code-block:: bash

    $ source <(kubectl completion bash)


2. 部署pod network方案

去https://kubernetes.io/docs/concepts/cluster-administration/addons/ 选择一个network方案， 根据提供的具体链接去部署。


这里我们选择overlay的方案，名字叫 ``flannel`` 部署方法如下：

下载文件 https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml ，并进行如下修改：


确保network是我们配置的 --pod-network-cidr  10.244.0.0/16

.. code-block:: yaml

    net-conf.json: |
      {
        "Network": "10.244.0.0/16",
        "Backend": {
          "Type": "vxlan"
        }
      }

在 kube-flannel的容器args里，确保有iface=enp0s8, 其中enp0s8是我们的--apiserver-advertise-address=192.168.56.10 接口名

.. code-block:: yaml

   - name: kube-flannel
    #image: flannelcni/flannel:v0.18.0 for ppc64le and mips64le (dockerhub limitations may apply)
     image: rancher/mirrored-flannelcni-flannel:v0.18.0
     command:
     - /opt/bin/flanneld
     args:
     - --ip-masq
     - --kube-subnet-mgr
     - --iface=enp0s8


比如我们的机器，这个IP的接口名是 ``enp0s8``

.. code-block:: bash

  vagrant@k8s-master:~$ ip a
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
      inet 127.0.0.1/8 scope host lo
        valid_lft forever preferred_lft forever
      inet6 ::1/128 scope host
        valid_lft forever preferred_lft forever
  2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
      link/ether 02:9a:67:51:1e:b6 brd ff:ff:ff:ff:ff:ff
      inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
        valid_lft 85351sec preferred_lft 85351sec
      inet6 fe80::9a:67ff:fe51:1eb6/64 scope link
        valid_lft forever preferred_lft forever
  3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
      link/ether 08:00:27:59:c5:26 brd ff:ff:ff:ff:ff:ff
      inet 192.168.56.10/24 brd 192.168.56.255 scope global enp0s8
        valid_lft forever preferred_lft forever
      inet6 fe80::a00:27ff:fe59:c526/64 scope link
        valid_lft forever preferred_lft forever

把修改好的文件保存一个新文件，文件名flannel.yaml，上传到master节点，然后运行

<<<<<<< HEAD
.. code-block:: bash

  $ kubectl apply -f flannel.yaml


检查结果， 如果显示下面的结果，pod都是running的状态，说明我们的network方案部署成功。

.. code-block:: bash

  vagrant@k8s-master:~$ kubectl get pods -A
  NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
  kube-system   coredns-6d4b75cb6d-m5vms             1/1     Running   0          3h19m
  kube-system   coredns-6d4b75cb6d-mmdrx             1/1     Running   0          3h19m
  kube-system   etcd-k8s-master                      1/1     Running   0          3h19m
  kube-system   kube-apiserver-k8s-master            1/1     Running   0          3h19m
  kube-system   kube-controller-manager-k8s-master   1/1     Running   0          3h19m
  kube-system   kube-flannel-ds-blhqr                1/1     Running   0          3h18m
  kube-system   kube-proxy-jh4w5                     1/1     Running   0          3h17m
  kube-system   kube-scheduler-k8s-master            1/1     Running   0          3h19m


添加worker节点
~~~~~~~~~~~~~~~~~


添加worker节点非常简单，直接在worker节点上运行join即可，注意--token


.. code-block:: bash

  $ sudo kubeadm join 192.168.56.10:6443 --token 0pdoeh.wrqchegv3xm3k1ow \
    --discovery-token-ca-cert-hash sha256:f4e693bde148f5c0ff03b66fb24c51f948e295775763e8c5c4e60d24ff57fe82


最后在master节点查看node和pod结果。(比如我们有两个worker节点)

.. code-block:: bash

=======
.. code-block:: bash

  $ kubectl apply -f flannel.yaml


检查结果， 如果显示下面的结果，pod都是running的状态，说明我们的network方案部署成功。

.. code-block:: bash

  vagrant@k8s-master:~$ kubectl get pods -A
  NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
  kube-system   coredns-6d4b75cb6d-m5vms             1/1     Running   0          3h19m
  kube-system   coredns-6d4b75cb6d-mmdrx             1/1     Running   0          3h19m
  kube-system   etcd-k8s-master                      1/1     Running   0          3h19m
  kube-system   kube-apiserver-k8s-master            1/1     Running   0          3h19m
  kube-system   kube-controller-manager-k8s-master   1/1     Running   0          3h19m
  kube-system   kube-flannel-ds-blhqr                1/1     Running   0          3h18m
  kube-system   kube-proxy-jh4w5                     1/1     Running   0          3h17m
  kube-system   kube-scheduler-k8s-master            1/1     Running   0          3h19m


添加worker节点
~~~~~~~~~~~~~~~~~


添加worker节点非常简单，直接在worker节点上运行join即可，注意--token


.. code-block:: bash

  $ sudo kubeadm join 192.168.56.10:6443 --token 0pdoeh.wrqchegv3xm3k1ow \
    --discovery-token-ca-cert-hash sha256:f4e693bde148f5c0ff03b66fb24c51f948e295775763e8c5c4e60d24ff57fe82


最后在master节点查看node和pod结果。(比如我们有两个worker节点)

.. code-block:: bash

>>>>>>> 12ed30716031e97569c911a2df233795cd7b1372
  vagrant@k8s-master:~$ kubectl get nodes
  NAME          STATUS   ROLES           AGE     VERSION
  k8s-master    Ready    control-plane   3h26m   v1.24.0
  k8s-worker1   Ready    <none>          3h24m   v1.24.0
  k8s-worker2   Ready    <none>          3h23m   v1.24.0
  vagrant@k8s-master:~$


pod的话，应该可以看到三个flannel，三个proxy的pod


.. code-block:: bash

  vagrant@k8s-master:~$ kubectl get pods -A
  NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
  kube-system   coredns-6d4b75cb6d-m5vms             1/1     Running   0          3h19m
  kube-system   coredns-6d4b75cb6d-mmdrx             1/1     Running   0          3h19m
  kube-system   etcd-k8s-master                      1/1     Running   0          3h19m
  kube-system   kube-apiserver-k8s-master            1/1     Running   0          3h19m
  kube-system   kube-controller-manager-k8s-master   1/1     Running   0          3h19m
  kube-system   kube-flannel-ds-blhqr                1/1     Running   0          3h18m
  kube-system   kube-flannel-ds-lsbg5                1/1     Running   0          3h16m
  kube-system   kube-flannel-ds-s7jtf                1/1     Running   0          3h17m
  kube-system   kube-proxy-jh4w5                     1/1     Running   0          3h17m
  kube-system   kube-proxy-mttvg                     1/1     Running   0          3h19m
  kube-system   kube-proxy-v4qxp                     1/1     Running   0          3h16m
  kube-system   kube-scheduler-k8s-master            1/1     Running   0          3h19m


至此我们的三节点集群搭建完成。
