Role Based Access Control
=============================


API Objects
----------------

- Role and ClusterRole
- RoleBinding and ClusterRoleBinding


Roles
----------

Roles 代表的是可以对k8s的resource做什么操作， 并且是分别namespace的

ClusterRoles
----------------

Cluster级别的Resource， Node, PersistentVolumes.  (跨namespace)


RoleBinding
----------------

Role/ClusterRole 定义了可以做什么。

RoleBindingClusterRoleBinding是定义了谁可以做在这个Role/ClusterRole定义


使用场景
----------

Role/RoleBinding 一般用于单个namespace去定义权限

CLusterRole/ClusterRoleBinding 一般用于所有的namespace
