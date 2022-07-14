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


Role and RoleBinding
~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # 以管理员身份创建一些资源
    $ kubectl config use-context kubernetes-admin@kubernetes
    $ kubectl create namespace ns1
    $ kubectl create deployment web1 --namespace=ns1 --image=gcr.io/google-samples/hello-app:1.0 --port=8080 --replicas=2

    # test
    $ kubectl auth can-i list pod
    yes
    $ kubectl auth can-i list pod --as demouser
    no

    # create role and role binding
    $ kubectl create role demorole --verb=get,list --resource=pods --namespace ns1
    role.rbac.authorization.k8s.io/demorole created
    $ kubectl create rolebinding demorolebinding --role=demorole --user=demouser --namespace ns1
    rolebinding.rbac.authorization.k8s.io/demorolebinding created

    # test
    $ kubectl auth can-i list pod --as demouser
    no
    $ kubectl auth can-i list pod --as demouser --namespace ns1
    yes
    $ kubectl get pods --namespace ns1 --as demouser
    NAME                    READY   STATUS    RESTARTS   AGE
    web1-7f6c665f7d-65h6v   1/1     Running   0          9m38s
    web1-7f6c665f7d-n54t5   1/1     Running   0          9m38s
    $ kubectl auth can-i delete pod --as demouser --namespace ns1
    no
    $ kubectl auth can-i list node --as demouser --namespace ns1
    Warning: resource 'nodes' is not namespace scoped
    no
    $ kubectl auth can-i list deployment --as demouser --namespace ns1
    no


ClusterRole and ClusterRoleBinding
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    $ kubectl create clusterrole democlusterrole --verb=list --resource=node
    clusterrole.rbac.authorization.k8s.io/democlusterrole created
    $ kubectl create clusterrolebinding democlusteerrolebinding --clusterrole=democlusterrole --user=demouser
    clusterrolebinding.rbac.authorization.k8s.io/democlusteerrolebinding created
    $ kubectl auth can-i list node
    Warning: resource 'nodes' is not namespace scoped
    yes
    $ kubectl auth can-i list node --as demouser
    Warning: resource 'nodes' is not namespace scoped
    yes
    $











