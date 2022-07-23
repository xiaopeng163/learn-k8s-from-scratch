Kubernetes Installation
===========================

Kubernetes考试版本查看 https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/#

Kubernetes的集群搭建方法有很多种，其中最常见的有：

- Minikube
- kubeadm
- Kubernetes on cloud （AWS，Azure，GCP等）

最简单的是第三种，基本就是在云上点一下鼠标就完成了，其次是minikube，一条命令搞定，稍微麻烦一点的是kubeadm。


个人比较推荐的是 ``kubeadm``, 原因是在CKA的考试中，kubeadm相关的内容是必考内容之一，包括：

- Use Kubeadm to install a basic cluster
- Perform a version upgrade on a Kubernetes cluster using Kubeadm


.. note::

    有些朋友可能听说过 https://labs.play-with-k8s.com/ 这个免费的在线k8s环境，个人并不推荐，速度非常慢，而且经常会因为资源问题卡死。

.. toctree::
    :maxdepth: 2
    :caption: Contents:

    k8s-install/minikube
    k8s-install/kubeadm
    k8s-install/verify
    k8s-install/vagrant
