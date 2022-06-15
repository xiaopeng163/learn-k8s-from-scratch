Scheduling Pod to Specific Node
====================================


prepare node labels
---------------------------

.. code-block:: bash

    $ kubectl label node k8s-worker1 hardware=gpu


Pod with nodeSelector
--------------------------

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-pod
    spec:
      containers:
      - name: nginx
        image: nginx
      nodeSelector:
        hardware: gpu

