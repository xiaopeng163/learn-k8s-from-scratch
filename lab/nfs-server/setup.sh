#!/bin/bash

# install NFS server and create directory for our exports

sudo apt-get install -y nfs-kernel-server
sudo mkdir -p /export/volumes
sudo mkdir -p /export/volumes/pod

# config NFS export

sudo bash -c 'echo "/export/volumes *(rw,no_root_squash,no_subtree_check)" > /etc/exports'
cat /etc/exports
sudo systemctl restart nfs-kernel-server.service
