Security
==============

- Kubernetes Security Fundamentals
- Managing Certificates and kubeconfig files
- Managing Role Based Access Controls

前置知识：

- Difference between Authentication and Authorization:

    - Authentication: 你是谁？
    - Authorization: 你可以干什么？

- 关于PKI，数字签名，证书等知识:

    - https://learn-cryptography.readthedocs.io/zh/latest/digital-signature/

- SSL单向认证和双向认证

All Kubernetes clusters have two categories of users:

- service accounts managed by Kubernete, 程序（pod）连接API Server
- normal users. 普通用户，比如通过kubectl连接API Server


.. toctree::
   :maxdepth: 2
   :caption: Contents:

   security/kubeconfig
   security/RBAC
   security/service_account
