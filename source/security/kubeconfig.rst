Certificates and kubeconfig files
=====================================


关于PKI，数字签名，证书等知识 https://learn-cryptography.readthedocs.io/zh/latest/digital-signature/


Certificates and PKI
----------------------

kubeadm-based cluster will:

- create self-signed Certificate Authority (in /etc/kubernetes/pki)

  - ca.key private key
  - ca.crt CA Certificate， 会被复制到各个cluster节点上，让Node信任由这个CA签名的证书。(同时也在kubeconfig文件里)

- Generates Certificates for System Components
- kubernetes-admin User created


Create Certificate
-----------------------

Create new Certificate for new user

- Create a private key with openssl
- Create a Certificate signing request with openssl
- Create and submit ``CertificateSigning`` Requst object
- Approve the ``CertificateSigning`` Request
- Retrive the Certificate


.. code-block:: bash

    $ # create a private key
    $ openssl genrsa -out demouser.key 2048

    # generate CSR
    $ # CN(common name) is your username, o(Organization) is the Group
    $ openssl req -new -key demouser.key -out demouser.csr -subj "/CN=demouser"

    # the CertificateSigning Request needs to be base64 encoded
    $ cat demouser.csr | base64 | tr -d "\n"


Create ``CertificateSigning`` Requst object

.. code-block:: yaml

    apiVersion: certificates.k8s.io/v1
    kind: CertificateSigningRequest
    metadata:
        name: demouser
    spec:
        groups:
        - system: authenticated
        request: put the base64 encoded csr here
        signerName: kubernetes.io/kube-apiserver-client
        usages:
        - client auth

Approve ``CertificateSigning`` Requst object

.. code-block:: bash

    $ # approe the CSR
    $ kubectl certificate approve demouser

    # retrieve the certificate from the CSR object, and decode it from base64
    $ kubectl get certificatesigningrequests demouser -o jsonpath='{.status.certificate}' | base64 --decode > demouser.crt

    $ # check certificate
    $ openssl x509 -in demouser.crt -text



kubeconfig files
-----------------------


- Users
- Clusters
- Contexts

``/etc/kubernetes/admin.conf``

update kubeconfig file
----------------------------------

.. code-block::  bash

    $ # add demo user
    $ kubectl config set-credentials demouser --client-key=demouser.key --client-certificate=demouser.crt --embed-certs=true

    $ # check
    $ kubectl config get-users
    NAME
    demouser
    kubernetes-admin

    # create contesxt
    $ kubectl config get-contexts
    CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
    *         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   default
    $ kubectl config set-context demo --user=demouser --cluster=kubernetes
    Context "demo" created.
    $ kubectl config get-contexts
    CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
              demo                          kubernetes   demouser
    *         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   default

    $ # change context
    $ kubectl config use-context demo
    Switched to context "demo".
    $ kubectl config get-contexts
    CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
    *         demo                          kubernetes   demouser
              kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   default
    $ kubectl get nodes
    Error from server (Forbidden): nodes is forbidden: User "demouser" cannot list resource "nodes" in API group "" at the cluster scope


    $ kubectl get nodes -v 6
    I0711 20:58:04.364228   65356 loader.go:372] Config loaded from file:  /home/vagrant/.kube/config
    I0711 20:58:04.383605   65356 round_trippers.go:553] GET https://192.168.56.10:6443/api/v1/nodes?limit=500 403 Forbidden in 14 milliseconds
    I0711 20:58:04.384119   65356 helpers.go:222] server response object: [{
    "kind": "Status",
    "apiVersion": "v1",
    "metadata": {},
    "status": "Failure",
    "message": "nodes is forbidden: User \"demouser\" cannot list resource \"nodes\" in API group \"\" at the cluster scope",
    "reason": "Forbidden",
    "details": {
        "kind": "nodes"
    },
    "code": 403
    }]
    Error from server (Forbidden): nodes is forbidden: User "demouser" cannot list resource "nodes" in API group "" at the cluster scope
