Labels
===============


adding and eidting labels
-----------------------------------

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-pod
      labels:
        app: v1
        tier: PROD
    spec:
    - name: nginx
      image: nginx

edit labels


.. code-block:: bash

    $ kubectl label pod nginx-pod tier=PROD app=v1
    $ kubectl label pod nginx-pod tier=TEST app=v1 --overwrite
    $ kubectl label pod nginx-pod tier-


Querying Using Labels and Selectors
----------------------------------------

.. code-block:: bash

    $ kubectl get pods --show-labels
    $ kubectl get pods --selector tier=PROD
    $ kubectl get pods -l 'tier in (PROD, TEST)'
    $ kubectl get pods -l 'tier notin (PROD, TEST)'


How Kubernetes Uses Labels
----------------------------------


Controllers and Services match pods using Selectors

Pod Scheduling

- select node
-
