Role Based Access Control
=============================


API Objects
----------------

- Role and ClusterRole
- RoleBinding and ClusterRoleBinding


Roles
----------

Roles 代表的是可以对k8s的resource做什么操作， 并且是分别namespace的


.. code-block:: bash

    $ kubectl create role demorole --verb=get,list --resource=pods --namespace ns1

    $ kubectl create role demorole --verb=* --resource=pods --namespace ns1

ClusterRoles
----------------

Cluster级别的Resource， Node, PersistentVolumes.  (跨namespace)

.. code-block:: bash

    $ kubectl create clusterrole democlusterrole --verb=get,list --resource=nodes

RoleBinding/ClusterRoleBinding
-------------------------------------------

Role/ClusterRole 定义了可以做什么。

RoleBindingClusterRoleBinding是定义了谁可以做在这个Role/ClusterRole定义

RoleBinding
~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    $ kubectl create rolebinding demorolebinding --role=demorole --user=demouser --namespace ns1

ClusterRoleBinding
~~~~~~~~~~~~~~~~~~~~~~~~~~~


.. code-block:: bash

    $ kubectl create clusterrolebinding democlusterrolebinding --clusterrole=democlusterrole --user=demouser


使用场景
~~~~~~~~~~~~

Role/RoleBinding 一般用于单个namespace去定义权限

CLusterRole/ClusterRoleBinding 一般用于所有的namespace

Test
------------


.. code-block:: bash

    $ kubectl auth can-i list pods
    $ kubectl auth can-i list pods --as=demouser --namespace ns1

    $ kubectl get pods --namespace ns1 --as=demouser

    $ kubectl delete pod <podname> --namespace ns1 --as=demouser