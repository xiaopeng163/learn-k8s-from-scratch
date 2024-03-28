Cluster Cert Renew
====================


k8s集群内部通信证书的有效期为1年，到期后需要更新证书。如果你遇到了以下问题，那么你可能需要更新证书：


x509: certificate has expired or is not yet valid


本文档将指导您如何更新k8s集群内部通信证书。


查看证书有效期
------------------

.. code-block:: bash

  $ sudo kubeadm certs check-expiration
  [check-expiration] Reading configuration from the cluster...
  [check-expiration] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'

  CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
  admin.conf                 Mar 04, 2025 15:35 UTC   341d            ca                      no
  apiserver                  Mar 04, 2025 15:35 UTC   341d            ca                      no
  apiserver-etcd-client      Mar 04, 2025 15:35 UTC   341d            etcd-ca                 no
  apiserver-kubelet-client   Mar 04, 2025 15:35 UTC   341d            ca                      no
  controller-manager.conf    Mar 04, 2025 15:35 UTC   341d            ca                      no
  etcd-healthcheck-client    Mar 04, 2025 15:35 UTC   341d            etcd-ca                 no
  etcd-peer                  Mar 04, 2025 15:35 UTC   341d            etcd-ca                 no
  etcd-server                Mar 04, 2025 15:35 UTC   341d            etcd-ca                 no
  front-proxy-client         Mar 04, 2025 15:35 UTC   341d            front-proxy-ca          no
  scheduler.conf             Mar 04, 2025 15:35 UTC   341d            ca                      no
  super-admin.conf           Mar 04, 2025 15:35 UTC   341d            ca                      no

  CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
  ca                      Mar 02, 2034 15:35 UTC   9y              no
  etcd-ca                 Mar 02, 2034 15:35 UTC   9y              no
  front-proxy-ca          Mar 02, 2034 15:35 UTC   9y              no


更新证书
-----------

更新之前最好备份一下现有证书，以及etcd snapshot，以防万一。

把这个目录的文件全部备份一下 `/etc/kubernetes/pki/`

.. code-block:: bash

  $ sudo kubeadm certs renew all
  [renew] Reading configuration from the cluster...
  [renew] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'

  certificate embedded in the kubeconfig file for the admin to use and for kubeadm itself renewed
  certificate for serving the Kubernetes API renewed
  certificate the apiserver uses to access etcd renewed
  certificate for the API server to connect to kubelet renewed
  certificate embedded in the kubeconfig file for the controller manager to use renewed
  certificate for liveness probes to healthcheck etcd renewed
  certificate for etcd nodes to communicate with each other renewed
  certificate for serving etcd renewed
  certificate for the front proxy client renewed
  certificate embedded in the kubeconfig file for the scheduler manager to use renewed
  certificate embedded in the kubeconfig file for the super-admin renewed

  Done renewing certificates. You must restart the kube-apiserver, kube-controller-manager, kube-scheduler and etcd, so that they can use the new certificates.

执行完之后，需要重启kube-apiserver, kube-controller-manager, kube-scheduler和etcd。

暴力方法就是直接重启集群的所有节点。比较温和的方法是按照我们前面讲的集群upgrade的方法，依次重启集群的所有节点，重启节点之前需进行节点的 `drain` 操作。