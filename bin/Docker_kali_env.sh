#!/bin/bash
# refer: https://www.kali.org/news/official-kali-linux-docker-images/

dcn="Kali"
docker_container_name=`docker container ls | awk 'NR>1 && $NF == "'"$dcn"'" {print $NF}'`

if [ "$dcn" = "$docker_container_name" ]; then
	echo "docker exec $dcn ..."
	docker exec -it ${dcn} /bin/bash
else
	docker_container_name=`docker container ls -a | awk 'NR>1 && $NF == "'"$dcn"'" {print $NF}'`

	if [ "$dcn" = "$docker_container_name" ]; then
		echo "docker start $dcn ..."
		docker start ${dcn}
		#docker attach $dcn
		docker exec -it $dcn /bin/bash
	else
		echo "docker run $dcn ..."
		#docker 的四种网络模式(https://www.jianshu.com/p/22a7032bb7bd)
		docker run --name ${dcn} -v /home/$USER:/home/$USER -it --net=host --workdir / kalilinux/kali-rolling /bin/bash

		# 1. 更新国内镜像源
		#中科大
		#deb http://mirrors.ustc.edu.cn/kali kali-rolling main non-free contrib
		#deb-src http://mirrors.ustc.edu.cn/kali kali-rolling main non-free contrib
		#阿里云
		#deb http://mirrors.aliyun.com/kali kali-rolling main non-free contrib
		#deb-src http://mirrors.aliyun.com/kali kali-rolling main non-free contrib
		#清华大学
		#deb http://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free
		#deb-src https://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free
		#浙大
		#deb http://mirrors.zju.edu.cn/kali kali-rolling main contrib non-free
		#deb-src http://mirrors.zju.edu.cn/kali kali-rolling main contrib non-free
		#东软大学
		#deb http://mirrors.neusoft.edu.cn/kali kali-rolling/main non-free contrib
		#deb-src http://mirrors.neusoft.edu.cn/kali kali-rolling/main non-free contrib
		#官方源
		#deb http://http.kali.org/kali kali-rolling main non-free contrib
		#deb-src http://http.kali.org/kali kali-rolling main non-free contrib

		# 2. 安装相关软件包
		#https://www.kali.org/news/official-kali-linux-docker-images/
		#apt-get update && apt-get install metasploit-framework
		#apt install realtek-rtl88xxau-dkms aircrack-ng net-tools pciutils
		#apt install bash-completion

		#ref: http://pkg.kali.org/pkg/realtek-rtl88xxau-dkms#
	fi
fi
