Labels
===============


- Used to organize resources: Pod, Nodes and more
- Label Selectors are used to select/query Objects


adding and eidting labels
-----------------------------------

- imperatively with kubectl
- Declaratively in a Manifest in YAML

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-pod-1
      labels:
        app: v1
        tier: PROD
    spec:
      containers:
      - name: nginx
        image: nginx
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-pod-2
      labels:
        app: v1
        tier: ACC
    spec:
      containers:
      - name: nginx
        image: nginx
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-pod-3
      labels:
        app: v1
        tier: TEST
    spec:
      containers:
      - name: nginx
        image: nginx 

edit labels


.. code-block:: bash

    $ kubectl label pod nginx-pod-1 tier=PROD app=v1
    $ kubectl label pod nginx-pod-2 tier=ACC app=v1
    $ kubectl label pod nginx-pod-3 tier=TEST app=v1

    # update label
    $ kubectl label pod nginx-pod-1 tier=ACC app=v1 --overwrite  # overwrite
    $ kubectl label pod nginx-pod-1 tier-   # delete label


Querying Using Labels and Selectors
----------------------------------------

.. code-block:: bash

    $ kubectl get pods --show-labels
    $ kubectl get pods --selector tier=PROD
    $ kubectl get pods -l 'tier in (PROD, TEST)'
    $ kubectl get pods -l 'tier notin (PROD, TEST)'


How Kubernetes Uses Labels
----------------------------------

- Controllers and Services match pods using Selectors
- Pod Scheduling, scheduling to specific Node
