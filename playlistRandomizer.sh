#!/usr/bin/bash

ORIGNAME=$1
# Get track info from existing playlist
exec `cat $1 > tmp; tail -n +4 tmp > temp.txt; head -n 3 tmp > new.pls; awk -F "=" '{print $2}' temp.txt > temp.pls;`


# create random numbering for playlist
RANGE=`cat temp.pls | wc -l`
let RANGE/=2
echo $RANGE
COUNTER=0
while [ $COUNTER -lt $RANGE ]; do
	let "ARR[$COUNTER]=${COUNTER} + 1"
	let COUNTER+=1
done 
echo ${ARR[@]}

LETTERS=`uname -a | base64 | md5sum | sed 's/[^a-zA-Z0-9]//g' | sed 's/[^0-9]//g'`
echo ${#LETTERS}
echo $LETTERS
INDEX=0
STRINDEX=${#LETTERS}-1
while [ $INDEX -lt $RANGE ]; do
	
	let "KEY[$INDEX] = ${LETTERS:$STRINDEX:1} % ${#LETTERS}"
	let INDEX+=1
	
	if [[ $STRINDEX = 0 ]]; then
		let STRINDEX=${#LETTERS}
	fi
	let STRINDEX-=1
done
echo ${KEY[@]}

INDEX=0
j=0
while [ $INDEX -lt $RANGE ]; do
	let VAR=($j+${ARR[$INDEX]}+${KEY[$INDEX]})%$RANGE
	let j=$VAR
	
	let "TMP = ${ARR[$INDEX]}"
	let "ARR[$INDEX] = ${ARR[$j]}"
	let "ARR[$j] = $TMP"
	
	echo $j
	let INDEX+=1
done  

INDEX=0
while [ $INDEX -lt $RANGE ]; do
	echo "File${ARR[INDEX]}=" >> newlist.txt
	echo "Title${ARR[INDEX]}=" >> newlist.txt
	let INDEX+=1
done

exec `paste -d "" newlist.txt temp.pls > new.list`
exec `cat new.list >> new.pls`
rm newlist.txt
rm temp.pls
rm tmp
rm new.list
rm temp.txt
exec `mv new.pls $ORIGNAME` 
exit
