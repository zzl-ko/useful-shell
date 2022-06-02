#!/bin/bash

docker_container_name=`docker container ls | awk 'NR>1 && $NF == "u20.04" {print $NF}'`

if [ "u20.04" = "$docker_container_name" ]; then
	echo "docker exec u20.04 ..."
	docker exec -it u20.04 /bin/bash
else
	docker_container_name=`docker container ls -a | awk 'NR>1 && $NF == "u20.04" {print $NF}'`

	if [ "u20.04" = "$docker_container_name" ]; then
		echo "docker start u20.04 ..."
		docker start u20.04
		#docker attach u20.04
		docker exec -it u20.04 /bin/bash
	else
		echo "docker run u20.04 ..."
		docker run --name u20.04 -v /home/$USER:/home/$USER -it --workdir / ubuntu:20.04 /bin/bash
	fi
fi
