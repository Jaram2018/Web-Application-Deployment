#!/bin/bash

APP_FOLDER=/home/ec2-user/app
REPOSITORY=$APP_FOLDER/git
echo "APP_FOLDER : $APP_FOLDER"
echo "REPOSITORY : $REPOSITORY"

cd $REPOSITORY/Web-Application-Deployment

#!/bin/bash
echo "> Git Pull"
git pull

echo "> Start project build"
./gradlew build

echo "> Copy build file"
cp ./build/libs/*.jar $APP_FOLDER/

echo "> Check 'pid' of the current operating application"
CURRENT_PID=$(pgrep -f web-application-deployment)
echo "$CURRENT_PID"

if [ -z $CURRENT_PID ]; then
	echo "> There is no operating app."
else
	echo "> kill -2 $CURRENT_PID"
	kill -2 $CURRENT_PID
	sleep 10
fi

JAR_NAME=$(ls $APP_FOLDER/ |grep 'web-application-deployment' | tail -n 1)
echo "> JAR name : $JAR_NAME"

echo "> Deploy new application"
nohup java -jar $APP_FOLDER/$JAR_NAME &