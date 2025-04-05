## Довольно простой способ как развернуть необходимые приложения в кубере

Основные приемущества данного варианта, сборка обоих приложений происходит автоматически (не надо устанавливать gradle, idea).
Все реализовано средствами docker

Я использовал следующий дистрибутив: **24.04.2 LTS (Noble Numbat)**

Из того что нам понадобится поставить:
 - docker
 - microk8s
 - postman

### Установка Docker

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```


```bash
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable --now docker
```

***Перезаходим в профиль***


Проверим что докер работает корректно и запустим Hello world
```bash
docker run hello-world
```

на экране должно отобразиться:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

### Установка microk8s

```bash
sudo snap install microk8s --classic

sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
su - $USER

microk8s status --wait-ready

echo "alias kubectl='microk8s kubectl" >  ~/.bash_aliases
echo "alias kc='microk8s kubectl" >>  ~/.bash_aliases

exec /bin/bash

kc get all --all-namespaces

microk8s enable dashboard dns
```

## Переходим непосредственно к сборке приложения и контейнеров

Делаем клон репозитория:

```bash 
git clone https://github.com/StupidFraid/urfu-java.git

cd urfu-java
```

Собираем контейнеры и запускаем их в microk8s

```bash
docker build twitter/. -t urfu-twitter
docker build ums/. -t urfu-ums
docker build . -t urfu-mysql

docker save urfu-ums:latest -o ./docker-image/urfu-ums.tar
docker save urfu-twitter:latest -o ./docker-image/urfu-twitter.tar
docker save urfu-mysql:latest -o ./docker-image/urfu-mysql.tar

kc apply -f deployment/mysql_deployment.yml 
kc apply -f deployment/ums_deployment.yml
kc apply -f deployment/twitter_deployment.yml


kc  apply -f deployment/hpa_twitter_deployment.yml 
kc  apply -f deployment/hpa_ums_deployment.yml 
```

проверяем что все запустилось:

```
kc get all --all-namespaces



```
