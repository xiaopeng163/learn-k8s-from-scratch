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
  - retain, pvc虽然删除了，但是这块pv里的数据会保留，pv的状态会变为released，这是无法马上被下一次的pvc使用，管理员必须手动清理删除

Define a Persistent Volume
-----------------------------------

.. code-block:: yaml

  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: pv-nfs
  spec:
    capacity:
      storage: 4Gi
    accessModes:
      - ReadWriteMany
    persistentVolumeReclaimPolicy: Retain
    nfs:
      server: 192.168.56.20
      path: "/export/volumes/pod"


.. code-block:: bash

    vagrant@k8s-master:~$ kubectl apply -f pv.yml
    persistentvolume/test-nfs created
    vagrant@k8s-master:~$ kubectl get persistentvolume
    NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
    pv-nfs     4Gi        RWX            Retain           Available                                   5s

Define PersistentVolumeClaim
--------------------------------

.. code-block:: yaml

    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: pvc-nfs
    spec:
      accessModes:
        - ReadWriteMany
      resources:
        requests:
          storage: 1Gi


Use persistentvolume in Pod
--------------------------------

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: web
      template:
        metadata:
          labels:
            app: web
        spec:
          volumes:
          - name: webcontent
            persistentVolumeClaim:
              claimName: pvc-nfs
          containers:
          - image: nginx
            name: nginx
            ports:
            - containerPort: 80
            volumeMounts:
            - name: webcontent
              mountPath: "/usr/share/nginx/html/web-app"

查看volume mount

.. code-block:: bash

  $ kubectl get pods -o wide
  NAME                  READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
  web-9996cd57b-988n7   1/1     Running   0          25m   10.244.2.170   k8s-worker2   <none>           <none>

去节点 k8s-worker2 上, 可以看到pod挂载的volume信息

.. code-block::  bash

  vagrant@k8s-worker2:~$ mount | grep nfs
  192.168.56.20:/export/volumes/pod on /var/lib/kubelet/pods/1c17d9be-239c-44b4-8f35-99ad0c7976d2/volumes/kubernetes.io~nfs/pv-nfs type nfs4 (rw,relatime,vers=4.2,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.56.12,local_lock=none,addr=192.168.56.20)

去NFS server上创建一个文件，具体路径为：

.. code-block::  bash

  vagrant@nfs-server:/export/volumes/pod$ pwd
  /export/volumes/pod
  vagrant@nfs-server:/export/volumes/pod$ ls
  index.html
  vagrant@nfs-server:/export/volumes/pod$ more index.html
  hello k8s
  vagrant@nfs-server:/export/volumes/pod$

创建一个service

.. code-block::  bash

  $ kubectl expose deployment web --port=80 --type=NodePort
  $ kubectl get service
  NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
  kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        25d
  web          NodePort    10.97.45.206   <none>        80:32615/TCP   6s

打开浏览器访问 http:<node-ip>:32615/web-app/

应该就能看到 hello k8s


clean
-----------

.. code-block:: bash

    $ kubectl delete service web
    $ kubectl delete deployments.apps web
    $ kubectl delete persistentvolumeclaims pvc-nfs
    $ kubectl delete persistentvolume pv-nfs
