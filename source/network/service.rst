Services
=========

- Persistent endpoint access for clients
- Adds persistency to the ephemerality of Pods
- Networking abstration providing persistent virutal IP and DNS
- Load balances to the backend Pods
- Automatically updated during pod controller operations


How Services Work
---------------------

Services match pods using Labels and Selectors

Creates and registers Endpoints in the Service (Pod IP and port pair)

Implemented in the kube-proxy on the Node in iptables

Kube-proxy watches the API Server and Endpoints


Service Types
---------------

ClusterIP(Default), when application deson't need to be accessed by out side of the cluster

NodePort

LoadBalancer

