Network Policy
================

NetworkPolicy is a Kubernetes resource that controls traffic between pods and/or network endpoints. It acts as a firewall for your pods, allowing you to specify which connections are allowed.

什么是Network Policy
----------------------

**Key Concepts:**

- **Pod-level Firewall**: Controls ingress (incoming) and egress (outgoing) traffic for pods
- **Label-based Selection**: Uses labels to select which pods the policy applies to
- **Default Deny**: By default, all traffic is allowed; NetworkPolicies create restrictions
- **Namespace-scoped**: NetworkPolicies are namespace resources
- **Requires CNI Support**: Your CNI plugin must support NetworkPolicy (Calico, Cilium, Weave Net)

**Without NetworkPolicy:**

All pods can communicate with all pods (default allow-all behavior)

**With NetworkPolicy:**

You can:

- Isolate pods from each other
- Allow only specific pods to communicate
- Restrict access to specific ports
- Control external traffic


前提条件
----------

**Check if your CNI supports NetworkPolicy:**

.. code-block:: bash

    # Common CNI plugins with NetworkPolicy support:
    # ✅ Calico
    # ✅ Cilium
    # ✅ Weave Net
    # ✅ Antrea
    # ❌ Flannel (does not support NetworkPolicy)

    # Check your CNI
    $ kubectl get pods -n kube-system | grep -E "calico|cilium|weave|flannel"

If using Flannel, you need to switch to a NetworkPolicy-capable CNI or use Flannel + Canal.


NetworkPolicy基础
-------------------

**Simple Example:**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: deny-all
      namespace: default
    spec:
      podSelector: {}  # Empty selector = all pods in namespace
      policyTypes:
      - Ingress
      - Egress

This policy blocks ALL ingress and egress traffic for all pods in the namespace (except what you explicitly allow).


NetworkPolicy结构
-------------------

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: example-policy
      namespace: default
    spec:
      podSelector:  # Which pods this policy applies to
        matchLabels:
          role: db
      policyTypes:  # Types of traffic to control
      - Ingress
      - Egress
      ingress:  # Ingress rules (incoming traffic)
      - from:
        - podSelector:
            matchLabels:
              role: frontend
        ports:
        - protocol: TCP
          port: 3306
      egress:  # Egress rules (outgoing traffic)
      - to:
        - podSelector:
            matchLabels:
              role: monitoring
        ports:
        - protocol: TCP
          port: 9090

**字段说明:**

- ``podSelector``: 选择该策略应用到哪些Pod（基于标签）
- ``policyTypes``: 指定策略类型（Ingress、Egress或两者）
- ``ingress``: 入站规则列表（允许哪些流量进入）
- ``egress``: 出站规则列表（允许哪些流量出去）
- ``from``: 允许的流量来源
- ``to``: 允许的流量目的地
- ``ports``: 允许的端口和协议


Ingress规则
-------------

**Example 1: Allow Traffic from Specific Pods**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-frontend-to-backend
      namespace: default
    spec:
      podSelector:
        matchLabels:
          app: backend  # Apply to backend pods
      policyTypes:
      - Ingress
      ingress:
      - from:
        - podSelector:
            matchLabels:
              app: frontend  # Allow from frontend pods
        ports:
        - protocol: TCP
          port: 8080

**Example 2: Allow Traffic from Specific Namespace**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-from-monitoring-namespace
      namespace: default
    spec:
      podSelector:
        matchLabels:
          app: backend
      policyTypes:
      - Ingress
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              name: monitoring  # Allow from monitoring namespace
        ports:
        - protocol: TCP
          port: 9090

**Example 3: Allow Traffic from IP Blocks**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-external-traffic
      namespace: default
    spec:
      podSelector:
        matchLabels:
          app: web
      policyTypes:
      - Ingress
      ingress:
      - from:
        - ipBlock:
            cidr: 192.168.1.0/24  # Allow from this CIDR
            except:
            - 192.168.1.5/32  # Except this IP
        ports:
        - protocol: TCP
          port: 80

**Example 4: Combine Multiple Selectors (OR logic)**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-multiple-sources
    spec:
      podSelector:
        matchLabels:
          app: backend
      policyTypes:
      - Ingress
      ingress:
      - from:
        - podSelector:
            matchLabels:
              app: frontend  # OR
        - namespaceSelector:
            matchLabels:
              name: monitoring  # OR
        - ipBlock:
            cidr: 10.0.0.0/8  # OR

**Example 5: Combine Selectors (AND logic)**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-specific-namespace-and-pod
    spec:
      podSelector:
        matchLabels:
          app: backend
      policyTypes:
      - Ingress
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              name: production
          podSelector:
            matchLabels:
              app: frontend  # Must match BOTH namespace AND pod label


Egress规则
------------

**Example 1: Allow DNS**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-dns
      namespace: default
    spec:
      podSelector:
        matchLabels:
          app: myapp
      policyTypes:
      - Egress
      egress:
      - to:
        - namespaceSelector:
            matchLabels:
              name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
        ports:
        - protocol: UDP
          port: 53

**Example 2: Allow External HTTPS**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-external-https
      namespace: default
    spec:
      podSelector:
        matchLabels:
          app: myapp
      policyTypes:
      - Egress
      egress:
      - to:
        - ipBlock:
            cidr: 0.0.0.0/0  # All external IPs
            except:
            - 169.254.169.254/32  # Except metadata service
        ports:
        - protocol: TCP
          port: 443

**Example 3: Allow Traffic to Database**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-to-database
      namespace: default
    spec:
      podSelector:
        matchLabels:
          app: backend
      policyTypes:
      - Egress
      egress:
      - to:
        - podSelector:
            matchLabels:
              app: mysql
        ports:
        - protocol: TCP
          port: 3306


常见策略模式
--------------

**Pattern 1: Default Deny All**

Block all traffic and explicitly allow what's needed:

.. code-block:: yaml

    # Deny all ingress
    ---
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: default-deny-ingress
    spec:
      podSelector: {}
      policyTypes:
      - Ingress
    ---
    # Deny all egress
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: default-deny-egress
    spec:
      podSelector: {}
      policyTypes:
      - Egress

**Pattern 2: Allow All (Explicitly)**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-all
    spec:
      podSelector: {}
      ingress:
      - {}
      egress:
      - {}
      policyTypes:
      - Ingress
      - Egress

**Pattern 3: Three-Tier Application**

.. code-block:: yaml

    # Frontend: Allow ingress from LoadBalancer, egress to backend
    ---
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: frontend-policy
    spec:
      podSelector:
        matchLabels:
          tier: frontend
      policyTypes:
      - Ingress
      - Egress
      ingress:
      - from:
        - ipBlock:
            cidr: 0.0.0.0/0  # Public internet
        ports:
        - protocol: TCP
          port: 80
      egress:
      - to:
        - podSelector:
            matchLabels:
              tier: backend
        ports:
        - protocol: TCP
          port: 8080
      - to:  # DNS
        - namespaceSelector:
            matchLabels:
              name: kube-system
        ports:
        - protocol: UDP
          port: 53
    ---
    # Backend: Allow from frontend, allow to database
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: backend-policy
    spec:
      podSelector:
        matchLabels:
          tier: backend
      policyTypes:
      - Ingress
      - Egress
      ingress:
      - from:
        - podSelector:
            matchLabels:
              tier: frontend
        ports:
        - protocol: TCP
          port: 8080
      egress:
      - to:
        - podSelector:
            matchLabels:
              tier: database
        ports:
        - protocol: TCP
          port: 5432
      - to:  # DNS
        - namespaceSelector:
            matchLabels:
              name: kube-system
        ports:
        - protocol: UDP
          port: 53
    ---
    # Database: Allow only from backend
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: database-policy
    spec:
      podSelector:
        matchLabels:
          tier: database
      policyTypes:
      - Ingress
      - Egress
      ingress:
      - from:
        - podSelector:
            matchLabels:
              tier: backend
        ports:
        - protocol: TCP
          port: 5432
      egress:
      - to:  # DNS
        - namespaceSelector:
            matchLabels:
              name: kube-system
        ports:
        - protocol: UDP
          port: 53

**Pattern 4: Namespace Isolation**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: deny-from-other-namespaces
      namespace: production
    spec:
      podSelector: {}
      policyTypes:
      - Ingress
      ingress:
      - from:
        - podSelector: {}  # Allow only from same namespace


实际操作
----------

**Step 1: Deploy Test Application**

.. code-block:: bash

    # Create namespaces
    $ kubectl create namespace frontend
    $ kubectl create namespace backend

    # Deploy frontend
    $ kubectl run nginx --image=nginx --labels="app=frontend" -n frontend

    # Deploy backend
    $ kubectl run httpd --image=httpd --labels="app=backend" -n backend

**Step 2: Verify Initial Connectivity (No Policies)**

.. code-block:: bash

    # Get backend pod IP
    $ kubectl get pod -n backend -o wide
    NAME    READY   STATUS    RESTARTS   AGE   IP
    httpd   1/1     Running   0          1m    10.244.1.5

    # Test connectivity from frontend
    $ kubectl exec -n frontend nginx -- curl -m 3 10.244.1.5
    # Should work (default allow-all)

**Step 3: Apply Deny-All Policy to Backend**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: deny-all
      namespace: backend
    spec:
      podSelector: {}
      policyTypes:
      - Ingress

.. code-block:: bash

    $ kubectl apply -f deny-all.yaml

    # Test connectivity again
    $ kubectl exec -n frontend nginx -- curl -m 3 10.244.1.5
    # Timeout (connection blocked)

**Step 4: Allow Specific Traffic**

.. code-block:: yaml

    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-from-frontend
      namespace: backend
    spec:
      podSelector:
        matchLabels:
          app: backend
      policyTypes:
      - Ingress
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              name: frontend
          podSelector:
            matchLabels:
              app: frontend

.. code-block:: bash

    $ kubectl apply -f allow-from-frontend.yaml

    # Label the frontend namespace
    $ kubectl label namespace frontend name=frontend

    # Test connectivity
    $ kubectl exec -n frontend nginx -- curl -m 3 10.244.1.5
    # Works again!


查看和调试
------------

.. code-block:: bash

    # List all NetworkPolicies
    $ kubectl get networkpolicy
    $ kubectl get netpol  # Short form

    # List in all namespaces
    $ kubectl get netpol -A

    # Describe NetworkPolicy
    $ kubectl describe netpol <policy-name>

    # Get YAML
    $ kubectl get netpol <policy-name> -o yaml

    # Delete NetworkPolicy
    $ kubectl delete netpol <policy-name>

**Testing Connectivity:**

.. code-block:: bash

    # Method 1: curl from one pod to another
    $ kubectl exec <source-pod> -- curl -m 5 <target-pod-ip>:<port>

    # Method 2: Use netcat
    $ kubectl exec <source-pod> -- nc -zv <target-pod-ip> <port>

    # Method 3: Deploy debug pod
    $ kubectl run debug --rm -it --image=nicolaka/netshoot -- bash
    # Then test from inside


故障排查
----------

**Issue: Policy Not Working**

.. code-block:: bash

    # 1. Check if CNI supports NetworkPolicy
    $ kubectl get pods -n kube-system | grep -E "calico|cilium|weave"

    # 2. Verify pod labels match policy selector
    $ kubectl get pods --show-labels
    $ kubectl get netpol <policy> -o yaml | grep -A 5 podSelector

    # 3. Check if policy is in correct namespace
    $ kubectl get netpol -A

    # 4. Test with a simple policy first
    # Start with deny-all, then gradually add allow rules

**Issue: DNS Not Working**

When using egress policies, you must explicitly allow DNS:

.. code-block:: yaml

    egress:
    - to:
      - namespaceSelector:
          matchLabels:
            name: kube-system
        podSelector:
          matchLabels:
            k8s-app: kube-dns
      ports:
      - protocol: UDP
        port: 53
      - protocol: TCP
        port: 53

**Issue: Can't Access External Services**

.. code-block:: yaml

    egress:
    - to:
      - ipBlock:
          cidr: 0.0.0.0/0
          except:
          - 169.254.169.254/32  # AWS metadata
      ports:
      - protocol: TCP
        port: 443
      - protocol: TCP
        port: 80

**Debugging Tips:**

1. Start with deny-all policy
2. Add allow rules incrementally
3. Use ``kubectl exec`` to test connectivity
4. Check pod and namespace labels carefully
5. Remember: policies are additive (multiple policies combine with OR logic)


最佳实践
----------

1. **Default Deny, Explicit Allow**
   
   Start with deny-all and explicitly allow required traffic:

   .. code-block:: bash

       kubectl apply -f default-deny-all.yaml
       # Then add specific allow policies

2. **Use Namespace Labels**
   
   Label namespaces for easier policy management:

   .. code-block:: bash

       kubectl label namespace production env=prod
       kubectl label namespace development env=dev

3. **Document Your Policies**
   
   Add clear descriptions in metadata:

   .. code-block:: yaml

       metadata:
         name: allow-frontend-to-backend
         annotations:
           description: "Allows frontend pods to connect to backend on port 8080"

4. **Test Policies in Non-Prod First**
   
   Always test NetworkPolicies in development before applying to production.

5. **Include DNS Egress**
   
   If using egress policies, always allow DNS:

   .. code-block:: yaml

       egress:
       - to:
         - namespaceSelector: {}
           podSelector:
             matchLabels:
               k8s-app: kube-dns
         ports:
         - protocol: UDP
           port: 53

6. **Use Multiple Policies**
   
   Create separate policies for different concerns rather than one complex policy.

7. **Monitor Policy Effects**
   
   Use metrics and logging to monitor policy impacts:

   .. code-block:: bash

       # Check dropped packets (depends on CNI)
       # For Calico:
       kubectl exec -n kube-system <calico-pod> -- calico-node -status

8. **Version Control Your Policies**
   
   Store NetworkPolicies in Git like other Kubernetes resources.


高级主题
----------

**Cilium Network Policies**

Cilium provides extended NetworkPolicy features:

- Layer 7 (HTTP, gRPC) filtering
- DNS-based policies
- Cluster mesh for multi-cluster

**Calico Network Policies**

Calico has its own GlobalNetworkPolicy resource:

- Applies across namespaces
- More powerful selectors
- Host endpoint protection

**Policy Validation**

Use tools to validate policies before applying:

- Network Policy Viewer: https://github.com/runoncloud/network-policy-viewer
- Cilium Editor: https://editor.cilium.io/


实用工具
----------

**Network Policy Recipes:**

https://github.com/ahmetb/kubernetes-network-policy-recipes

Collection of common NetworkPolicy patterns.

**Policy Simulation:**

Test policies before applying:

.. code-block:: bash

    # Use kubectl dry-run
    kubectl apply -f policy.yaml --dry-run=client

**Visualization:**

- Cilium Hubble: Visual network flows
- Weave Scope: Topology and network visualization


参考资料
----------

- Network Policies: https://kubernetes.io/docs/concepts/services-networking/network-policies/
- Network Policy Recipes: https://github.com/ahmetb/kubernetes-network-policy-recipes
- Calico Network Policy: https://docs.tigera.io/calico/latest/network-policy/
- Cilium Network Policy: https://docs.cilium.io/en/stable/policy/
