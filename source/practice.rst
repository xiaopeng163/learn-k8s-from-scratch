Practice
=============


Auto complete
-----------------

if not, set it by yourself.

search "kubectl cheat sheet"


Deploy pod
--------------

.. code-block:: bash

    kubectl run nginx-pod --image=nginx:alpine --namespace=demo --labels="key=value"

    kubectl run busybox --image=busybox --comand -- sleep 10000


Deploy static pod
--------------------

.. code-block:: bash

    kubectl run busybox --image=busybox --dryrun=client -o yaml --comand -- sleep 10000 > /etc/kubernetes/manifests/

Create a Service for a pod
-----------------------------

.. code-block:: bash

    kubectl expose pod nginx-pod --port 80 --name nginx-svc


for node port type


.. code-block:: bash

    kubectl expose pod nginx-pod --type NodePort --port 80 --name nginx-svc

after deployed, change the node port from kubectl edit



Create a deployment
-------------------------

.. code-block:: bash

    kubectl create deployment nginx-web --image=nginx:alpine --replicas=2



troubeshot pod
-------------------

.. code-block:: bash

    kubectl get pods
    kubectl describe pod xxxx
    kubectl logs pod-name container-name



json path
---------------

get node os images


.. code-block:: bash

    kubectl get node -o jsonpath='[items[*].status.nodeInfo.osImage]'


    kubectl get nodes -o json | jq -c 'paths' | grep InternalIP

Persistent volumes
---------------------

search from k8b documentation




RBAC role binding
---------------------------

1. create CSR


.. code-block:: bash

    apiVersion: certificates.k8s.io/v1
    kind: CertificateSigningRequest
    metadata:
    name: myuser
    spec:
    request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dZVzVuWld4aE1JSUJJakFOQmdrcWhraUc5dzBCQVFFRgpBQU9DQVE4QU1JSUJDZ0tDQVFFQTByczhJTHRHdTYxakx2dHhWTTJSVlRWMDNHWlJTWWw0dWluVWo4RElaWjBOCnR2MUZtRVFSd3VoaUZsOFEzcWl0Qm0wMUFSMkNJVXBGd2ZzSjZ4MXF3ckJzVkhZbGlBNVhwRVpZM3ExcGswSDQKM3Z3aGJlK1o2MVNrVHF5SVBYUUwrTWM5T1Nsbm0xb0R2N0NtSkZNMUlMRVI3QTVGZnZKOEdFRjJ6dHBoaUlFMwpub1dtdHNZb3JuT2wzc2lHQ2ZGZzR4Zmd4eW8ybmlneFNVekl1bXNnVm9PM2ttT0x1RVF6cXpkakJ3TFJXbWlECklmMXBMWnoyalVnald4UkhCM1gyWnVVV1d1T09PZnpXM01LaE8ybHEvZi9DdS8wYk83c0x0MCt3U2ZMSU91TFcKcW90blZtRmxMMytqTy82WDNDKzBERHk5aUtwbXJjVDBnWGZLemE1dHJRSURBUUFCb0FBd0RRWUpLb1pJaHZjTgpBUUVMQlFBRGdnRUJBR05WdmVIOGR4ZzNvK21VeVRkbmFjVmQ1N24zSkExdnZEU1JWREkyQTZ1eXN3ZFp1L1BVCkkwZXpZWFV0RVNnSk1IRmQycVVNMjNuNVJsSXJ3R0xuUXFISUh5VStWWHhsdnZsRnpNOVpEWllSTmU3QlJvYXgKQVlEdUI5STZXT3FYbkFvczFqRmxNUG5NbFpqdU5kSGxpT1BjTU1oNndLaTZzZFhpVStHYTJ2RUVLY01jSVUyRgpvU2djUWdMYTk0aEpacGk3ZnNMdm1OQUxoT045UHdNMGM1dVJVejV4T0dGMUtCbWRSeEgvbUNOS2JKYjFRQm1HCkkwYitEUEdaTktXTU0xMzhIQXdoV0tkNjVoVHdYOWl4V3ZHMkh4TG1WQzg0L1BHT0tWQW9FNkpsYWFHdTlQVmkKdjlOSjVaZlZrcXdCd0hKbzZXdk9xVlA3SVFjZmg3d0drWm89Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
    signerName: kubernetes.io/kube-apiserver-client
    expirationSeconds: 86400  # one day
    usages:
    - client auth

Some points to note:

- usages has to be 'client auth'
- expirationSeconds could be made longer (i.e. 864000 for ten days) or shorter (i.e. 3600 for one hour)
- request is the base64 encoded value of the CSR file content. You can get the content using this command: cat myuser.csr | base64 | tr -d "\n"


.. code-block:: bash

    kubectl get csr

approve CSR


.. code-block:: bash

    kubectl certificate approve xxxxxxx(CRS)

2. Create role

.. code-block:: bash

    kubectl create role developer --verb=create,get,list,update,delete --resource=pods --namespace=xxxx

3. role binding


    kubectl auth can-i get pods --namespace=xxxx --as john


    kubectl create rolebinding --help




pod DNS
----------


get pod ip


xx-xx-xx-xx.default.pod.cluster.local