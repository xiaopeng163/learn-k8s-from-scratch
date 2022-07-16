etcd backup and restore operations
=====================================


etcd
-------

- key vaule datastore
- stores cluster state data and objects


to protect data:

- backup and restore
- HA


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
