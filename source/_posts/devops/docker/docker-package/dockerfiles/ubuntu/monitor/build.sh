docker rmi --force `docker images | grep ubuntu | awk '{print $3}'`

docker build -t monitor:1.0 .

#docker tag ubuntu-base:18.0401 10.10.208.193:5000/ubuntu-base:18.0401
#
#docker push 10.10.208.193:5000/ubuntu-base:18.0401



