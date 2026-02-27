StorageClass
==============

StorageClass provides a way to describe different "classes" of storage in Kubernetes. It enables dynamic provisioning of Persistent Volumes (PVs), eliminating the need to manually create PVs.

什么是StorageClass
--------------------

**Key Concepts:**

- **Dynamic Provisioning**: Automatically creates PVs when PVCs are requested
- **Storage Abstraction**: Defines different types of storage (fast, slow, replicated, etc.)
- **Provisioner**: Backend storage provider (AWS EBS, GCE PD, NFS, etc.)
- **Parameters**: Storage-specific configuration (type, IOPS, replication, etc.)
- **Reclaim Policy**: What happens to PV when PVC is deleted

**Without StorageClass (Manual):**

1. Admin creates PV manually
2. User creates PVC
3. Kubernetes binds PVC to existing PV
4. If no PV available, PVC stays pending

**With StorageClass (Dynamic):**

1. Admin creates StorageClass once
2. User creates PVC referencing StorageClass
3. StorageClass automatically provisions PV
4. PVC binds to newly created PV


StorageClass组成
------------------

.. code-block:: yaml

    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: fast-ssd
    provisioner: kubernetes.io/aws-ebs  # Storage backend
    parameters:  # Provisioner-specific parameters
      type: gp3
      iops: "3000"
      encrypted: "true"
    reclaimPolicy: Delete  # or Retain
    allowVolumeExpansion: true
    volumeBindingMode: WaitForFirstConsumer  # or Immediate
    mountOptions:
      - debug

**字段说明:**

- ``provisioner``: 存储提供者，决定使用哪个插件创建PV
- ``parameters``: 传递给provisioner的参数（因provisioner而异）
- ``reclaimPolicy``: PV回收策略（Delete或Retain），默认Delete
- ``allowVolumeExpansion``: 是否允许PVC扩容
- ``volumeBindingMode``: 何时创建和绑定PV
  
  - ``Immediate``: 创建PVC时立即创建PV（默认）
  - ``WaitForFirstConsumer``: 等待Pod调度后再创建PV（推荐）

- ``mountOptions``: 挂载选项


常见Provisioners
------------------

**Cloud Providers:**

- **kubernetes.io/aws-ebs**: Amazon EBS volumes
- **kubernetes.io/gce-pd**: Google Compute Engine Persistent Disks
- **kubernetes.io/azure-disk**: Azure Disk Storage
- **kubernetes.io/azure-file**: Azure File Storage
- **kubernetes.io/cinder**: OpenStack Cinder

**In-tree Provisioners:**

- **kubernetes.io/no-provisioner**: No dynamic provisioning, manual PV only
- **kubernetes.io/host-path**: HostPath (single node testing only)

**External Provisioners (CSI):**

- csi.storage.k8s.io (Container Storage Interface drivers)
- rook.io/ceph-block
- nfs.csi.k8s.io
- many more...


创建StorageClass
------------------

**Example 1: AWS EBS StorageClass**

.. code-block:: yaml

    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: aws-ebs-gp3
    provisioner: ebs.csi.aws.com
    parameters:
      type: gp3
      iops: "3000"
      throughput: "125"
      encrypted: "true"
    volumeBindingMode: WaitForFirstConsumer
    allowVolumeExpansion: true
    reclaimPolicy: Delete

.. code-block:: bash

    $ kubectl apply -f aws-ebs-storageclass.yaml
    storageclass.storage.k8s.io/aws-ebs-gp3 created

**Example 2: GCE Persistent Disk**

.. code-block:: yaml

    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: gce-pd-ssd
    provisioner: pd.csi.storage.gke.io
    parameters:
      type: pd-ssd
      replication-type: regional-pd
    volumeBindingMode: WaitForFirstConsumer
    allowVolumeExpansion: true

**Example 3: NFS Dynamic Provisioning**

使用NFS Subdir External Provisioner:

.. code-block:: yaml

    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: nfs-client
    provisioner: nfs.csi.k8s.io
    parameters:
      server: nfs-server.default.svc.cluster.local
      share: /exported/path
    reclaimPolicy: Retain
    volumeBindingMode: Immediate


使用StorageClass
------------------

**Method 1: Specify in PVC**

.. code-block:: yaml

    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: my-pvc
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: aws-ebs-gp3  # Reference StorageClass
      resources:
        requests:
          storage: 10Gi

.. code-block:: bash

    $ kubectl apply -f pvc.yaml
    persistentvolumeclaim/my-pvc created

    # Watch PV being created automatically
    $ kubectl get pvc
    NAME     STATUS   VOLUME                                     CAPACITY   STORAGECLASS
    my-pvc   Bound    pvc-12345678-1234-1234-1234-123456789abc   10Gi       aws-ebs-gp3

    $ kubectl get pv
    NAME                                       CAPACITY   RECLAIM POLICY   STATUS
    pvc-12345678-1234-1234-1234-123456789abc   10Gi       Delete           Bound

**Method 2: Default StorageClass**

Set a default StorageClass:

.. code-block:: bash

    # Mark StorageClass as default
    $ kubectl patch storageclass aws-ebs-gp3 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

Now PVCs without ``storageClassName`` will use the default:

.. code-block:: yaml

    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: auto-pvc
    spec:
      accessModes:
        - ReadWriteOnce
      # No storageClassName specified - uses default
      resources:
        requests:
          storage: 5Gi

.. code-block:: bash

    # Check which StorageClass is default
    $ kubectl get storageclass
    NAME               PROVISIONER       RECLAIMPOLICY   VOLUMEBINDINGMODE      DEFAULT
    aws-ebs-gp3        ebs.csi.aws.com   Delete          WaitForFirstConsumer   true
    standard           kubernetes.io/gce-pd   Delete     Immediate              false


volumeBindingMode详解
------------------------

**Immediate (立即绑定)**

PV在PVC创建时立即创建:

.. code-block:: yaml

    volumeBindingMode: Immediate

.. code-block:: bash

    # Create PVC
    $ kubectl apply -f pvc.yaml
    
    # PV is created immediately
    $ kubectl get pv
    NAME       CAPACITY   STATUS   CLAIM         STORAGECLASS
    pvc-xxx    10Gi       Bound    default/pvc   fast

**问题:** 如果Pod不能调度到PV所在的区域，会导致失败。

**WaitForFirstConsumer (延迟绑定)**

等待第一个使用该PVC的Pod调度后再创建PV:

.. code-block:: yaml

    volumeBindingMode: WaitForFirstConsumer

.. code-block:: bash

    # Create PVC
    $ kubectl apply -f pvc.yaml
    
    # PVC stays in Pending (waiting for consumer)
    $ kubectl get pvc
    NAME     STATUS    VOLUME   CAPACITY
    my-pvc   Pending   

    # Create Pod using the PVC
    $ kubectl apply -f pod.yaml
    
    # Now PV is created in the same zone as the Pod
    $ kubectl get pvc
    NAME     STATUS   VOLUME      CAPACITY
    my-pvc   Bound    pvc-xxx     10Gi

**优势:** 确保PV在Pod可以访问的位置创建（考虑了topology约束）。


回收策略 (Reclaim Policy)
----------------------------

**Delete (默认)**

当PVC被删除时，PV和底层存储都被删除:

.. code-block:: yaml

    reclaimPolicy: Delete

.. code-block:: bash

    # Delete PVC
    $ kubectl delete pvc my-pvc
    
    # PV is also deleted automatically
    $ kubectl get pv  # PV is gone
    
    # Underlying storage (e.g., EBS volume) is also deleted

**Retain**

当PVC被删除时，PV保留但状态变为Released:

.. code-block:: yaml

    reclaimPolicy: Retain

.. code-block:: bash

    # Delete PVC
    $ kubectl delete pvc my-pvc
    
    # PV still exists but is Released
    $ kubectl get pv
    NAME       CAPACITY   STATUS      CLAIM
    pvc-xxx    10Gi       Released    default/my-pvc
    
    # Data is preserved, can be manually recovered

**使用场景:**

- ``Delete``: 开发/测试环境，不需要保留数据
- ``Retain``: 生产环境，重要数据需要备份或恢复


Volume扩容
------------

启用扩容:

.. code-block:: yaml

    allowVolumeExpansion: true

扩展PVC:

.. code-block:: bash

    # Original PVC
    $ kubectl get pvc my-pvc
    NAME     STATUS   VOLUME      CAPACITY
    my-pvc   Bound    pvc-xxx     10Gi

    # Edit PVC to increase size
    $ kubectl edit pvc my-pvc
    # Change storage: 10Gi to storage: 20Gi

    # Or use patch
    $ kubectl patch pvc my-pvc -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'

    # Wait for expansion to complete
    $ kubectl get pvc my-pvc
    NAME     STATUS   VOLUME      CAPACITY
    my-pvc   Bound    pvc-xxx     20Gi

**重要限制:**

- 只能扩容，不能缩容
- 某些卷类型需要重启Pod才能完成扩容
- 并非所有provisioner都支持扩容


实际案例
----------

**案例1: 多层存储**

为不同工作负载定义不同的存储类型:

.. code-block:: yaml

    # Fast SSD for databases
    ---
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: fast-ssd
    provisioner: ebs.csi.aws.com
    parameters:
      type: io2
      iops: "10000"
    ---
    # Standard for general use
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: standard
      annotations:
        storageclass.kubernetes.io/is-default-class: "true"
    provisioner: ebs.csi.aws.com
    parameters:
      type: gp3
    ---
    # Slow HDD for archives
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: archive
    provisioner: ebs.csi.aws.com
    parameters:
      type: sc1

使用:

.. code-block:: yaml

    # Database PVC
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: db-storage
    spec:
      storageClassName: fast-ssd
      accessModes: [ReadWriteOnce]
      resources:
        requests:
          storage: 100Gi
    ---
    # Archive PVC
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: archive-storage
    spec:
      storageClassName: archive
      accessModes: [ReadWriteOnce]
      resources:
        requests:
          storage: 1Ti

**案例2: StatefulSet with StorageClass**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: mysql
    spec:
      serviceName: mysql
      replicas: 3
      selector:
        matchLabels:
          app: mysql
      template:
        metadata:
          labels:
            app: mysql
        spec:
          containers:
          - name: mysql
            image: mysql:8.0
            volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
      volumeClaimTemplates:
      - metadata:
          name: data
        spec:
          storageClassName: fast-ssd  # Use fast SSD for database
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: 50Gi


查看和管理
------------

.. code-block:: bash

    # List all StorageClasses
    $ kubectl get storageclass
    $ kubectl get sc  # Short form

    # Describe StorageClass
    $ kubectl describe storageclass fast-ssd

    # Get detailed YAML
    $ kubectl get sc fast-ssd -o yaml

    # Check which is default
    $ kubectl get sc | grep default

    # List PVCs using a specific StorageClass
    $ kubectl get pvc --all-namespaces -o json | jq '.items[] | select(.spec.storageClassName=="fast-ssd") | .metadata.name'

    # Delete StorageClass (must have no PVCs using it)
    $ kubectl delete sc old-storage-class


最佳实践
----------

1. **Set a Default StorageClass**
   
   .. code-block:: bash

       kubectl patch sc standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

2. **Use WaitForFirstConsumer**
   
   For multi-zone clusters, use ``WaitForFirstConsumer`` to ensure PVs are created in the correct zone:

   .. code-block:: yaml

       volumeBindingMode: WaitForFirstConsumer

3. **Enable Volume Expansion**
   
   Allow PVCs to be expanded without recreating:

   .. code-block:: yaml

       allowVolumeExpansion: true

4. **Define Multiple Storage Tiers**
   
   Create different StorageClasses for different performance needs:
   
   - Fast SSD for databases
   - Standard for general use
   - Archive for cold storage

5. **Use Appropriate Reclaim Policy**
   
   - Production: Use ``Retain`` for critical data
   - Development: Use ``Delete`` for automatic cleanup

6. **Tag Provisioned Resources**
   
   Use parameters to tag cloud resources:

   .. code-block:: yaml

       parameters:
         tags: "Environment=Production,Team=Platform"

7. **Set Resource Limits**
   
   Prevent excessive storage provisioning with ResourceQuotas:

   .. code-block:: yaml

       apiVersion: v1
       kind: ResourceQuota
       metadata:
         name: storage-quota
       spec:
         hard:
           requests.storage: "1Ti"
           persistentvolumeclaims: "10"

8. **Monitor Storage Usage**
   
   .. code-block:: bash

       # Check PVC usage
       kubectl get pvc --all-namespaces

       # Check PV status
       kubectl get pv

       # Use kubectl top (requires metrics-server)
       kubectl top pods --containers


故障排查
----------

**PVC Stuck in Pending**

.. code-block:: bash

    # Check PVC events
    $ kubectl describe pvc my-pvc
    
    # Common causes:
    # 1. StorageClass doesn't exist
    $ kubectl get sc
    
    # 2. Provisioner not running
    $ kubectl get pods -n kube-system | grep provisioner
    
    # 3. Quota exceeded
    $ kubectl describe quota
    
    # 4. WaitForFirstConsumer but no pod using PVC yet
    $ kubectl get pods -o wide

**Volume Expansion Failed**

.. code-block:: bash

    # Check if expansion is allowed
    $ kubectl get sc <storage-class> -o yaml | grep allowVolumeExpansion
    
    # Check PVC events
    $ kubectl describe pvc my-pvc
    
    # For file system expansion, may need to restart pod
    $ kubectl delete pod <pod-name>

**PV Not Deleted After PVC Deletion**

.. code-block:: bash

    # Check reclaim policy
    $ kubectl get pv <pv-name> -o yaml | grep reclaimPolicy
    
    # If Retain, manually delete
    $ kubectl delete pv <pv-name>
    
    # Also delete underlying storage (e.g., EBS volume)

**Wrong Zone/Region**

.. code-block:: bash

    # Use WaitForFirstConsumer
    $ kubectl patch sc <storage-class> -p '{"volumeBindingMode":"WaitForFirstConsumer"}'
    
    # Or use allowedTopologies
    allowedTopologies:
    - matchLabelExpressions:
      - key: topology.kubernetes.io/zone
        values:
        - us-east-1a
        - us-east-1b


高级主题
----------

**Topology Awareness**

Restrict storage provisioning to specific zones:

.. code-block:: yaml

    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: zone-specific
    provisioner: ebs.csi.aws.com
    volumeBindingMode: WaitForFirstConsumer
    allowedTopologies:
    - matchLabelExpressions:
      - key: topology.kubernetes.io/zone
        values:
        - us-east-1a
        - us-east-1b

**Custom Provisioner**

Deploy your own storage provisioner for custom storage backends:

.. code-block:: yaml

    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: custom-storage
    provisioner: example.com/my-provisioner
    parameters:
      customParameter: "value"


参考资料
----------

- Storage Classes: https://kubernetes.io/docs/concepts/storage/storage-classes/
- Dynamic Volume Provisioning: https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/
- CSI Drivers: https://kubernetes-csi.github.io/docs/drivers.html
- Volume Expansion: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#expanding-persistent-volumes-claims
