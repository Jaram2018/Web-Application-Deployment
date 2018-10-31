# [ Jaram 2018 Seminar ]
# > DevOps 를 지향하는 배포 (CI & CD & ZDD)
##  33기 정병길

![diagram](https://github.com/ByeongGil-Jung/Web-Application-Deployment/blob/master/github/diagram.png)  
(원본 출처 : https://jojoldu.tistory.com/267?category=635883)

## 1. CI & CD & ZDD
- CI : Continuous Integration (지속적 통합)
- CD : Continuous Deployment (지속적 배포)  
(`app/scripts/CD.sh`)
- ZDD : Zero-Downtime Deployment (무중단 배포)  
(`app/scripts/ZDD.sh`)

## 2. 각 폴더별 설명
- **web-application-deployment**  
: tomcat 이 들어있는 web app 의 source directory
- **config**  
: web app(Spring Boot) 의 외부 환경변수 설정(.yml) 을 모아 둔 directory
- **jar**  
: web app 을 실행시킬 jar 파일들을 모아 둔 directory
- **scripts**  
: CI & CD & DZZ 를 실행시킬 shell-script 를 모아 둔 directory  
_(절대! git directory 내에서 실행시키면 안됨. -> 복사시키거나 옮겨 둘 것)_  
  
> `CD.sh`  
> : 항상 git repo 의 최신 application 을 build 하고 run 시키는 스크립트  
> `ZDD.sh`  
> : Nginx 를 활용하여 profile 을 교체시키며 app 을 run 시키는 스크립트  
> `switch.sh`  
> : Nginx 의 port 를 전환하는 스크립트  
> `final_deploy.sh`  
> : 'CD.sh', 'ZDD.sh', 'switch.sh' 를 통합한 배포 자동화 최종 스크립트  
> `run.sh`  
> : 'final_deploy.sh' 를 background process 로 작동  
  

## 3. 패키지 세팅
(예제는 AWS EC2 Linux 2 환경)
- java 1.8.0
- git
- \+ jenkins
- \+ nginx

## 4. Jenkins 설치, 설정 및 실행
### [ Jenkins 설치 ]
1. `> wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo`
2. `> rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key`
3. `> yum install jenkins`

### [ Jenkins 설정 ]
1. `> vi /etc/sysconfig/jenkins` 에서 `JENKINS_PORT=“8080”` 에서 원하는 Port 로 수정
2. 이후 Github 와 연동 **(참조 : https://jojoldu.tistory.com/291)**
3. 이후 jenkins 환경 설정 **(참조 : https://jojoldu.tistory.com/315?category=777282)**
4. '구성' 의 'Build' 에 run.sh 의 절대경로를 넣는다.  
_(저는 `sudo ~/scripts/run.sh` 를 넣었습니다.)_  
  
+) Slack Noti 연동 **(참조 : http://dogbirdfoot.tistory.com/16)**

### [ Jenkins 실행 ]
- `> service jenkins start`  
_(`> service jenkins restart`, `> service jenkins stop` 등도 참조)_

## 5. Nginx 설치, 설정 및 실행
### [ Nginx 설치 ]
1. `> yum install nginx`

### [ Nginx 실행 ]
- `> service nginx start`  
_(따로 설정을 안 할 경우, 서버 구동 시 항상 start 해줘야 한다.)_

### [ Nginx 설정 ]
- `> vi /etc/nginx/nginx.conf` 에서  
  
`server { ... ` 와 `location / {` 사이에  
`include /etc/nginx/conf.d/service-url.inc;` 입력  
  
그리고 바로 아래에 있는 `location / { ... }` 사이에  
  
`proxy_pass $service_url;`  
`proxy_set_header X-Real-IP $remote_addr;`  
`proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;`  
`proxy_set_header Host $http_host;`  
  
를 입력
- `> vim /etc/nginx/conf.d/service-url.inc` 으로 파일 생성  
- `set $service_url http://127.0.0.1:9081;` 입력  
- `> service nginx restart` 한 뒤, http 프록시가 9081 을 향하는지 확인

## 6. 실행 및 배포 방법
1. CD.sh 을 실행하여 build 파일을 먼저 만든다.  
2. ZDD.sh 를 두 번 실행한다.  
_(처음 실행 때는 profile=set1 이 설정되어 배포되고, 두번 째 실행 때는 profile=set2 이 설정되어 배포된다.)_  
3. `> ps -ef | grep web-application` 의 명령어를 통해 set1, set2 가 모두 실행 중인지 확인한다.  
4. 배포 자동화 시작.

## 7. 서버 환경
- Default Port : 9080  
- (profile = set1) 에서의 Port : 9081  
- (profile = set2) 에서의 Port : 9082    
_(http://.../profile 을 통해 현재 profile 확인 가능)_  
- Jenkins Port : 5858  
