# This script installs k8s cluster using kubeadm and kubectl.

# This script is used to install the necessary packages and configure the VM for the installation of the kubneretes cluster.

# The script is executed on the VM that will be used as the Kubernetes master node. 
# It assumes Docker and apt-transport-https ca-certificates curl software-properties-common are already installed, firewall is configured, and the user has sudo privileges.


# Install Kubeadm & Kubelet & Kubectl on all Nodes

# Add the Kubernetes GPG key
KUBERNETES_VERSION=1.29


sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y

sudo apt-get install -y kubelet kubeadm kubectl

# freeze the version of the packages
sudo apt-mark hold kubelet kubeadm kubectl

# Start and enable the kubelet service

sudo systemctl enable kubelet
sudo systemctl start kubelet

# Initialize the Kubernetes cluster
sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR --node-name $NODENAME --ignore-preflight-errors Swap

# Configure kubectl for the new user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# token for joining the cluster
kubeadm token create --print-join-command > /tmp/join-command.sh

# Install the Calico network plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
