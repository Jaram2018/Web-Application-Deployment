#!/bin/bash

# 각 directory path 지정
GIT_PATH=/home/ec2-user/Web-Application-Deployment
APP_PATH=${GIT_PATH}/app
SCRIPTS_PATH=${APP_PATH}/scripts
CONFIG_PATH=${APP_PATH}/config
SOURCE_PATH=${APP_PATH}/web-application-deployment
BUILD_PATH=$(ls ${SOURCE_PATH}/build/libs/*.jar)

JAR_NAME=$(basename ${BUILD_PATH})  # basename 으로 파일 명 추출
echo "> The name of file in build : ${JAR_NAME}"

echo "> Copy the build file"
DEPLOY_PATH=${APP_PATH}/jar/  # jar 파일을 모아둔 곳의 path
cp ${BUILD_PATH} ${DEPLOY_PATH}  # Spring Boot 의 jar 파일이 있는 directory 를 DEPLOY_PATH 에 복사

CURRENT_PROFILE=$(curl -s http://localhost/profile)  # Nginx 에 설정된 현재 app 의 profile 확인
echo "> Current profile : ${CURRENT_PROFILE}"

# 작동 안하는 profile 찾기
if [ ${CURRENT_PROFILE} == set1 ]  # 만약 set1 이 작동 중일 경우 -> profile = set2 / port = 9082 로 설정
then
    IDLE_PROFILE=set2
    IDLE_PORT=9082
elif [ ${CURRENT_PROFILE} == set2 ]  # 만약 set2 가 작동 중일 경우 -> profile = set1 / port = 9081 로 설정
then
    IDLE_PROFILE=set1
    IDLE_PORT=9081
else  # 만약 어떤 profile 도 아닐 경우 (아마 최초 run 일 때) -> profile = set1 / port = 9081 로 설정
    echo "> There is no matched profile (Profile : ${CURRENT_PROFILE})"
    echo "> Let's set 'set1'"
    IDLE_PROFILE=set1
    IDLE_PORT=9081
fi

echo "> Exchange 'application.jar'"
IDLE_APPLICATION=${IDLE_PROFILE}-web-application-deployment  # profile-app명.jar 로 새 명명
IDLE_APPLICATION_PATH=${DEPLOY_PATH}${IDLE_APPLICATION}  # 새 명명된 파일의 절대경로

ln -Tfs ${DEPLOY_PATH}${JAR_NAME} ${IDLE_APPLICATION_PATH}  # 새로 명명된 파일의 jar 심볼릭 링크

echo "> Check the 'pid' of operating application in ${IDLE_PROFILE}"
IDLE_PID=$(pgrep -f ${IDLE_APPLICATION})  # 배정받은 profile 로 현재 작동중인 app 의 pid 확인

if [ -z ${IDLE_PID} ]  # 만약 작동중이 아니라면 넘어감 (아마 그 profile 의 최초 run)
then
    echo "> There is no current operating application"
else  # 만약 작동중이라면 그것을 kill
    echo "> kill -15 ${IDLE_PID}"
    kill -15 ${IDLE_PID}
    sleep 5
fi

# 새로 설정한 profile 의 환경변수로 app 가동
echo "> Deploy the ${IDLE_PROFILE} ..."
nohup java -jar -Dspring.profiles.active=${IDLE_PROFILE} ${IDLE_APPLICATION_PATH} &

#echo "> Starting 'Health Check' after 10s on ${IDLE_PROFILE}"
#echo "> curl -s http://localhost:${IDLE_PORT}/actuator/health"
sleep 10

#for count in {1...10}
#do
#    response=$(curl -s http://localhost:${IDLE_PORT}/actuator/health)
#    up_count=$(echo ${response} | grep 'UP' | wc -l)
#
#    if [ ${up_count} -ge 1 ]
#    then
#        echo "> Success 'Health Check'"
#        break
#    else
#        echo "> Unknown the response of 'Health Check' or there isn't 'UP' state"
#        echo "> Health check: ${response}"
#    fi
#
#    if [ ${count} -eq 10 ]
#    then
#        echo "> Failed 'Health check'"
#        echo "> Exit the deployment without connecting 'Nginx'"
#        exit 1
#    fi
#
#    echo "> Failed 'Health Check' - Reconnecting ..."
#    sleep 10
#done