Affinity and Anti-Affinity
=============================


nodeAffinity
--------------

Ues labels on Nodes to make a scheduling decision with ``matchExpressions``

https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/

requiredDuringSchedulingIgnoredDuringExecution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: disktype
                operator: In
                values:
                - ssd
      containers:
      - name: nginx
        image: nginx
        imagePullPolicy: IfNotPresent

preferredDuringSchedulingIgnoredDuringExecution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: disktype
                operator: In
                values:
                - ssd
      containers:
      - name: nginx
        image: nginx
        imagePullPolicy: IfNotPresent

podAffinity and podAntiAffinity
------------------------------------

schedule pods onto the same or different node as some other pod

https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
