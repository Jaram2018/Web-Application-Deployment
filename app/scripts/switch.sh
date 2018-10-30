#!/bin/bash

CURRENT_PROFILE=$(curl -s http://localhost/profile)  # Nginx 로 현재 작동중인 app 의 profile 확인
echo "> Check current profile : ${CURRENT_PROFILE}"

# 사용하지 않는 set 을 찾는다
if [ ${CURRENT_PROFILE} == set1 ]  # 만약 profile 이 set1 일 경우 -> port = 9082 로 설정
then
    IDLE_PORT=9082
elif [ ${CURRENT_PROFILE} == set2 ]  # 만약 profile 이 set2 일 경우 -> port = 9081 로 설정
then
    IDLE_PORT=9081
else  # 아무 profile 도 설정되지 않았을 경우 -> port = 9081 로 설정
    echo "> There is no matched profile (Profile : ${CURRENT_PROFILE})"
    echo "> Allocated to 9081"
    IDLE_PORT=9081
fi

echo "> Switching the port to : ${IDLE_PORT}"
echo "> Switching ..."
# /etc/nginx/conf.d/service-url.inc 의 내용을 "set $service_url http://127.0.0.1:${IDLE_PORT};" 로 변경
echo "set \$service_url http://127.0.0.1:${IDLE_PORT};" | sudo tee /etc/nginx/conf.d/service-url.inc


echo "> Reload 'Nginx'"
sudo service nginx reload  # Nginx reload

sleep 1

NEW_PROFILE=$(curl -s http://localhost/profile)  # 변경된 현재 profile 확인
echo "> Current proxy port in 'Nginx' : ${NEW_PROFILE}"