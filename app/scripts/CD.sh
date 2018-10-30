#!/bin/bash

# 각 directory path 지정
GIT_FOLDER=/home/ec2-user/Web-Application-Deployment
APP_FOLDER=${GIT_FOLDER}/app
REPOSITORY=${APP_FOLDER}/web-application-deployment
JAR_PATH=${APP_FOLDER}/jar

echo "APP_FOLDER : $APP_FOLDER"
echo "REPOSITORY : $REPOSITORY"

cd /home/ec2-user/Web-Application-Deployment/

echo "> Git Pull"
git pull  # git 의 최신 repo 를 pull

cd ${REPOSITORY}

echo "> Start project build"
./gradlew build  # Spring Boot 빌드 (아마, 실행을 위해서 755 등의 권한 설정을 해줘야 함)

echo "> Copy build file"
cp ./build/libs/*.jar ${JAR_PATH}/  # build 된 파일을 jar 폴더에 모음

echo "> Check 'pid' of the current operating application"
CURRENT_PID=$(pgrep -f web-application-deployment)  # 이미 실행중인 app 이 있을 경우, 그 pid 를 변수화
echo "$CURRENT_PID"

if [ -z ${CURRENT_PID} ]  # 만약 실행중인 app 이 없을 경우 넘어감
then
	echo "> There is no operating app."
else  # 실행중인 app 이 있을 경우 그것을 kill
	echo "> kill -15 $CURRENT_PID"
	kill -15 ${CURRENT_PID}
	sleep 5
fi

JAR_NAME=$(ls ${JAR_PATH}/ |grep 'web-application-deployment' | tail -n 1)  # app 을 실행시킬 최신 app(jar 파일) 이름을 변수화
echo "> JAR name : $JAR_NAME"

echo "> Deploy new application"
nohup java -jar ${JAR_PATH}/${JAR_NAME} &  # nuhup 으로 app 을 background process 로 실행