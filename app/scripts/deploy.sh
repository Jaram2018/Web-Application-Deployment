#!/bin/bash

GIT_FOLDER=/home/ec2-user/Web-Application-Deployment/
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

echo "> Check 'pid' of the current operating application"
CURRENT_PID=$(pgrep -f web-application-deployment)
echo "$CURRENT_PID"

if [ -z ${CURRENT_PID} ]; then
	echo "> There is no operating app."
else
	echo "> kill -15 $CURRENT_PID"
	kill -15 ${CURRENT_PID}
	sleep 5
fi

JAR_NAME=$(ls ${JAR_PATH}/ |grep 'web-application-deployment' | tail -n 1)
echo "> JAR name : $JAR_NAME"

echo "> Deploy new application"
nohup java -jar ${JAR_PATH}/${JAR_NAME} &