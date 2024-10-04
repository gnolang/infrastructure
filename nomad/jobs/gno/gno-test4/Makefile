
.PHONY: all gnoval1 gnoval2 gnoval3 gnoval4 gnorpc01

all: gnoval1 gnoval2 gnoval3 gnoval4 gnorpc01

gnoval1:
	rsync -av ./docker-compose.yml  devops@103.219.168.237:/home/devops/
	rsync -av ./gnoval1/ devops@103.219.168.237:/home/devops/gnoland-data

gnoval2:
	rsync -av ./docker-compose.yml  devops@72.46.84.19:/home/devops/
	rsync -av ./gnoval2/ devops@72.46.84.19:/home/devops/gnoland-data

gnoval3:
	rsync -av ./docker-compose.yml devops@186.233.184.76:/home/devops/
	rsync -av ./gnoval3/ devops@186.233.184.76:/home/devops/gnoland-data

gnoval4:
	rsync -av ./docker-compose.yml devops@103.14.26.13:/home/devops/
	rsync -av ./gnoval4/ devops@103.14.26.13:/home/devops/gnoland-data

gnorpc01:
	rsync -av ./gnorpc01/gnoland-data devops@69.67.150.82:/home/devops/
