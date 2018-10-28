#!/bin/bash

echo "> Check current operating port"

CURRENT_PROFILE=$(curl -s http://localhost/profile)

# 사용하지 않는 set 을 찾는다
if [ ${CURRENT_PROFILE} == set1 ]
then
    IDLE_PORT=9082
elif [ ${CURRENT_PROFILE} == set2 ]
then
    IDLE_PORT=9081
else
    echo "> There is no matched profile (Profile : ${CURRENT_PROFILE})"
    echo "> Allocated to 9081"
    IDLE_PORT=9081
fi

echo "> Switching the port to : ${IDLE_PORT}"
echo "> Switching ..."
echo "set \$service_url http://127.0.0.1:${IDLE_PORT};" | sudo tee /etc/nginx/conf.d/service-url.inc

PROXY_PORT=$(curl -s http://localhost/profile)
echo "> Current proxy port in 'Nginx' : ${PROXY_PORT}"

echo "> Reload 'Nginx'"
sudo service nginx reload