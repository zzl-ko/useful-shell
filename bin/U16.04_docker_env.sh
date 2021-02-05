#!/bin/bash

docker_container_name=`docker container ls | awk 'NR>1 && $NF == "u16.04" {print $NF}'`

if [ "u16.04" = "$docker_container_name" ]; then
	echo "docker exec u16.04 ..."
	docker exec -it u16.04 /bin/bash
else
	docker_container_name=`docker container ls -a | awk 'NR>1 && $NF == "u16.04" {print $NF}'`

	if [ "u16.04" = "$docker_container_name" ]; then
		echo "docker start u16.04 ..."
		docker start u16.04
		#docker attach u16.04
		docker exec -it u16.04 /bin/bash
	else
		echo "docker run u16.04 ..."
		docker run --name u16.04 -v /home/$USER:/home/$USER -it --workdir / ubuntu:16.04 /bin/bash
	fi
fi
