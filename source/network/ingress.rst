Ingress
=========


Ingress Architecture
--------------------------

- Ingress Resource
- Ingress Controller (HTTP reverse proxy)
- Ingress Class


name-based virtual hosts

path-based routing


Exposing a Single Service with Ingress
------------------------------------------


.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: ingress-single
    spec:
      ingressClassName: nginx
      defaultBackend:
        service:
          name: hello-world-service-single
          port:
            number: 80  

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