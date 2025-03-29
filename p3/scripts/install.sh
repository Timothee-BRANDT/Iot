#!/bin/bash

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
echo "INSTALL docker"
wget -qO get-docker.sh https://get.docker.com
sudo sh get-docker.sh

# https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
echo "MANAGE DOCKER AS NON ROOT USER"
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# https://k3d.io/stable/#install-current-latest-release
echo "INSTALL k3d"
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# TODO: untested
echo "INSTALL kubectl"
wget -O kubectl "https://dl.k8s.io/release/$(wget -qO- https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
