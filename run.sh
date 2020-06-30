#!/usr/bin/bash
# Since we will work in the future with ISTIO, I found it correct to use their instructions to prepare the cluster
# They did a good job, we use their labor.
if ! [ -x "$(command -v kubectl)" ]; then
  echo "Installing kubectl..."
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
else
  echo "kubectl is already installed"
  kubectl version
fi


if ! [ -x "$(command -v wdocker)" ]; then
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
  sudo gpasswd -a $USER docker  
  echo "Done Docker" 

else
  echo "docker is already installed"
  docker -v
fi


if ! [ -x "$(command -v minikube)" ]; then
  echo "Installing minikube..."
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
  sudo cp minikube /usr/local/bin/
  # please ensure that you have placed the minikube in the right path so that it can locate when you run with root user
  # sudo cp /usr/local/bin/minikube /usr/bin
  
else
  echo "minikube is already installed"
  sudo minikube version
  
fi

echo "Starting minikube..."
echo "Configuring minikube..."
minikube config set vm-driver docker
minikube start --memory=6384 --cpus=2
kubectl get pods








# Install Docker
# install kubectl
# curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# grep -E --color 'vmx|svm' /proc/cpuinfo
#sudo apt install docker.io
#sudo systemctl start docker
#sudo systemctl enable docker
#docker --versionu
#curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
#  && chmod +x minikube
#sudo mkdir -p /usr/local/bin/
#sudo install minikube /usr/local/bin/
# for NONE driver 
# please ensure that you have placed the minikube in the right path so that it can locate when you run with root user
#sudo cp /usr/local/bin/minikube /usr/bin
#minikube version
# virtualbox none
#minikube config set driver docker
#sudo minikube start --memory=6384 --cpus=2 --kubernetes-version=v1.17.5

#minikube start --vm-driver=none solves the issue

#sudo cp /usr/local/bin/minikube /usr/bin


#Suggestion: For non-root usage, try the newer 'docker' driver  