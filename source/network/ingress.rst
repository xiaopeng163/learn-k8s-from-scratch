Ingress
=========


What is Ingress?
--------------------

参考 https://kubernetes.io/docs/concepts/services-networking/ingress/

.. image:: ../_static/network/ingress-overview.svg
   :alt: ingress-overview

.. image:: ../_static/network/kubernetes-ingress.png
   :alt: ingress-k8s



简单说，就是接收请求，并根据一定的路由规则，把请求转发到相应的Service上去。

两个要求：

- Ingress Resource，就是一系列的路由规则 routing rules
- Ingress Controller, 控制实现这些路由规则。（https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/）

Ingress Controller
---------------------

Nginx Ingress Controller: https://github.com/kubernetes/ingress-nginx/blob/main/docs/deploy/index.md

创建 Nginx ingress Controller

.. code-block:: bash

  $ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.1/deploy/static/provider/cloud/deploy.yaml

Type of Ingress
--------------------------

Exposing a Single Service with Ingress
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a web server deployment and service

.. code-block:: bash

  $ kubectl create deployment demo --image=httpd --port=80
  $ kubectl expose deployment demo

Create ingress resource:

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: demo-localhost
      namespace: default
    spec:
      ingressClassName: nginx
      rules:
      - host: demo.localdev.me
        http:
          paths:
          - backend:
              service:
                name: demo
                port:
                  number: 80
            path: /
            pathType: Prefix

找到demo这个service的cluster IP(10.100.162.241)，以及 ingress-nginx-controller这个service的ClusterIP(10.101.55.153，

.. code-block:: bash

  kubectl get svc -A
  NAMESPACE       NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
  default         demo                                 ClusterIP      10.100.162.241   <none>        80/TCP                       19m
  default         kubernetes                           ClusterIP      10.96.0.1        <none>        443/TCP                      37d
  ingress-nginx   ingress-nginx-controller             LoadBalancer   10.101.55.153    <pending>     80:32765/TCP,443:32009/TCP   16m
  ingress-nginx   ingress-nginx-controller-admission   ClusterIP      10.110.135.56    <none>        443/TCP                      16m
  kube-system     kube-dns                             ClusterIP      10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP       37d

- 直接访问demo的clusterIP是可以的

.. code-block:: bash

  $ curl 10.100.162.241
  <html><body><h1>It works!</h1></body></html>

- 但是直接访问ingress-nginx-controller的ClusterIP是不可以的

.. code-block:: bash

  $ curl 10.101.55.153
  <html>
  <head><title>404 Not Found</title></head>
  <body>
  <center><h1>404 Not Found</h1></center>
  <hr><center>nginx</center>
  </body>
  </html>

需要通过域名访问, 当然前提是要把域名对应的ingress-nginx-controller的ClusterIP放到系统hosts文件里。

.. code-block:: bash

  $ curl demo.localdev.me
  <html><body><h1>It works!</h1></body></html>
  $ more /etc/hosts | grep demo
  10.101.55.153 demo.localdev.me

Exposing Multiple Services with Ingress
------------------------------------------

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: ingress-multiple
    spec:
      ingressClassName: nginx
      rules:
        - host: path.example.com
          http:
            paths:
            - path: /red
              pathType: Prefix
              backend:
                service:
                  name: hello-world-service-red
                  port:
                    number: 4242
            - path: /blue
              pathType: Prefix
              backend:
                service:
                  name: hello-world-service-blue
                  port:
                    number: 4343
      defaultBackend:
        service:
          name: hello-world-service-single
          port:
            number: 80


Name Based Virtual Hosts with Ingress
------------------------------------------

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: ingress-multiple
    spec:
      ingressClassName: nginx
      rules:
        - host: red.example.com
          http:
            paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: hello-world-service-red
                  port:
                    number: 4242
        - host: blue.example.com
          http:
            paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: hello-world-service-blue
                  port:
                    number: 4343

Using TLS certificates for HTTPs Ingress
-------------------------------------------------------

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: ingress-https
    spec:
      ingressClassName: nginx
      tls:
      - hosts:
          - tls.example.com
        secretName: tls-secret
      rules:
      - host: tls.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: hello-world-service-single
                port:
                  number
