#!/bin/bash

# 숫자 계산 echo `expr $selectedCMD + 3`

declare -ri MAXNUM=20
declare -ri MAXSTAGE=2

declare -i userlen=0
declare -i statuslen=0
declare -i pslen=0

declare -i selectedUser=0
declare -i selectedPs=0
declare -i stage=1
declare -i flag=1

# stage=1 => 현재 NAME 메뉴 선택중
# stage=2 => CMD 메뉴 선택중

key=0
user=(`ps -eo user|sort|uniq`)
unset user[0]
#status=(`ps -eo user,cmd,pid,stime`)
# user[0] = USERS. 쓸데없는 문자임


### Functions ---

PrintScreen() 
{
    # print Screen
    clear
    
    echo "Practice"
    echo "In Linux"
    echo "-NAME-----------------CMD------------------PID---STIME----"
    #ps -i cmd	IFS=$'\n` 를 이용해 명령어 결과를 한줄단위로 배열에 저장

    # USER 저장된거 찾아서 삭제
    temp=(`ps -eo user|sort|uniq`)
    for (( i=0; i<${#user[@]}; i++ ))
    do
        if [ "${user[i]}" = "USER" ]; then
            unset user[i]
            break;
        fi
    done
    # 유저목록에서 USER제거하고 다시 정렬
    IFS=$'\n' user=($(sort <<<"${user[*]}"))
    
    #IFS=$'\n` status=(`ps -o cmd,pid,stime -u ${user[$selectedUser]}`)
    IFS=$'\n' cmd=(`ps -o cmd -u ${user[$selectedUser]}`)
    IFS=$'\n' pid=(`ps -o pid -u ${user[$selectedUser]}`)
    IFS=$'\n' stime=(`ps -o stime -u ${user[$selectedUser]}`)

    userlen=`expr ${#user[@]}`
    pslen=`expr ${#cmd[@]} - 1` # 맨첫줄 뺴고 길이측정

    for (( i=0; i<MAXNUM; i++ ))
    do
        printf "|"
        if [ $i -lt $userlen  ]; then
            if [ $i -eq $selectedUser ]; then
                printf "\x1b[41m" # 색 지정
            fi
            printf "%20.20s" ${user[$i]}
            printf "\x1b[0m" # 색 초기화
        else
            printf "                    "
        fi
        printf "|"
        if [ $i -le $pslen ]; then
            psIndex=`expr $i + 1`
            if [ $psIndex -eq $selectedPs ]; then
                printf "\x1b[42m" # 색 지정
            fi
            printf "%20.20s|%5.5s|%8.8s" ${cmd[$psIndex]} ${pid[$psIndex]} ${stime[$psIndex]}
            printf "\x1b[0m" # 색 초기화
        else
            printf "                    |     |        "
        fi
        printf "|\n"
    done

    
    echo "----------------------------------------------------------"
    echo "If you want to exit, Please Type 'q' or 'Q'"
}

MenuController() {
    if [ $key = q ] || [ $key = Q ]; then
        flag=0
    elif [ $key = "" ]; then
        read -n 1 key
        read -n 1 key
        if [ $stage = 1 ]; then
            if [ $key = A ] && [ $selectedUser -gt 0 ]; then #상
                selectedUser=$selectedUser-1
            elif [ $key = B ] && [ $selectedUser -lt `expr $userlen - 1` ] && [ $selectedPs -lt $MAXNUM ]; then #하
                selectedUser=$selectedUser+1
            elif [ $key = C ]; then #우
                stage=2
                selectedPs=1
                #echo "cmd로 이동"
            else
                Nothing
            fi
        
        elif [ $stage = 2 ]; then
            if [ $key = A ] && [ $selectedPs -gt 1 ]; then #상
                selectedPs=$selectedPs-1
            elif [ $key = B ] && [ $selectedPs -lt $pslen ] && [ $selectedPs -lt $MAXNUM ]; then #하
                selectedPs=$selectedPs+1
            elif [ $key = D ]; then #좌
                stage=1
                selectedPs=0 #0이면 화면 색칠 안함
                #echo "Name으로 이동"
            else
                Nothing
            fi
        fi
    else
        Nothing
    fi    

    # 화면에 보여주기 위한 key 변수 이름 변경
    key="^[[$key"
    echo $key
}

Nothing() {
    n=1
}

RenewScreen() 
{
    while [ $flag = 1 ]
    do
        sleep 3
        PrintScreen
    done
}


### Main Start ###
clear
PrintScreen

while [ $flag = 1 ]
do
    read -n 1 key
    MenuController
    PrintScreen 
        
    # Debug
    #echo "{userlen=$userlen, pslen=$pslen, stage=$stage, flag=$flag}"
    #echo "{selectedUser=($selectedUser, ${user[$selectedUser]}), selectedPs=$selectedPs}"
done


### Main End ###
