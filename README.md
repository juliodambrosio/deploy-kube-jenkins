# Projeto de Deploy Automatizado com Kubernetes e Jenkins

### Descrição
Este projeto tem como objetivo criar um ambiente automatizado para deploy de aplicações utilizando Kubernetes e Jenkins. 

A aplicação utilizada foi [Conversão Temperatura](https://github.com/KubeDev/conversao-temperatura/). Desenvolvido por [KubeDev](https://github.com/KubeDev)

### Estrutura do Projeto


|-- vagrant/        # Arquivos do Vagrant para criar as VMs

|-- k8s/            # Manifest do Kubernetes 

|-- src/            # Código-fonte da aplicação

|-- Dockerfile      # Configuração do container da aplicação

|-- Jenkinsfile     # Pipeline do Jenkins


### Como Configurar
Entre em cada pasta do vagrant e execute: 

```bash
vagrant up
```
Execute o código em cada uma das VMs criadas para o cluster Kubernetes: 

```bash
#!/bin/bash

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter 

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

sudo apt-get update && sudo apt-get install -y apt-transport-https curl

sudo mkdir /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update && sudo apt-get install -y containerd.io

sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl status containerd

sudo systemctl enable --now kubelet
```

Instale o Jenkins na outra VM seguindo a documentação: https://www.jenkins.io/doc/book/installing/linux/#debianubuntu

Além do Jenkins, é necessário instalar o: 

- Docker
- kubectl

Configure o Jenkins acessando: http://localhost:8080

Depois de configurado, instale as seguintes extensões dentro do Jenkins:

- Docker
- Docker Pipeline
- Kubernetes CLI

clique em "Criar nova Tarefa" e selecione *pipeline*. 

Em seguida, procure por *Pipeline* e aplique as seguintes configurações: 

- Definição : Pipeline script from SCM
- SCM: Git
- Repositório: https://github.com/juliodambrosio/deploy-kube-jenkins.git
- Credencial: Coloque se o repositório for privado.
- Branches: */main
- Script Path: Jenkinsfile.

Em *Triggers*, habilite a opção *Consultar periodicamente o SCM* e coloque o valor: 

```bash
H/3 * * * *
```
Com essa configuração aplicada, o Jenkins vai verificar se o repositório foi alterado a cada 3 minutos. Se foi alterado,  vai executar o deploy automaticamente.

Tudo aplicado, clique em *Salvar*.

OBS: No Jenkinsfile, precisa cadastrar duas variáveis de ambiente: 

- dockerhub: suas credenciais de acesso do Docker Hub;
- kubeconfig: Arquivo de configuração do kubectl para executar o deploy.

Sem essas variáveis, o deploy não vai funcionar.

