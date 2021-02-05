#!/bin/bash
# refer: https://www.kali.org/news/official-kali-linux-docker-images/

docker_container_name=`docker container ls | awk 'NR>1 && $NF == "kali" {print $NF}'`

if [ "kali" = "$docker_container_name" ]; then
	echo "docker exec kali ..."
	docker exec -it kali /bin/bash
else
	docker_container_name=`docker container ls -a | awk 'NR>1 && $NF == "kali" {print $NF}'`

	if [ "kali" = "$docker_container_name" ]; then
		echo "docker start kali ..."
		docker start kali
		#docker attach kali
		docker exec -it kali /bin/bash
	else
		echo "docker run kali ..."
		docker run --name kali -v /home/$USER:/home/$USER -it --workdir / kalilinux/kali-rolling /bin/bash
	fi
fi
