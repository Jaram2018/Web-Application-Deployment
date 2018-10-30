#!/bin/bash
# jenkins 에서 배포 시 자동으로 실행시킬 script 파일 (git directory 외부에 위치시켜야 함)
/home/ec2-user/Web-Application-Deployment/app/scripts/final_deploy.sh > /dev/null 2> /dev/null < /dev/null &

################################################
# < jenkins 의 Build 에 들어갈 내용 >

## 만약 deploy 를 테스트할 경우 아래 'run.sh' 을 주석처리 하고, 이 부분을 주석해제 한다.
##SCRIPT_FOLDER=/home/ec2-user/Web-Application-Deployment/app/scripts
##sudo ${SCRIPT_FOLDER}/CD.sh
#
#sudo /home/ec2-user/run.sh
#
#echo "> Build Success"