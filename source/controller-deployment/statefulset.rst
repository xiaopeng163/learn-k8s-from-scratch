StatefulSet
=============

StatefulSet is a workload API object used to manage stateful applications. Unlike Deployments, StatefulSets maintain a sticky identity for each pod and provide guarantees about ordering and uniqueness.

什么时候使用StatefulSet
---------------------------

**Use StatefulSets when you need:**

- **Stable, unique network identifiers**: Each pod gets a persistent hostname
- **Stable, persistent storage**: Volumes persist across pod rescheduling
- **Ordered, graceful deployment and scaling**: Pods are created/deleted in order
- **Ordered, automated rolling updates**: Updates happen in a specific sequence

**Common Use Cases:**

- Databases (MySQL, PostgreSQL, MongoDB)
- Distributed systems (Kafka, Elasticsearch, etcd)
- Applications requiring stable network identity (ZooKeeper)
- Stateful applications with leader election


StatefulSet vs Deployment
----------------------------

+----------------------------+--------------------------------+--------------------------------+
| Feature                    | Deployment                     | StatefulSet                    |
+============================+================================+================================+
| Pod Identity               | Random names, interchangeable  | Stable, ordered names          |
+----------------------------+--------------------------------+--------------------------------+
| Network Identity           | Changes on restart             | Persistent hostname            |
+----------------------------+--------------------------------+--------------------------------+
| Storage                    | Shared or ephemeral            | Persistent per pod             |
+----------------------------+--------------------------------+--------------------------------+
| Scaling Order              | Parallel, no guarantee         | Sequential, ordered            |
+----------------------------+--------------------------------+--------------------------------+
| Update Strategy            | Can be parallel                | Sequential, ordered            |
+----------------------------+--------------------------------+--------------------------------+
| Use Case                   | Stateless apps                 | Stateful apps                  |
+----------------------------+--------------------------------+--------------------------------+


StatefulSet基础概念
----------------------

**Pod Identity**

StatefulSet pods have a unique, stable identity consisting of:

- **Ordinal Index**: Pods are numbered 0 to N-1
- **Stable Network ID**: ``<statefulset-name>-<ordinal>``
- **Stable Hostname**: Each pod has a predictable DNS name

**Headless Service**

StatefulSets require a Headless Service (ClusterIP: None) to manage network identity:

.. code-block:: yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: nginx-svc
    spec:
      clusterIP: None  # Headless service
      selector:
        app: nginx
      ports:
      - port: 80

This creates DNS records for each pod: ``<pod-name>.<service-name>.<namespace>.svc.cluster.local``


创建StatefulSet
------------------

**Example: Nginx StatefulSet**

.. code-block:: yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: nginx-svc
      labels:
        app: nginx
    spec:
      ports:
      - port: 80
        name: web
      clusterIP: None  # Headless service
      selector:
        app: nginx
    ---
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: web
    spec:
      serviceName: "nginx-svc"  # Must match the headless service
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:1.21
            ports:
            - containerPort: 80
              name: web
            volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
      volumeClaimTemplates:  # Creates PVC for each pod
      - metadata:
          name: www
        spec:
          accessModes: [ "ReadWriteOnce" ]
          storageClassName: "standard"  # Use your storage class
          resources:
            requests:
              storage: 1Gi

创建并验证:

.. code-block:: bash

    # Create the StatefulSet
    $ kubectl apply -f statefulset.yaml
    service/nginx-svc created
    statefulset.apps/web created

    # Watch pods being created (notice the ordered creation)
    $ kubectl get pods -w
    NAME    READY   STATUS    RESTARTS   AGE
    web-0   0/1     Pending   0          0s
    web-0   0/1     ContainerCreating   0          0s
    web-0   1/1     Running             0          2s
    web-1   0/1     Pending             0          0s
    web-1   0/1     ContainerCreating   0          0s
    web-1   1/1     Running             0          2s
    web-2   0/1     Pending             0          0s
    web-2   0/1     ContainerCreating   0          0s
    web-2   1/1     Running             0          2s

    # View the StatefulSet
    $ kubectl get statefulset
    NAME   READY   AGE
    web    3/3     1m

    # View the pods (notice the ordinal names)
    $ kubectl get pods -l app=nginx
    NAME    READY   STATUS    RESTARTS   AGE
    web-0   1/1     Running   0          1m
    web-1   1/1     Running   0          1m
    web-2   1/1     Running   0          1m

    # View the PVCs (one per pod)
    $ kubectl get pvc
    NAME        STATUS   VOLUME                                     CAPACITY
    www-web-0   Bound    pvc-8c8c8c8c-8c8c-8c8c-8c8c-8c8c8c8c8c8c   1Gi
    www-web-1   Bound    pvc-9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d   1Gi
    www-web-2   Bound    pvc-aeaeaeae-aeae-aeae-aeae-aeaeaeaeaeae   1Gi


稳定的网络标识
----------------

Each pod gets a stable DNS name:

.. code-block:: bash

    # Format: <pod-name>.<service-name>.<namespace>.svc.cluster.local
    # For example:
    # - web-0.nginx-svc.default.svc.cluster.local
    # - web-1.nginx-svc.default.svc.cluster.local
    # - web-2.nginx-svc.default.svc.cluster.local

    # Test DNS resolution
    $ kubectl run -it --rm debug --image=busybox --restart=Never -- sh
    
    # Inside the debug pod:
    / # nslookup web-0.nginx-svc.default.svc.cluster.local
    Server:    10.96.0.10
    Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local
    
    Name:      web-0.nginx-svc.default.svc.cluster.local
    Address 1: 10.244.1.5 web-0.nginx-svc.default.svc.cluster.local

    # Ping specific pod
    / # ping web-0.nginx-svc
    PING web-0.nginx-svc (10.244.1.5): 56 data bytes
    64 bytes from 10.244.1.5: seq=0 ttl=64 time=0.123 ms

**Even if a pod is deleted and recreated, it maintains the same name and DNS record:**

.. code-block:: bash

    # Delete a pod
    $ kubectl delete pod web-1
    pod "web-1" deleted

    # StatefulSet recreates it with the same name
    $ kubectl get pods -l app=nginx
    NAME    READY   STATUS    RESTARTS   AGE
    web-0   1/1     Running   0          5m
    web-1   1/1     Running   0          10s   # Same name, new pod
    web-2   1/1     Running   0          5m


持久化存储
------------

**Volume Claim Templates**

StatefulSets use ``volumeClaimTemplates`` to automatically create a PVC for each pod:

.. code-block:: yaml

    volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        storageClassName: "fast-ssd"
        resources:
          requests:
            storage: 10Gi

**Key Points:**

- Each pod gets its own PVC
- PVCs are named: ``<template-name>-<statefulset-name>-<ordinal>``
- PVCs persist even if pods are deleted
- When pod is recreated, it reattaches to the same PVC

.. code-block:: bash

    # Check PVCs
    $ kubectl get pvc
    NAME         STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS
    data-web-0   Bound    pv-001    10Gi       RWO            fast-ssd
    data-web-1   Bound    pv-002    10Gi       RWO            fast-ssd
    data-web-2   Bound    pv-003    10Gi       RWO            fast-ssd

    # Delete a pod
    $ kubectl delete pod web-1

    # The PVC remains
    $ kubectl get pvc
    NAME         STATUS   VOLUME    CAPACITY
    data-web-0   Bound    pv-001    10Gi
    data-web-1   Bound    pv-002    10Gi      # Still here!
    data-web-2   Bound    pv-003    10Gi

    # New pod reattaches to the same PVC
    $ kubectl get pods
    NAME    READY   STATUS    RESTARTS   AGE
    web-1   1/1     Running   0          30s   # Using data-web-1 PVC


扩缩容
--------

**Scaling Up (Sequential)**

.. code-block:: bash

    # Scale from 3 to 5 replicas
    $ kubectl scale statefulset web --replicas=5

    # Pods are created sequentially
    $ kubectl get pods -w
    web-3   0/1     Pending   0          0s
    web-3   1/1     Running   0          2s
    web-4   0/1     Pending   0          0s    # web-4 starts after web-3 is ready
    web-4   1/1     Running   0          2s

**Scaling Down (Reverse Order)**

.. code-block:: bash

    # Scale from 5 to 3 replicas
    $ kubectl scale statefulset web --replicas=3

    # Pods are deleted in reverse order
    $ kubectl get pods -w
    web-4   1/1     Terminating   0          5m
    web-4   0/1     Terminating   0          5m
    web-3   1/1     Terminating   0          5m    # web-3 deleted after web-4
    web-3   0/1     Terminating   0          5m

    # Final state
    $ kubectl get pods
    NAME    READY   STATUS    RESTARTS   AGE
    web-0   1/1     Running   0          10m
    web-1   1/1     Running   0          10m
    web-2   1/1     Running   0          10m

**Important:** Scaling down does NOT delete PVCs automatically:

.. code-block:: bash

    # PVCs remain after scaling down
    $ kubectl get pvc
    NAME         STATUS   VOLUME
    data-web-0   Bound    pv-001
    data-web-1   Bound    pv-002
    data-web-2   Bound    pv-003
    data-web-3   Bound    pv-004    # Still exists
    data-web-4   Bound    pv-005    # Still exists

    # If you scale up again, pods reuse existing PVCs
    $ kubectl scale statefulset web --replicas=5


更新策略
----------

**RollingUpdate (Default)**

Updates pods in reverse ordinal order (N-1 to 0):

.. code-block:: yaml

    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: web
    spec:
      updateStrategy:
        type: RollingUpdate
        rollingUpdate:
          partition: 0  # Update all pods

.. code-block:: bash

    # Update image
    $ kubectl set image statefulset/web nginx=nginx:1.22

    # Watch the rolling update (reverse order)
    $ kubectl rollout status statefulset/web
    waiting for statefulset rolling update to complete 0 pods at revision web-2...
    waiting for statefulset rolling update to complete 1 pods at revision web-2...
    waiting for statefulset rolling update to complete 2 pods at revision web-2...
    statefulset rolling update complete 3 pods at revision web-2...

**Partition Updates**

Use ``partition`` to stage updates (canary deployments):

.. code-block:: yaml

    updateStrategy:
      type: RollingUpdate
      rollingUpdate:
        partition: 2  # Only update pods with ordinal >= 2

.. code-block:: bash

    # This will only update web-2, web-3, web-4, etc.
    # web-0 and web-1 remain at the old version
    $ kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":2}}}}'

**OnDelete Strategy**

Pods are updated only when manually deleted:

.. code-block:: yaml

    updateStrategy:
      type: OnDelete


完整示例：MySQL StatefulSet
-------------------------------

.. code-block:: yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: mysql
    spec:
      clusterIP: None
      selector:
        app: mysql
      ports:
      - port: 3306
        name: mysql
    ---
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
            env:
            - name: MYSQL_ROOT_PASSWORD
              value: "password"
            ports:
            - containerPort: 3306
              name: mysql
            volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
            - name: config
              mountPath: /etc/mysql/conf.d
          volumes:
          - name: config
            configMap:
              name: mysql-config
      volumeClaimTemplates:
      - metadata:
          name: data
        spec:
          accessModes: [ "ReadWriteOnce" ]
          storageClassName: "standard"
          resources:
            requests:
              storage: 10Gi

连接到MySQL实例:

.. code-block:: bash

    # Connect to a specific MySQL instance
    $ kubectl run -it --rm mysql-client --image=mysql:8.0 --restart=Never -- \
      mysql -h mysql-0.mysql.default.svc.cluster.local -p

    # From another pod, you can connect to:
    # - mysql-0.mysql.default.svc.cluster.local
    # - mysql-1.mysql.default.svc.cluster.local
    # - mysql-2.mysql.default.svc.cluster.local


StatefulSet管理
-----------------

**查看状态**

.. code-block:: bash

    # Get StatefulSet status
    $ kubectl get statefulset web
    NAME   READY   AGE
    web    3/3     10m

    # Describe StatefulSet
    $ kubectl describe statefulset web

    # Get detailed output
    $ kubectl get statefulset web -o yaml

**删除StatefulSet**

.. code-block:: bash

    # Delete StatefulSet but keep pods running
    $ kubectl delete statefulset web --cascade=orphan

    # Delete StatefulSet and pods (default)
    $ kubectl delete statefulset web

    # Note: PVCs are NOT deleted automatically
    # Delete PVCs manually if needed
    $ kubectl delete pvc www-web-0 www-web-1 www-web-2

**暂停和恢复**

.. code-block:: bash

    # Pause rollout (for RollingUpdate)
    $ kubectl rollout pause statefulset/web

    # Resume rollout
    $ kubectl rollout resume statefulset/web

    # Check rollout history
    $ kubectl rollout history statefulset/web

    # Rollback to previous version
    $ kubectl rollout undo statefulset/web


最佳实践
----------

1. **Always Use Headless Service**
   
   StatefulSets require a headless service for stable network identity.

2. **Plan Storage Carefully**
   
   - Choose appropriate StorageClass
   - Size PVCs appropriately (they can't be shrunk)
   - Consider backup strategy

3. **Set Pod Management Policy**
   
   .. code-block:: yaml

       spec:
         podManagementPolicy: OrderedReady  # Default, sequential
         # OR
         podManagementPolicy: Parallel      # Faster, but no ordering

4. **Use Init Containers for Setup**
   
   Initialize data or configuration before main container starts.

5. **Implement Readiness Probes**
   
   Ensure pods are truly ready before proceeding to next pod:

   .. code-block:: yaml

       readinessProbe:
         httpGet:
           path: /health
           port: 8080
         initialDelaySeconds: 10
         periodSeconds: 5

6. **Don't Forget Resource Limits**
   
   .. code-block:: yaml

       resources:
         requests:
           memory: "1Gi"
           cpu: "500m"
         limits:
           memory: "2Gi"
           cpu: "1000m"

7. **Plan for PVC Cleanup**
   
   Automate PVC deletion for scaled-down pods:

   .. code-block:: bash

       # Script to clean up unused PVCs
       kubectl get pvc | grep "www-web-" | awk '{if ($1 ~ /web-[3-9]/) print $1}' | xargs kubectl delete pvc

8. **Use Anti-Affinity for HA**
   
   Spread pods across nodes:

   .. code-block:: yaml

       affinity:
         podAntiAffinity:
           requiredDuringSchedulingIgnoredDuringExecution:
           - labelSelector:
               matchExpressions:
               - key: app
                 operator: In
                 values:
                 - mysql
             topologyKey: kubernetes.io/hostname


故障排查
----------

**Pod Stuck in Pending**

.. code-block:: bash

    # Check PVC status
    $ kubectl get pvc
    
    # Check events
    $ kubectl describe statefulset web
    $ kubectl describe pod web-0

    # Common causes:
    # - No PV available for PVC
    # - StorageClass doesn't exist
    # - Insufficient node resources

**Pod Not Getting Stable Identity**

.. code-block:: bash

    # Verify headless service exists
    $ kubectl get svc nginx-svc
    
    # Check if serviceName matches
    $ kubectl get statefulset web -o yaml | grep serviceName

**Slow Rolling Updates**

.. code-block:: bash

    # Check pod readiness probe
    $ kubectl get pods
    
    # Check events
    $ kubectl get events --sort-by='.lastTimestamp'
    
    # Consider using partition for staged rollouts

**PVC Not Binding**

.. code-block:: bash

    # Check StorageClass
    $ kubectl get storageclass
    
    # Check PV availability
    $ kubectl get pv
    
    # Describe PVC
    $ kubectl describe pvc data-web-0


参考资料
----------

- StatefulSet Basics: https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/
- StatefulSet Concepts: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
- Run Replicated Stateful Application: https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/
