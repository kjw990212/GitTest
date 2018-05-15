#!/bin/bash
declare -a arr
declare -a arrp
init_arr(){
unset arr
unset arrp
declare -i j=1
for (( i=0; ;i++ ))
do
arr[$i]="`ls -p | grep -v '/$' | head -$j | tail -1`"
arrp[$i]="`ls -p | grep -v '/$' | head -$j | tail -1 | cut -c 1-29`"
if [ "`ls -p | grep -v '/$' | head -$j | tail -1`" == "`ls -p | grep -v '/$' | tail -1`" ]
then
	break
fi
j=j+1
done
if [ "`ls -p | grep -v '/$' | wc -l`" == 0 ]
then
	unset arr[0]
fi
}
declare -a arr_d
declare -a arr_dp
init_arr_d(){
unset arr_d
unset arr_dp
arr_d[0]='..'
arr_dp[0]='..'
declare -i j=1
for (( i=1; ; i++ ))
do
arr_d[$i]="`ls -d ./*/ | grep '/$' | cut -f 2 -d '/' | head -$j | tail -1`"
arr_dp[$i]="`ls -d ./*/ | grep '/$' | cut -f 2 -d '/' | head -$j | tail -1`"
if [ "`ls -d ./*/ | grep '/$' | cut -f 2 -d '/' | head -$j | tail -1`" == "`ls -d ./*/ | grep '/$' | cut -f 2 -d '/' | tail -1`" ]
then
		break
fi
j=j+1
done
if [ "`ls -p | grep '/$' | wc -l`" == 0 ]
then
	unset arr_d[1]
fi
}
declare -i f
declare -i s
declare -i l=0
declare -i n=0
declare -i num
print_equal(){
for (( i=0; i<$1; i++ ))
	do
		printf '='
	done
}
print_file(){
f=0
s=0
for (( i=0; i<${#arr_d[@]}; i++ ))
	do 
		num=$i
		if [ $l == $i ]
		then
			echo "[0m|[43m[34m${arr_dp[i]}[0m "
		else
			echo "[0m|[34m${arr_dp[i]}[0m"
		fi
		if [ $i == 27 ]
		then
			break
		fi
	done
for (( i=0; i<${#arr[@]}; i++ ))
	do
		if [ `expr $num + $i` -gt 26 ]
		then 
			break
		fi
		if [ -x "${arr[i]}" ]
		then
			if [ $l == `expr $i + ${#arr_d[@]}` ]
			then
				echo "[0m|[43m[32m"${arrp[i]}"[0m "
				s=s+1 
			else
				echo "[0m|[32m${arrp[i]}"
				s=s+1
			fi
		elif [ "`file "${arr[i]}" | cut -f 2 -d ' '`" == "Zip" ]
		then
			if [ $l == `expr $i + ${#arr_d[@]}` ]
			then
				echo "[0m|[43m[31m"${arrp[i]}"[0m "
				s=s+1
			else	
				echo "[0m|[31m${arrp[i]}"
				s=s+1
			fi
		elif [ "`file "${arr[i]}" | cut -f 2 -d ' '`" == "gzip" ]
		then
			if [ $l == `expr $i + ${#arr_d[@]}` ]
			then
				echo "[0m|[43m[31m${arrp[i]}[0m "
				s=s+1
			else
				echo "[0m|[31m${arrp[i]}"
				s=s+1
			fi
		else
			if [ $l == `expr $i + ${#arr_d[@]}` ]
			then
				echo "[0m|[43m${arrp[i]}[0m "
				f=f+1
			else
				echo "[0m|${arrp[i]}"
				f=f+1
			fi
		fi
	done
	if [ ${#arr[@]} -le 28 ]
		then
			for (( i=0; i<`expr 28 - ${#arr[@]} - ${#arr_d[@]}`; i++ ))
				do
					echo "[0m|"
				done
		fi
}
print_pipe() {
	for (( i=2; i<30; i++ ))
	do
		tput cup $i $1 
	echo "|"
	done
	tput cup 38 0
}
read_key() {
read -n 3 key
	if [[ $key = "" ]]
	then
		n=1
	elif [ $key = '[A' ]
	then
		if [ 0 -lt $l ]
		then
			l=l-1
			n=0
		fi
	elif [ $key = '[B' ]
	then
		if [ $l -lt 29 ]
		then
			if [ $l -lt `expr ${#arr[@]} + ${#arr_d[@]} - 1` ]
			then
				l=l+1
				n=0
			fi	
		fi
	fi
}
start_() {
init_arr_d
init_arr
print_equal 47
printf " 2017203012 Jeongwon Kim "
print_equal 48
echo ""
print_equal 57
printf " List "
print_equal 57
echo ""
}
end() {
print_equal 53
printf " information "
print_equal 54
echo ""
if [ 0 -le `expr $l - ${#arr_d[@]}` ] 
then
	echo "|file name : ${arr[$l-${#arr_d[@]}]}"
	if [ -x "${arr[$l-${#arr_d[@]}]}" ]
	then
		echo "|[32mfile type : execute file[0m"
	elif [ "`file "${arr[$l-${#arr_d[@]}]}" | cut -f 2 -d ' '`" == "Zip" ]
	then
		echo "|[31mfile type : compressed file[0m"
	elif [ "`file "${arr[$l-${#arr_d[@]}]}" | cut -f 2 -d ' '`" == "gzip" ]
	then		
		echo "|[31mfile type : compressed file[0m"
	else
		echo "|[0mfile type : regular file"
	fi
	echo "|file size : `wc -c "${arr[$l-${#arr_d[@]}]}" | cut -f 1 -d ' '`"
	echo "|creation time : `stat -c '%x' "${arr[$l-${#arr_d[@]}]}"`"
	echo "|permission : `stat -c '%a' "${arr[$l-${#arr_d[@]}]}"`"
	echo "|absolute path : `readlink -f "${arr[$l-${#arr_d[@]}]}"`"
else
	echo "|file name : "${arr_d[l]}" "
	echo "|[34mfile type : directory[0m"
	echo "|file size : `du -b "${arr_d[l]}" | tail -1 | cut -f 1 -d '	'`"
	echo "|creation time : `stat -c '%x' "${arr_d[l]}"`"
	echo "|permission : `stat -c '%a' "${arr_d[l]}"`"
	echo "|absolute path : `readlink -f "${arr_d[l]}"`"
fi
print_equal 56
printf " Total "
print_equal 57
echo ""
d="`du -b -s | cut -f 1 -d '	'`"
echo "|                    `expr ${#arr[@]} + ${#arr_d[@]} - 1` total   `expr ${#arr_d[@]} - 1` dir   $f file   $s Sfile   $d byte "             
print_equal 57
printf " End "
print_equal 58
print_pipe 30
print_pipe 75
print_pipe 120
}
for (( ; ; ))
do
start_
print_file
end
if [ $n == 1 ]
then
	if [ 0 -le `expr $l - ${#arr_d[@]}` ] 
	then
		declare -i j=1
		for (( i=2; i-1<=`wc -l "${arr[$l-${#arr_d[@]}]}" | cut -f 1 -d ' '`; i++ ))
		do	
			if [ "`file "${arr[$l-${#arr_d[@]}]}" | cut -f 2 -d ' '`" == "Zip" ]
			then
				break
			elif [ "`file "${arr[$l-${#arr_d[@]}]}" | cut -f 2 -d ' '`" == "gzip" ]
			then		
				break
			else
				tput cup $i 31
				printf "$j "
				if [ "`cat "${arr[$l-${#arr_d[@]}]}" | head -$j | tail -1`" == "`cat "${arr[$l-${#arr_d[@]}]}" | head -$j | tail -1 | grep -v "	"`" ]
				then	
				cat "${arr[$l-${#arr_d[@]}]}" | head -$j | tail -1 | cut -c 1-41
				j=j+1
				else
					declare -i k=`cat "${arr[$l-${#arr_d[@]}]}" | head -$j | tail -1 | tr -cd "	" | wc -m`
					declare -i q=k
					k=k*5
					k=40-k-q
					cat "${arr[$l-${#arr_d[@]}]}" | head -$j | tail -1 | cut -c 1-$k
					j=j+1
				fi
				if [ $j == 29 ]
				then
						break
				fi
			fi
			n=0
		done
	else
		cd ${arr_d[l]}
		l=0
		n=0
		start_
		print_file
		end
	fi
	tput cup 38 0
fi

read_key
echo "[0m"
done

