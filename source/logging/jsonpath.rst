JsonPath
============

some examples

.. code-block:: bash

    # get all pod names
    $ kubectl get pods -o jsonpath='{.items[*].metadata.name}'
    
    # get all container image name in use by all pods in all namespaces
    $ kubectl get pods --all-namespaces -o jsonpath='{.items[*].spec.containers[*].image}'
 
    # add a new line to the result
    $ kubectl get pods --all-namespaces -o jsonpath='{.items[*].spec.containers[*].image}{"\n"}'

    # ?() define filter
    # @ - the current object
    $ kubectl get nodes -o jsonpath="{.items[*].status.addresses[?(@.type=='InternalIP')].address}"

    # sorting
    $ kubectl get pods -A -o jsonpath='{.items[*].metadata.name}{"\n"}' --sort-by=.metadata.name

