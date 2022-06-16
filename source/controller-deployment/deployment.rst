Deployment
============================




Create Deployment
----------------------

Imperatively
~~~~~~~~~~~~~~~

.. code-block:: bash

    $ kubectl create deployment web --image=nginx
    $ kubectl scale deployment web --replicas=5


Declaratively
~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: web
      name: web
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: web
      template:
        metadata:
          labels:
            app: web
        spec:
          containers:
          - image: nginx
            name: nginx


Update Deployment
----------------------


Scale Deployment
----------------------
