Persistent Volumes
=====================


Type of Persistent Volumes


.. list-table:: Type of Persistent Volumes
   :header-rows: 1

   * - Networked
     - Block
     - Cloud
   * - NFS
     - Fibre Channel
     - aws ElasticBlockStore
   * - azureFile
     - iSCSI
     - azureDisk
   * -
     -
     - gcePersistenDisk


Persistent Volumes Claims

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
- Reclaim (PVC deleted)
