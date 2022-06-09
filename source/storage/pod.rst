.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: multicontainer-pod
    spec:
      containers:
      - name: producer
        image: busybox
        command: ["sh", "-c", "while ture; do echo $(hostname) $(date) >> /var/log/index.html; sleep 10; done"]
        volumeMounts:
        - name: webcontent
          mountPath: /var/log
      - name: consumer
        image: nginx
        ports:
          - containerPort: 80
        volumeMounts:
        - name: webcontent
          mountPath: /user/share/nginx/html
      volumes:
      - name: webcontent
        emptyDir: {}