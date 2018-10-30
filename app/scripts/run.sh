#!/bin/bash
# jenkins 에서 배포 시 자동으로 실행시킬 script 파일 (git directory 외부에 위치시켜야 하며, path 는 달라질 수 있음)
/home/ec2-user/scripts/final_deploy.sh > /dev/null 2> /dev/null < /dev/null &

################################################
# < jenkins 의 Build 에 들어갈 내용 >

## 만약 deploy 를 테스트할 경우 아래 'run.sh' 을 주석처리 하고, 이 부분을 주석해제 한다.
##sudo /home/ec2-user/scripts/CD.sh
#
#sudo /home/ec2-user/scripts/run.sh
#
#echo "> Build Success"