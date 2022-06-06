Service
========

https://kubernetes.io/docs/concepts/services-networking/service/


Pod to Pod Network
----------------------

https://kubernetes.io/docs/concepts/cluster-administration/networking/

- all containers can communicate with all other containers without NAT
- all nodes can communicate with all containers (and vice-versa) without NAT
- the IP that a container sees itself as is the same IP that others see it as


.. code-block:: bash

    vagrant@k8s-master:~$ sudo kubeadm init --apiserver-advertise-address=192.168.56.10  --pod-network-cidr=10.244.0.0/16

Pod初始化的时候，指定了pod network CIDR, pod能分配到的IP地址范围。

.. code-block:: bash

    vagrant@k8s-master:~$ kubectl run test1 --image=busybox --command -- bin/sh -c "sleep 100000"
    pod/test1 created
    vagrant@k8s-master:~$ kubectl run test2 --image=busybox --command -- bin/sh -c "sleep 100000"
    pod/test2 created
    vagrant@k8s-master:~$ kubectl get pods -o wide
    NAME    READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
    test1   1/1     Running   0          14s   10.244.2.18   k8s-worker2   <none>           <none>
    test2   1/1     Running   0          6s    10.244.1.18   k8s-worker1   <none>           <none>
    vagrant@k8s-master:~$

Pod之间可以自由通信。

.. code-block:: bash

    vagrant@k8s-master:~$ kubectl exec pods/test1 -it -- sh
    / # ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
        valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host
        valid_lft forever preferred_lft forever
    3: eth0@if12: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue
        link/ether b6:f2:6c:a0:df:6b brd ff:ff:ff:ff:ff:ff
        inet 10.244.2.18/24 brd 10.244.2.255 scope global eth0
        valid_lft forever preferred_lft forever
        inet6 fe80::b4f2:6cff:fea0:df6b/64 scope link
        valid_lft forever preferred_lft forever
    / # ping 10.244.1.18
    PING 10.244.1.18 (10.244.1.18): 56 data bytes
    64 bytes from 10.244.1.18: seq=0 ttl=62 time=1.287 ms
    64 bytes from 10.244.1.18: seq=1 ttl=62 time=0.687 ms
    64 bytes from 10.244.1.18: seq=2 ttl=62 time=0.487 ms
    ^C
    --- 10.244.1.18 ping statistics ---
    3 packets transmitted, 3 packets received, 0% packet loss
    round-trip min/avg/max = 0.487/0.820/1.287 ms
