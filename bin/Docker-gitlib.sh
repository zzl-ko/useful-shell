#!/bin/bash

GITLAB_HOME="$HOME/gitlab"

function docker_gitlab_start() {
docker_container_name=`docker container ls | awk 'NR>1 && $NF == "gitlab" {print $NF}'`

if [ "gitlab" = "$docker_container_name" ]; then
	echo "docker exec gitlab ..."
	docker exec -it gitlab /bin/bash
else
	docker_container_name=`docker container ls -a | awk 'NR>1 && $NF == "gitlab" {print $NF}'`

	if [ "gitlab" = "$docker_container_name" ]; then
		echo "docker start gitlab ..."
		docker start gitlab
		#docker attach gitlab
		docker exec -it gitlab /bin/bash
	else
		echo "docker run gitlab ..."
		docker run -d -it --name gitlab \
		-p 443:443 -p 8080:80 -p 222:22 \
		-v $GITLAB_HOME/config:/etc/gitlab \
		-v $GITLAB_HOME/logs:/var/log/gitlab \
		-v $GITLAB_HOME/data:/var/opt/gitlab \
		gitlab/gitlab-ce /bin/bash
	fi
fi

# ref https://www.zhihu.com/question/276485274/answer/1013996168
# docker exec  : Run a command in a running container,翻译过来就是在一个正在运行的容器中执行命令，exec是针对已运行的容器实例进行操作，在已运行的容器中执行命令，不创建和启动新的容器，退出shell不会导致容器停止运行。
# docker attach: Attach local standard input, output, and error streams to a running container，翻译过来，将本机的标准输入（键盘）、标准输出（屏幕）、错误输出（屏幕）附加到一个运行的容器，也就是说本机的输入直接输到容器中，容器的输出会直接显示在本机的屏幕上，如果退出容器的shell，容器会停止运行。
}

function docker_install_config() {
	# 0. 安装必要的依赖软件，来添加一个新的 HTTPS 软件源
	sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	# 1. 添加 Docker 的官方 GPG 密钥
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	# 2. 将 Docker APT 软件源添加到你的系统
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	# 3. 安装docker最新版本
	sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io
	# 4. 以非 Root 用户身份执行 Docker（可能需要重启docker,甚至重启PC才能生效）
	sudo usermod -aG docker $USER
	# 5. 如果你想阻止 Docker 自动更新，锁住它的版本
	sudo apt-mark hold docker-ce
	
	echo "You may need to restart the computer!"
}

function main() {
	type docker >/dev/null 2>&1

	if [ $? -ne 0 ]; then
		echo "docker not installed. if you want to install?(y/n)"
		read -t 5 ans
		[ "$ans" != "y" ] && exit 1
		docker_install_configls
	fi
	
	docker_gitlab_start
}

main

