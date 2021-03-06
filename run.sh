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
minikube start --memory=6384 --cpus=3
kubectl get pods

echo "Download and install Istio..."
curl -sL https://istio.io/downloadIstio | ISTIO_VERSION=1.6.4 sh -
cd istio*
export PATH="$PATH:$(pwd)/bin"
istioctl install --set profile=demo
echo "Adding a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later"
kubectl label namespace default istio-injection=enabled
echo "Print ISTIO status"
kubectl get --namespace=istio-system svc,deployment,pods,job,horizontalpodautoscaler,destinationrule
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl get pods
echo "wait for start pods"
kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=300s
kubectl get pods
echo "sleep 10"
sleep 10
kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
istioctl analyze
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
echo INGRESS_PORT: $INGRESS_PORT
echo SECURE_INGRESS_PORT: $SECURE_INGRESS_PORT
export INGRESS_HOST=$(minikube ip)
echo INGRESS_HOST: $INGRESS_HOST
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo GATEWAY_URL: GATEWAY_URL
echo MAIL_SITE_URL: http://$GATEWAY_URL/productpage

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
echo INGRESS_PORT: $INGRESS_PORT
echo SECURE_INGRESS_PORT: $SECURE_INGRESS_PORT
export INGRESS_HOST=$(minikube ip)
echo INGRESS_HOST: $INGRESS_HOST
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo GATEWAY_URL: GATEWAY_URL
echo MAIN_SITE_URL: http://$GATEWAY_URL/productpage

# set envs for tests
productpag_answer=$(curl http://$GATEWAY_URL/productpage | grep -o "<title>.*</title>")
status_code=$(curl -o /dev/null -s -w "%{http_code}" http://$GATEWAY_URL/productpage; echo)

echo "productpage - the productpage microservice calls the details and reviews microservices to populate the page."
echo "details - the details microservice contains book information."
echo "reviews - the reviews microservice contains book reviews. It also calls the ratings microservice."
echo "ratings - the ratings microservice contains book ranking information that accompanies a book"
echo "There are 3 versions of the reviews microservice:"
echo "Version v1 - doesn't call the ratings service"
echo "Version v2 - calls the ratings service, and displays each rating as 1 to 5 black stars."
echo "Version v3 - calls the ratings service, and displays each rating as 1 to 5 red stars."
echo
echo "Print env info"

kubectl get svc,deployment,pods -o wide 

echo "Test Bookinfo Application"
echo "...."
echo "......."
echo ".........."
echo "Test status code of main url..."
if [[ $status_code == 200 ]]; then
  echo "main url  status code is: "$status_code"  ......"
  echo "main url status code Test Passed OK."
else
  echo "Problem main url not passed, wrong status: "$status_code""
fi

echo "Test content of main url page..."
if [[ $productpag_answer == *"<title>Simple Bookstore App</title>"* ]]; then
  echo "main url test answer is "$productpag_answer"  ......"
  echo "main url Test Passed OK. "
else
  echo "Problem main url not passed, wrong answer "$productpag_answer""
fi

echo "Test mail url performance score"
sudo apt-get install apache2-utils -y
ab -c 10 -n 100 http://$GATEWAY_URL/productpage

sudo apt install siege -y
siege --log=/tmp/siege --concurrent=1 -q --internet --time=1M http://$GATEWAY_URL/productpage
cat /tmp/siege





