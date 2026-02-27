Troubleshooting Tools
==========================

Kubernetes provides various tools and commands for troubleshooting cluster and application issues. This section covers the essential tools you need to diagnose and resolve problems.

kubectl logs
--------------

View container logs to debug application issues.

**Basic Usage:**

.. code-block:: bash

    # View logs from a single-container pod
    $ kubectl logs <pod-name>

    # View logs from a specific container in a multi-container pod
    $ kubectl logs <pod-name> -c <container-name>

    # Follow logs in real-time (like tail -f)
    $ kubectl logs -f <pod-name>

    # View logs from a previous container instance (useful after crashes)
    $ kubectl logs <pod-name> --previous

    # View last 100 lines
    $ kubectl logs <pod-name> --tail=100

    # View logs since a specific time
    $ kubectl logs <pod-name> --since=1h
    $ kubectl logs <pod-name> --since-time=2024-01-01T00:00:00Z

**Advanced Examples:**

.. code-block:: bash

    # View logs from all containers in a pod
    $ kubectl logs <pod-name> --all-containers=true

    # View logs from all pods with a specific label
    $ kubectl logs -l app=nginx

    # Combine options
    $ kubectl logs -f <pod-name> -c <container> --tail=50

**Common Use Cases:**

.. code-block:: bash

    # Debug application startup issues
    $ kubectl logs deployment/myapp --tail=100

    # Check for errors in init containers
    $ kubectl logs <pod-name> -c <init-container-name>

    # View logs from a job
    $ kubectl logs job/my-job


kubectl events
-----------------

View cluster events to understand what's happening in your cluster.

**Basic Usage:**

.. code-block:: bash

    # View all events in the current namespace
    $ kubectl get events

    # View events sorted by creation timestamp
    $ kubectl get events --sort-by='.metadata.creationTimestamp'

    # View events in all namespaces
    $ kubectl get events -A

    # Watch events in real-time
    $ kubectl get events --watch

    # View events for a specific resource
    $ kubectl describe pod <pod-name> | grep -A 10 Events:

**Filter Events:**

.. code-block:: bash

    # Show only warning events
    $ kubectl get events --field-selector type=Warning

    # Show events for a specific object
    $ kubectl get events --field-selector involvedObject.name=<pod-name>

    # Show events in the last 30 minutes
    $ kubectl get events --field-selector type=Warning --sort-by='.lastTimestamp' | head -20

**Event Types:**

- ``Normal``: Regular operational events
- ``Warning``: Potential issues that need attention

**Example Output:**

.. code-block:: bash

    $ kubectl get events --sort-by='.lastTimestamp'
    LAST SEEN   TYPE      REASON              OBJECT                MESSAGE
    2m          Normal    Scheduled           pod/nginx-xxx         Successfully assigned default/nginx-xxx to node01
    2m          Normal    Pulling             pod/nginx-xxx         Pulling image "nginx:1.21"
    1m          Normal    Pulled              pod/nginx-xxx         Successfully pulled image
    1m          Normal    Created             pod/nginx-xxx         Created container nginx
    1m          Normal    Started             pod/nginx-xxx         Started container nginx


kubectl describe
-------------------

Get detailed information about resources including events.

.. code-block:: bash

    # Describe a pod (includes recent events)
    $ kubectl describe pod <pod-name>

    # Describe a node
    $ kubectl describe node <node-name>

    # Describe a deployment
    $ kubectl describe deployment <deployment-name>

**What to Look For:**

- Pod status and conditions
- Container states and restart counts
- Resource requests and limits
- Events at the bottom of the output
- Node conditions and capacity


systemctl (for Node-Level Issues)
-------------------------------------

Manage system services on cluster nodes. You need SSH access to the nodes.

**Check Service Status:**

.. code-block:: bash

    # Check kubelet status
    $ systemctl status kubelet

    # Check containerd/docker status
    $ systemctl status containerd
    $ systemctl status docker

    # Check if service is enabled
    $ systemctl is-enabled kubelet

**Restart Services:**

.. code-block:: bash

    # Restart kubelet
    $ sudo systemctl restart kubelet

    # Restart container runtime
    $ sudo systemctl restart containerd

**Enable Services:**

.. code-block:: bash

    # Enable kubelet to start on boot
    $ sudo systemctl enable kubelet

    # Start kubelet now
    $ sudo systemctl start kubelet


journalctl (for System Logs)
--------------------------------

View system logs for Kubernetes components on nodes.

**View Kubelet Logs:**

.. code-block:: bash

    # View all kubelet logs
    $ journalctl -u kubelet

    # Follow kubelet logs in real-time
    $ journalctl -u kubelet -f

    # View logs since last boot
    $ journalctl -u kubelet -b

    # View logs from the last hour
    $ journalctl -u kubelet --since "1 hour ago"

    # View logs with specific priority (error level)
    $ journalctl -u kubelet -p err

    # View last 100 lines
    $ journalctl -u kubelet -n 100

**View Container Runtime Logs:**

.. code-block:: bash

    # View containerd logs
    $ journalctl -u containerd -f

    # View docker logs
    $ journalctl -u docker -f

**View API Server Logs (if running as systemd service):**

.. code-block:: bash

    $ journalctl -u kube-apiserver -f

**Useful Options:**

.. code-block:: bash

    # Combine time filters
    $ journalctl -u kubelet --since "2024-01-01 00:00:00" --until "2024-01-01 01:00:00"

    # Output in JSON format
    $ journalctl -u kubelet -o json

    # Show only kernel messages
    $ journalctl -k


System Logs
--------------

Check traditional system logs for cluster-related issues.

**Common Log Locations:**

.. code-block:: bash

    # General system log
    $ tail -f /var/log/syslog        # Debian/Ubuntu
    $ tail -f /var/log/messages      # RHEL/CentOS

    # Kubernetes component logs (if not using systemd)
    $ tail -f /var/log/kube-apiserver.log
    $ tail -f /var/log/kube-scheduler.log
    $ tail -f /var/log/kube-controller-manager.log

    # Container runtime logs
    $ tail -f /var/log/containerd.log
    $ tail -f /var/log/docker.log

**Pod Logs on Nodes:**

.. code-block:: bash

    # Container logs are stored here
    $ ls /var/log/pods/
    $ ls /var/log/containers/


Additional Debugging Tools
-----------------------------

**kubectl exec**

Execute commands in a running container:

.. code-block:: bash

    # Get a shell in a container
    $ kubectl exec -it <pod-name> -- /bin/bash

    # Run a single command
    $ kubectl exec <pod-name> -- ls /app

    # Execute in a specific container
    $ kubectl exec -it <pod-name> -c <container-name> -- /bin/sh

**kubectl port-forward**

Forward local port to a pod for debugging:

.. code-block:: bash

    # Forward local port 8080 to pod port 80
    $ kubectl port-forward pod/<pod-name> 8080:80

    # Forward to a service
    $ kubectl port-forward service/<service-name> 8080:80

**kubectl debug**

Create debugging containers (requires Kubernetes 1.18+):

.. code-block:: bash

    # Create a debug container in a running pod
    $ kubectl debug <pod-name> -it --image=busybox

    # Create a copy of a pod with different settings
    $ kubectl debug <pod-name> -it --image=busybox --copy-to=<new-pod-name>

    # Debug a node by creating a privileged pod
    $ kubectl debug node/<node-name> -it --image=ubuntu

**crictl (Container Runtime Interface tool)**

Interact with the container runtime directly on nodes:

.. code-block:: bash

    # List all containers
    $ crictl ps -a

    # Inspect a container
    $ crictl inspect <container-id>

    # View container logs
    $ crictl logs <container-id>

    # List all pods
    $ crictl pods

    # Pull an image
    $ crictl pull nginx:latest


Troubleshooting Workflow
---------------------------

**Step 1: Identify the Problem**

.. code-block:: bash

    # Check cluster health
    $ kubectl get nodes
    $ kubectl get pods -A
    $ kubectl get events --sort-by='.lastTimestamp' | tail -20

**Step 2: Investigate the Resource**

.. code-block:: bash

    # Get detailed information
    $ kubectl describe pod <pod-name>
    $ kubectl logs <pod-name>

**Step 3: Check Node-Level Issues**

.. code-block:: bash

    # SSH to the node
    $ ssh user@node

    # Check kubelet
    $ systemctl status kubelet
    $ journalctl -u kubelet -f

**Step 4: Verify Network and DNS**

.. code-block:: bash

    # Test DNS
    $ kubectl run tmp --rm -i --tty --image=busybox -- nslookup kubernetes.default

    # Test connectivity
    $ kubectl run tmp --rm -i --tty --image=busybox -- wget -O- http://service-name

**Step 5: Check Resource Constraints**

.. code-block:: bash

    # Check node resources
    $ kubectl top nodes
    $ kubectl describe node <node-name>

    # Check pod resources
    $ kubectl top pods


Quick Reference Cheat Sheet
-------------------------------

.. code-block:: bash

    # Pod troubleshooting
    kubectl get pods
    kubectl describe pod <pod-name>
    kubectl logs <pod-name>
    kubectl logs <pod-name> --previous
    kubectl exec -it <pod-name> -- /bin/bash

    # Node troubleshooting
    kubectl get nodes
    kubectl describe node <node-name>
    kubectl top nodes

    # Service troubleshooting
    kubectl get svc
    kubectl describe svc <service-name>
    kubectl get endpoints <service-name>

    # Events and debugging
    kubectl get events --sort-by='.lastTimestamp'
    kubectl get events --field-selector type=Warning
    kubectl cluster-info dump

    # Node-level (requires SSH)
    systemctl status kubelet
    journalctl -u kubelet -f
    crictl ps
    crictl logs <container-id>
