CKA Exam Tips
===============

关于考试的一些技巧。

考试大纲（必读）
--------------------

https://github.com/cncf/curriculum


考试相关（必读）
------------------------

https://www.cncf.io/certification/cka/

https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad

https://docs.linuxfoundation.org/tc-docs/certification/faq-cka-ckad-cks


kubectl Cheat Sheet
-----------------------

考试的时候可以打开放一边

https://kubernetes.io/docs/reference/kubectl/cheatsheet/


https://collabnix.github.io/kubelabs/

一些工具的使用
---------------

vi/vim编辑器

json处理
------------

``jsonpath`` 或者使用 ``jq``

.. code-block:: bash

   vagrant@k8s-master:~$ kubectl get pods --all-namespaces -o json | jq '.items[].spec.containers[].image'
   "rancher/mirrored-flannelcni-flannel:v0.18.1"
   "rancher/mirrored-flannelcni-flannel:v0.18.1"
   "rancher/mirrored-flannelcni-flannel:v0.18.1"
   "k8s.gcr.io/coredns/coredns:v1.8.6"
   "k8s.gcr.io/coredns/coredns:v1.8.6"
   "k8s.gcr.io/etcd:3.5.3-0"
   "k8s.gcr.io/kube-apiserver:v1.24.3"
   "k8s.gcr.io/kube-controller-manager:v1.24.3"
   "k8s.gcr.io/kube-proxy:v1.24.3"
   "k8s.gcr.io/kube-proxy:v1.24.3"
   "k8s.gcr.io/kube-proxy:v1.24.3"
   "k8s.gcr.io/kube-scheduler:v1.24.3"
   "k8s.gcr.io/metrics-server/metrics-server:v0.6.1"
   vagrant@k8s-master:~$ kubectl get pods --all-namespaces -o jsonpath='{.items[*].spec.containers[*].image}'
   rancher/mirrored-flannelcni-flannel:v0.18.1 rancher/mirrored-flannelcni-flannel:v0.18.1 rancher/mirrored-flannelcni-flannel:v0.18.1 k8s.gcr.io/coredns/coredns:v1.8.6 k8s.gcr.io/coredns/coredns:v1.8.6 k8s.gcr.io/etcd:3.5.3-0 k8s.gcr.io/kube-apiserver:v1.24.3 k8s.gcr.io/kube-controller-manager:v1.24.3 k8s.gcr.io/kube-proxy:v1.24.3 k8s.gcr.io/kube-proxy:v1.24.3 k8s.gcr.io/kube-proxy:v1.24.3 k8s.gcr.io/kube-scheduler:v1.24.3 k8s.gcr.io/metrics-server/metrics-server:v0.6.1vagrant@k8s-master:~$
   vagrant@k8s-master:~$
   vagrant@k8s-master:~$


通过dry-run快速生成yaml
--------------------------


.. code-block:: bash

   vagrant@k8s-master:~$ kubectl run nginx --image=nginx --dry-run=client -oyaml > pod.yaml
   vagrant@k8s-master:~$ more pod.yaml
   apiVersion: v1
   kind: Pod
   metadata:
   creationTimestamp: null
   labels:
      run: nginx
   name: nginx
   spec:
   containers:
   - image: nginx
      name: nginx
      resources: {}
   dnsPolicy: ClusterFirst
   restartPolicy: Always
   status: {}

可以定义变量节省命令输入时间

.. code-block:: bash

   $ export dry="--dry-run=client -o yaml"
   $ kubectl run nginx --image=nginx $dry > pod.yaml


快速强制删除Pod
-----------------


直接就强制删除pod （SIGKILL） 可以节省时间。

.. code-block:: bash

    $ kubectl delete pod <name> --grace-period=0 --force

同样也可以定义变量节省时间
