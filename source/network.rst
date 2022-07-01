Networking
============

https://kubernetes.io/docs/concepts/cluster-administration/networking/


- Highly-coupled container-to-container communications: this is solved by Pods and localhost communications.
- Pod-to-Pod communications: this is the primary focus of this document.
- Pod-to-Service communications: this is covered by services.
- External-to-Service communications: this is covered by services.


Kubernetes Networking Model

- All pods can communicate with wach other on all Nodes
- Agents on a Node can communicate with all pods on that Node
- No Network Address Translation(NAT)

Kubernetes Network Topology

- Node Network
- Pod Network
- Cluster Network (used by Services)


.. toctree::
   :maxdepth: 2
   :caption: Contents:

   network/pod-network
   network/cluster-dns
   network/service
   network/ingress
