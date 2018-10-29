#!/bin/bash

GIT_FOLDER=/home/ec2-user/Web-Application-Deployment
APP_FOLDER=${GIT_FOLDER}/app
REPOSITORY=${APP_FOLDER}/web-application-deployment
JAR_PATH=${APP_FOLDER}/jar

echo "APP_FOLDER : $APP_FOLDER"
echo "REPOSITORY : $REPOSITORY"

cd /home/ec2-user/Web-Application-Deployment/

echo "> Git Pull"
git pull

cd ${REPOSITORY}

echo "> Start project build"
./gradlew build

echo "> Copy build file"
cp ./build/libs/*.jar ${JAR_PATH}/

#echo "> Check 'pid' of the current operating application"
#CURRENT_PID=$(pgrep -f web-application-deployment)
#echo "$CURRENT_PID"
#
#if [ -z ${CURRENT_PID} ]; then
#	echo "> There is no operating app."
#else
#	echo "> kill -15 $CURRENT_PID"
#	kill -15 ${CURRENT_PID}
#	sleep 5
#fi

JAR_NAME=$(ls ${JAR_PATH}/ |grep 'web-application-deployment' | tail -n 1)
echo "> JAR name : $JAR_NAME"

############################################################################

echo "> Start nonstop process ... "

GIT_PATH=/home/ec2-user/Web-Application-Deployment
APP_PATH=${GIT_PATH}/app
SCRIPTS_PATH=${APP_PATH}/scripts
CONFIG_PATH=${APP_PATH}/config
SOURCE_PATH=${APP_PATH}/web-application-deployment
BUILD_PATH=$(ls ${SOURCE_PATH}/build/libs/*.jar)

JAR_NAME=$(basename ${BUILD_PATH})  # basename : 파일 명 추출
echo "> The name of file in build : ${JAR_NAME}"

echo "> Copy the build file"
DEPLOY_PATH=${APP_PATH}/jar/
cp ${BUILD_PATH} ${DEPLOY_PATH}

CURRENT_PROFILE=$(curl -s http://localhost/profile)
echo "> Current profile : ${CURRENT_PROFILE}"

# 작동 안하는 profile 찾기
if [ ${CURRENT_PROFILE} == set1 ]
then
    IDLE_PROFILE=set2
    IDLE_PORT=9082
elif [ ${CURRENT_PROFILE} == set2 ]
then
    IDLE_PROFILE=set1
    IDLE_PORT=9081
else
    echo "> There is no matched profile (Profile : ${CURRENT_PROFILE})"
    echo "> Let's set 'set1'"
    IDLE_PROFILE=set1
    IDLE_PORT=9081
fi

echo "> Exchange 'application.jar'"
IDLE_APPLICATION=${IDLE_PROFILE}-web-application-deployment
IDLE_APPLICATION_PATH=${DEPLOY_PATH}${IDLE_APPLICATION}

ln -Tfs ${DEPLOY_PATH}${JAR_NAME} ${IDLE_APPLICATION_PATH}  # 앞에 profile 접두어 붙이고 신규 jar 심볼릭 링크

echo "> Check the 'pid' of operating application in ${IDLE_PROFILE}"
IDLE_PID=$(pgrep -f ${IDLE_APPLICATION})

if [ -z ${IDLE_PID} ]
then
    echo "> There is no current operating application"
else
    echo "> kill -15 ${IDLE_PID}"
    kill -15 ${IDLE_PID}
    sleep 5
fi

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

############################################################################

echo "> Switching !!"
sleep 10

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