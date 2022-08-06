Job and CronJob
===================

.. warning::

    注意API的版本，可能会随着Kubernetes的版本更新而改变

.. code-block:: bash

    $ kubectl api-resources | grep job
    cronjobs                          cj           batch/v1                               true         CronJob
    jobs                                           batch/v1                               true         Job


Job
-------

Job: https://kubernetes.io/docs/concepts/workloads/controllers/job/

一次性运行的Pod，一般为执行某个命令或者脚本，执行结束后pod的生命随之结束


create job

.. code-block:: bash

    $ kubectl create job my-job --image=busybox -- sh -c "sleep 50"


.. code-block:: yaml

    apiVersion: batch/v1
    kind: Job
    metadata:
      name: my-job
    spec:
      template:
        spec:
          containers:
          - name: my-job
            image: busybox
            command: ["sh",  "-c", "sleep 50"]
          restartPolicy: Never

.. code-block:: bash

    $ kubectl get pods
    NAME           READY   STATUS    RESTARTS   AGE
    my-job-z679f   1/1     Running   0          10s

    $ kubectl get pods
    NAME           READY   STATUS      RESTARTS   AGE
    my-job-z679f   0/1     Completed   0          63s


CronJob
---------

计划任务

CronJobs: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/

create CronJob

.. code-block:: yaml

    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: hello
    spec:
      schedule: "*/1 * * * *"
      jobTemplate:
        spec:
          template:
            spec:
              containers:
              - name: hello
                image: busybox:1.28
                imagePullPolicy: IfNotPresent
                command:
                - /bin/sh
                - -c
                - date; echo Hello from the Kubernetes cluster
              restartPolicy: OnFailure
