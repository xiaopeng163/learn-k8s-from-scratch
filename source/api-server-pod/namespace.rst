Namespace
===================


kubectl get namespaces 

# get list of all api resources and if they can/not be namespaced
kubectl api-resources --namesapced=true | head
kubectl api-resources --namespaced=false | head

kubectl describe namespaces

kubectl get pods --all-namespaces

# get all resources all
kubectl get all --all-namespaces


kubectl create namespace playground1

kubectl create namespace Playground1   # will be error


apiVersion: v1
kind: Namespace
matadata:
  name: playground1

