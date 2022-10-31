Volumes
=====================

https://kubernetes.io/docs/concepts/storage/volumes/

Kubernetes中的Volume基本延续了Docker中Volume的概念。 Kubernetes 将 Volume 分为持久化的 PersistentVolume 和非持久化的普通 Volume 两类。

- 普通的volume只是为了一个Pod中的多个container之间可以共享数据，它具有和pod相同的生命周期，所以本质上不具有持久化的功能
- Persistent Volume 是指能够将数据进行持久化存储的一种资源对象，它可以独立于 Pod 存在，生命周期与 Pod 无关，因此也决定了 PersistentVolume 不应该依附于任何一个宿主机节点，否则必然会对 Pod 调度产生干扰限制。

emptyDir
------------

https://kubernetes.io/docs/concepts/storage/volumes/#emptydir

An emptyDir volume is first created when a Pod is assigned to a node, and exists as long as that Pod is running on that node.
As the name says, the emptyDir volume is initially empty. All containers in the Pod can read and write the same files in the emptyDir volume,
though that volume can be mounted at the same or different paths in each container. When a Pod is removed from a node for any reason, the data in the emptyDir is deleted permanently.


.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: multicontainer-pod
    spec:
      containers:
      - name: producer
        image: busybox
        command: ["sh", "-c", "while true; do echo $(hostname) $(date) >> /var/log/index.html; sleep 10; done"]
        volumeMounts:
        - name: webcontent
          mountPath: /var/log
      - name: consumer
        image: nginx
        ports:
          - containerPort: 80
        volumeMounts:
        - name: webcontent
          mountPath: /usr/share/nginx/html
      volumes:
      - name: webcontent
        emptyDir: {}


hostPath
---------------

https://kubernetes.io/docs/concepts/storage/volumes/#hostpath

A hostPath volume mounts a file or directory from the host node's filesystem into your Pod.
This is not something that most Pods will need, but it offers a powerful escape hatch for some applications.


.. code-block:: yaml

      apiVersion: v1
      kind: Pod
      metadata:
        name: multicontainer-pod
      spec:
        containers:
        - name: producer
          image: busybox
          command: ["sh", "-c", "while true; do echo $(hostname) $(date) >> /var/log/index.html; sleep 10; done"]
          volumeMounts:
          - name: webcontent
            mountPath: /var/log
        - name: consumer
          image: nginx
          ports:
            - containerPort: 80
          volumeMounts:
          - name: webcontent
            mountPath: /usr/share/nginx/html
        volumes:
        - name: webcontent
          hostPath:
            path: /tmp
            type: Directory
