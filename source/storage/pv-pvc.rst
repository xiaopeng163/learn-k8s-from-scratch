Persistent Volumes and Persistent Volumes Claims
====================================================

https://kubernetes.io/docs/concepts/storage/persistent-volumes/


Persistent Volumes
----------------------------

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator
or dynamically provisioned using Storage Classes.


Type of Persistent Volumes

https://kubernetes.io/docs/concepts/storage/persistent-volumes/#types-of-persistent-volumes


Persistent Volumes Claims
----------------------------

A request for storage by a user

- Size
- Access mode (ReadWriteOnce, ReadWriteMany, ReadOnlyMany), access mode is node level access, not pod level
- Storage Class

the cluster will map the Persistent Volumes Claim to a Persistent Volume


Static Provisionling Workflow
--------------------------------

- create a PersistentVolume
- create a PersistentVolumeClaim
- Define Volume in pod spec


Storage Lifecycle
------------------

- Binding (PVC created, match PVC to PV)
- Using (pod lifetime)
- Reclaim (PVC deleted, the pv will be reclaimed based on the recalimd policy: delete or retain)
  
  - delete, 就是一旦pvc删除了，那么实际这块pv也会被清理，里面的数据会被删除，然后这块空间会等待下一次的pvc
  - retain, pvc虽然删除了，但是这块pv里的数据会保留，pv的状态会变为related，这是无法马上被下一次的pvc使用，管理员必须手动清理删除

Define a Persistent Volume
-----------------------------------

.. code-block:: yaml

  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: test-nfs
  spec:
    capacity:
      storage: 1Gi
    accessModes:
      - ReadWriteMany
    nfs:
      server: 192.168.50.20
      path: "/export/volumes/pod"
