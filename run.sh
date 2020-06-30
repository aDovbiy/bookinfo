#!/bin/bash
# Since we will work in the future with ISTIO, I found it correct to use their instructions to prepare the cluster
# They did a good job, we use their labor.
#


if ! [ -x "$(command -v kubectl)" ]; then
  echo "Installing kubectl..."
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
else
  echo "kubectl is already installed"
  kubectl version
fi


if ! [ -x "$(command -v docker)" ]; then
  echo "Installing docker..."
  sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common 
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce
  sudo systemctl enable docker
  sudo groupadd docker
  sudo usermod -aG docker $USER
  echo "https://docs.docker.com/engine/install/linux-postinstall/"
  echo "Please reboot VM. This step need onli one time for run Docker as non root user"
  echo "If you not ready for reboot, simple type 'exit', script will be to continue, but docker now will be run as not root user"
  sudo newgrp docker
  echo "Done Docker" 
else
  echo "docker is already installed"
  docker -v
fi


if ! [ -x "$(command -v minikube)" ]; then
  echo "Installing minikube..."
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x minikube
  sudo cp minikube /usr/local/bin/
else
  echo "minikube is already installed"
  sudo minikube version
fi

echo "Starting minikube..."
echo "Configuring minikube..."
minikube config set vm-driver docker
minikube start --memory=6384 --cpus=2
kubectl get pods