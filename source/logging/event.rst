Events
==========

Event global
---------------

.. code-block:: bash

    kubectl get events
    kubectl get events --field-selector type=Warning,reason=Failed
    kubectl get events --watch &   ( run `fg` and ctrl +c to break it)

Event per resource
----------------------

Use kubectl describe.

.. code-block:: bash

    kubectl describe pods nginx

