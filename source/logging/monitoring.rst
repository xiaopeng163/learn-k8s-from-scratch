Monitoring
===================

Monitoring is essential for understanding the health and performance of your Kubernetes cluster. Key aspects include:

- **Observe**: Track the current state of resources
- **Measure Changes**: Monitor trends over time
- **Resource Limits**: Ensure resources are not exhausted

Kubernetes Metrics Server
-----------------------------

https://kubernetes-sigs.github.io/metrics-server/

Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.

**What it does:**

- Collects resource metrics from Kubelets for Pods and Nodes
- Provides metrics like CPU and memory usage
- Required for Horizontal Pod Autoscaler (HPA) and Vertical Pod Autoscaler (VPA)
- Lightweight and designed for core monitoring

**What it doesn't do:**

- Does not store historical data (use Prometheus for that)
- Does not provide application-level metrics
- Not designed for alerting


Deploy Metrics Server
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Step 1: Deploy Metrics Server**

.. code-block:: bash

    # Download the latest Metrics Server manifest
    $ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

**Step 2: Verify Deployment**

.. code-block:: bash

    # Check if metrics-server is running
    $ kubectl get deployment metrics-server -n kube-system
    NAME             READY   UP-TO-DATE   AVAILABLE   AGE
    metrics-server   1/1     1            1           2m

    # Check the pods
    $ kubectl get pods -n kube-system -l k8s-app=metrics-server
    NAME                              READY   STATUS    RESTARTS   AGE
    metrics-server-5d5dd7d6f6-xxxxx   1/1     Running   0          2m

**Step 3: Test Metrics Collection**

Wait a few minutes for metrics to be collected, then run:

.. code-block:: bash

    # View node metrics
    $ kubectl top nodes
    NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
    controlplane   250m         12%    1024Mi          53%
    node01         100m         5%     512Mi           26%

    # View pod metrics for all namespaces
    $ kubectl top pods -A
    NAMESPACE     NAME                              CPU(cores)   MEMORY(bytes)
    kube-system   coredns-5d78c9869d-xxxxx          3m           12Mi
    kube-system   etcd-controlplane                 25m          80Mi
    kube-system   kube-apiserver-controlplane       50m          256Mi

    # View pod metrics in a specific namespace
    $ kubectl top pods -n default
    NAME                     CPU(cores)   MEMORY(bytes)
    nginx-6799fc88d8-xxxxx   1m           5Mi

    # View pod metrics with containers breakdown
    $ kubectl top pods --containers
    POD          NAME         CPU(cores)   MEMORY(bytes)
    nginx-pod    nginx        1m           5Mi
    nginx-pod    sidecar      0m           2Mi


Troubleshooting Metrics Server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Issue: "error: Metrics API not available"**

.. code-block:: bash

    # Check if metrics-server is running
    $ kubectl get apiservices v1beta1.metrics.k8s.io -o yaml

    # Check metrics-server logs
    $ kubectl logs -n kube-system deployment/metrics-server

**Common Issues:**

1. **TLS Certificate Issues** (for local development):

   If you see certificate errors, you may need to add ``--kubelet-insecure-tls`` flag:

   .. code-block:: bash

       $ kubectl patch deployment metrics-server -n kube-system --type='json' \
         -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

2. **Network Issues**:

   Ensure the metrics-server can reach the kubelet on each node:

   .. code-block:: bash

       # Check if metrics-server can resolve node names
       $ kubectl logs -n kube-system deployment/metrics-server | grep "unable to fetch"

3. **Resource Constraints**:

   Ensure metrics-server has sufficient resources:

   .. code-block:: bash

       # Check resource limits
       $ kubectl describe deployment metrics-server -n kube-system | grep -A 5 Limits


Monitoring Best Practices
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. **Use Metrics Server for Basic Monitoring**:
   
   - Resource usage tracking (CPU/Memory)
   - Quick health checks with ``kubectl top``
   - Enable autoscaling features

2. **Implement Comprehensive Monitoring**:
   
   For production environments, also consider:
   
   - **Prometheus**: For detailed metrics and alerting
   - **Grafana**: For visualization dashboards
   - **ELK/EFK Stack**: For log aggregation
   - **Jaeger/Zipkin**: For distributed tracing

3. **Monitor Key Metrics**:
   
   - Node resource utilization
   - Pod CPU and memory usage
   - API server latency
   - etcd performance
   - Network throughput
   - Storage I/O

4. **Set Up Alerts**:
   
   - High CPU/Memory usage
   - Pod restart counts
   - Node not ready status
   - Persistent volume issues
   - Certificate expiration


Example: Using Metrics for Autoscaling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Metrics Server is required for Horizontal Pod Autoscaler:

.. code-block:: yaml

    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: nginx-hpa
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: nginx
      minReplicas: 2
      maxReplicas: 10
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 50

Test the autoscaler:

.. code-block:: bash

    # Create the HPA
    $ kubectl apply -f nginx-hpa.yaml

    # Check HPA status
    $ kubectl get hpa
    NAME        REFERENCE          TARGETS   MINPODS   MAXPODS   REPLICAS
    nginx-hpa   Deployment/nginx   15%/50%   2         10        2

    # Generate load and watch scaling
    $ kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://nginx; done"


Additional Resources
~~~~~~~~~~~~~~~~~~~~~~~

- Metrics Server Documentation: https://kubernetes-sigs.github.io/metrics-server/
- Kubernetes Monitoring Architecture: https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/
- Prometheus Operator: https://prometheus-operator.dev/
- Kubernetes Dashboard: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
