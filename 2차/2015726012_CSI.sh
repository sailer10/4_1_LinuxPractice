#!/bin/bash

cursor=0
sub_cursor=-1
flag=0
istart=0
what=0
j=0
err=0

input="   "
function logo() {
	echo ""
	echo '______                     _    _             '
	echo '| ___ \                   | |  (_)             '
	echo '| |_/ / _ __   __ _   ___ | |_  _   ___   ___  '
	echo '|  __/ |  __| / _  | / __|| __|| | / __| / _ \ '
	echo '| |    | |   | (_| || (__ | |_ | || (__ |  __/ '
	echo '\_|    |_|    \__,_| \___| \__||_| \___| \___| '
	echo ""
	echo '(_)       | |    (_)                    '
	echo ' _  _ __  | |     _  _ __   _   _ __  __'
	echo '| ||  _ \ | |    | ||  _ \ | | | |\ \/ /'
	echo '| || | | || |____| || | | || |_| | >  < '
	echo '|_||_| |_|\_____/|_||_| |_| \__,_|/_/\_\'
	echo ""
}

function getUsers() {
	#using ps, get Uers, return to arrUsers
	arrUsers=(`ps -ef | cut -f 1 -d " " | sed "1d" | sort | uniq`)
}

function getCmds() {
	#IFS : Internal Field Separator 내부 필드 구분자

	#using ps, get CMDs, return to arrCmds
	ps -ef > temp
	grep ^$1 temp > psfu	#tac: 역으로 출력
	rm ./temp
	IFS_backup="$IFS"
	# backup IFS
	IFS=$'\n'
	arrCmds=(`tac psfu | cut -c 53-`)
	arrPIDs=(`tac psfu | cut -c 11-16`)
	arrSTIMEs=(`tac psfu | awk '{print $5}'`)
	#arrSTIMEs=(`cat psfu | cut -c 25-29`)

	IFS="$IFS_backup"
	# restore IFS
}

getUsers
getCmds ${arrUsers[$cursor]}

numUsers=${#arrUsers[*]}
numCmds=${#arrCmds[*]}


highlight() {
	if [ $2 = $1 ]; then
		echo -n [$3m
	fi
}




until [ "$input" = "q" -o "$input" = "Q" ]; do
clear
if [ $err -ne 0 ]; then
echo "Not Permission" && err=0
sleep 2
fi

clear
	getUsers
	getCmds ${arrUsers[$cursor]}

	numUsers=${#arrUsers[*]}
	numCmds=${#arrCmds[*]}

	# 1 + 20 + 1 + 20 + 1 + 5 + 1 + 8 + 1
	logo
	echo "-NAME-----------------CMD------------------PID---STIME----"
	for (( i=0; i<20; i++)); do
        printf "|"
		highlight $i $cursor 41
		printf "%20s" ${arrUsers[$i]}
		echo -n [0m
        printf "|"
		IFS_backup="$IFS"
		IFS=$'\n'
        highlight $i $sub_cursor 42
		j=`expr $istart + $i`
		printf "%-20.20s|%6s|%8s" ${arrCmds[$j]} ${arrPIDs[$j]} ${arrSTIMEs[$j]}
        echo -n [0m
        printf "|"
		IFS="$IFS_backup"
		printf "\n"
	done
	echo "----------------------------------------------------------"
	echo "[log: flag=$flag, cursor=$cursor, sub_cursor=$sub_cursor, what=$what"
	echo "		numUsers=$numUsers, numCmds=$numCmds. istart=$istart, err=$err"
	echo "If you want to exit , Please Type 'q' or 'Q'"
    printf ""
	read -n 3 -t 3 input
	case "$input" 
	in
		"") if [ $sub_cursor -ge 0 ]; then
				k=`expr $sub_cursor + $istart`
				what=`expr ${arrPIDs[$k]} + 0`
				if [ $what -ne 0 ]; then
					kill -9 $what
					err=$?
				fi
			fi;; #상,하,우,좌
		[A) if [ $flag -eq 0 ] && [ $cursor -gt 0 ]; then
				cursor=`expr $cursor - 1`
				istart=0
			 elif [ $sub_cursor -eq 0 ] && [ $istart -gt 0 ] ; then
				istart=`expr $istart - 1`
			 elif [ $sub_cursor -gt 0 ]; then
			 	sub_cursor=`expr $sub_cursor - 1`
			 fi;;
		[B) if [ $flag -eq 0 ]; then 
				[ $cursor -lt `expr $numUsers - 1` ] && cursor=`expr $cursor + 1` && istart=0
			 elif [ $flag -eq 1 ]; then 
				if [ $sub_cursor -lt 19 ]; then 
                [ $sub_cursor -lt `expr $numCmds - 1` ] && sub_cursor=`expr $sub_cursor + 1`
				elif [ $numCmds -gt `expr $istart + 20` ]; then
					istart=`expr $istart + 1`
				fi
			 fi;;
        [C) [ $flag -eq 0 ] && sub_cursor=0 && flag=1;;
        [D) [ $flag -eq 1 ] && flag=0 && sub_cursor=-1;;
	esac
done
