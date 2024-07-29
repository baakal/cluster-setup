
# This script is used to install the necessary packages and configure the VM for the installation of the RKE kubneretes cluster.
# The script is executed on the VM that will be used as the Kubernetes master node.
# This script will setup a new user with sudo privileges, install the necessary packages, and configure the firewall.

# This script will use ssh to connect to the VM

# The script will be executed by an Ansible playbook which will pass the necessary parameters to the script.

# exchange the key with the master node
# parameters
# $1: username
# $2: password
# $3: username of the master node
# $4: ip address of the master node

## 1. Create a new user with sudo privileges

sudo useradd -m -s /bin/bash $1
echo "$1:$2" | sudo chpasswd
sudo usermod -aG sudo $1

## 2. Exchange the key with the master node

ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-copy-id $3@$4


## 3. Install the necessary packages

sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

sudo apt-get install -y epel-release python3 python3-pip policycoreutils-python-utils

## 4. Install Docker engine
### 4.1. Add the Docker GPG key

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

### 4.2. Install Docker packages for k8 nodes

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

### 4.3. Start and enable the Docker service

sudo systemctl start docker

sudo systemctl enable docker

## 5. Finalize the configuration

### 5.1. Disable the swap memory

sudo swapoff -a

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

### 5.2. Configure the firewall

sudo ufw allow OpenSSH

sudo ufw allow 6443/tcp

sudo ufw allow 2379:2380/tcp

sudo ufw allow 10250:10252/tcp

sudo ufw allow 30000:32767/tcp

sudo ufw --force enable



