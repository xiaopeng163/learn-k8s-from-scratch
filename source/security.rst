Security
==============

- Kubernetes Security Fundamentals
- Managing Certificates and kubeconfig files
- Managing Role Based Access Controls

Certificates Based Authentication


kubectl config view
kubectl config viewe --raw

Get Certificates

kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 --decode > admin.crt
openssl x509 -in admin.crt --text

kubectl get pod -v 6

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   security/kubeconfig
   security/service_account
   security/RBAC
