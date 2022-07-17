etcd backup and restore operations
=====================================


etcd
-------

- key vaule datastore
- stores cluster state data and objects


to protect data:

- backup and restore
- HA

etcdctl install
-------------------

获取到当前的etcd版本。例如当前实验环境，etcd version是 3.5.3

.. code-block:: bash

    $ kubectl get pods -A | grep etcd
    kube-system     etcd-k8s-master                             1/1     Running     21 (26m ago)   47d
    $ kubectl exec -it --namespace kube-system etcd-k8s-master -- sh
    sh-5.1#
    sh-5.1# etcd --version
    etcd Version: 3.5.3
    Git SHA: 0452feec7
    Go Version: go1.16.15
    Go OS/Arch: linux/amd64
    sh-5.1# exit
    exit
    $

GitHub下载对应版本的etcd

.. code-block:: bash

    export RELEASE=3.5.3
    wget https://github.com/etcd-io/etcd/releases/download/v${RELEASE}/etcd-v${RELEASE}-linux-amd64.tar.gz
    tar -zxvf etcd-v${RELEASE}-linux-amd64.tar.gz
    cd etcd-v${RELEASE}-linux-amd64
    sudo cp etcdctl /usr/local/bin

检查版本

.. code-block:: bash

    $ etcdctl version
    etcdctl version: 3.5.3
    API version: 3.5

ETCD 文档 https://etcd.io/docs/


Backing up etcd
-------------------

etcd数据的备份可以通过``etcdctl``命令行创建快照snashot进行, 备份产生的数据应该尽快复制到集群外一个安全的地方保存。

对于kubeadm搭建的集群， etcd是运行在一个pod里， 数据存储在 ``/var/lib/etcd``, 这个目录通过 ``hostPath`` mount
到了master节点上。


.. code-block::  bash

    $ sudo apt-get install jq
    $ kubectl get  pod --namespace kube-system etcd-k8s-master -o jsonpath='{.spec.containers[0].volumeMounts}' | jq
    [
    {
        "mountPath": "/var/lib/etcd",
        "name": "etcd-data"
    },
    {
        "mountPath": "/etc/kubernetes/pki/etcd",
        "name": "etcd-certs"
    }
    ]
    $ sudo tree /var/lib/etcd/
    /var/lib/etcd/
    └── member
        ├── snap
        │   ├── 0000000000000016-00000000001bc619.snap
        │   ├── 0000000000000016-00000000001bed2a.snap
        │   ├── 0000000000000016-00000000001c143b.snap
        │   ├── 0000000000000016-00000000001c3b4c.snap
        │   ├── 0000000000000016-00000000001c625d.snap
        │   └── db
        └── wal
            ├── 0.tmp
            ├── 000000000000000f-000000000015c31b.wal
            ├── 0000000000000010-0000000000173561.wal
            ├── 0000000000000011-000000000018a661.wal
            ├── 0000000000000012-00000000001a1b93.wal
            └── 0000000000000013-00000000001b8e6c.wal

    3 directories, 12 files


.. code-block:: bash

    $ sudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key \
      snapshot save /var/lib/dat-backup.db

    # 验证
    $ sudo ETCDCTL_API=3 etcdctl --write-out=table \
      snapshot status /var/lib/dat-backup.db


Restoring etcd with etctl
-----------------------------


.. code-block:: bash

    $ sudo ETCDCTL_API=3 etcdctl snapshot restore /var/lib/dat-backup.db

    # 备份一下恢复之前的数据, 以防止恢复失败
    $ mv /var/lib/etcd /var/lib/etcd.OLD

    # 复制恢复数据
    $ sudo mv ./default.etcd /var/lib/etcd

    # 停止etcd容器
    # 找到容器ID
    sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps
    # stop
    sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock stop <container id>

