Monitoring
===================

- Observe
- Measure Changes
- Resource Limits

Kubernetes Metrics Server
-----------------------------

https://kubernetes-sigs.github.io/metrics-server/

collects resource metris from kubelets for resources like Pods, Nodes.

Metric like CPU, Memory

.. code-block:: bash

    $ kubectl top pods
    $ kubectl top nodes


Deploy Metrics Server
~~~~~~~~~~~~~~~~~~~~~~~~~~~

