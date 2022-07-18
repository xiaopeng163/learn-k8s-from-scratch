JsonPath
============

some examples

.. code-block:: bash

    # get all pod names
    $ kubectl get pods -o jsonpath='{.items[*].metadata.name}'
    
    # get all container image name in use by all pods in all namespaces
    $ kubectl get pods --all-namespaces -o jsonpath='{.items[*].spec.containers[*].image}'
