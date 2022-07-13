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
    - 一起学加密 Youtube视频 https://www.youtube.com/playlist?list=PLfQqWeOCIH4AZt3TiSRP4UuL_Y3gxYPAW
    - 一起学加密 B站视频 https://www.bilibili.com/video/BV1WF411x7mN?spm_id_from=333.999.section.playall

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
