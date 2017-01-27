#!/bin/bash

#	NAME:		ideal.sh
#	AUTHOR: 	SKRUPLER
#	LiCENSE:	GPLV2
#	DATE:		2017-01-26

#	ABOUT
# 	ideal.sh scans $1 param for directories with sfv files, adds to array. then scans 
# 	those with cksfv.
# 	finally it creates a list of those who do not have sfv and moves em.

# hax circumvent dirs with space in it
#OLDIFS=$IFS
#IFS=$(echo -en "\n\b")
FCOLOR="\033[31;1m"
PCOLOR="\033[32;1m"
BCOLOR="\033[34;1m"
CEND="\033[0m"

function help(){
	
	# just a simple help screen
	if [ -z $1 ];then
		echo -e "$FCOLOR" "ERROR: You need at least one argument" "$CEND"
	fi
	echo -e "ideal.sh - sfv checker wrapper script in bash"
	echo -e "Usage:"
	echo -e "\t$0 /path/to/target --move /tmp --verbose"
	echo -e "\t--move,\t\t -m" "\t"	"Directory to move broken releases into."
	echo -e "\t--write,\t -w" "\t" 	"Writable mode, default doesnt touch anything."
	echo -e "\t--verbose,\t -v" "\t" "Toggles verbose output."
}
function check_if_trail(){

	if [ -z $1 ];then
		#make trailing
		echo ""
	else
		continue
	fi
}


function make_list_of_failed(){

	# writes all failed to failed.log
	SCRIPT=$(realpath -s $0)
  	SCRIPTPATH=$(dirname $SCRIPT)
	LOGPATH="$SCRIPTPATH/failed.log"
	#echo "Making a failed list."

	if ! [ -z $1 ];then
		if ! [ -d $SCRIPTPATH ] && [ -e $LOGPATH ];then
			touch $SCRIPTPATH/failed.log
		elif [ -d $SCRIPTPATH ] && [ -s $LOGPATH ];then 
			rm $LOGPATH
			touch $LOGPATH
		fi
		for BROKEN in ${failed[@]};do
			if [ -d $BROKEN ];then
				echo -en "$BROKEN" "\n" >> $LOGPATH
			else
				echo "Not a directory. Skipped."
			fi
		done
	fi
}


function move_to_blah(){
	
	# takes $1
	if [ -d $1 ];then
		echo ""
	else
		printf "This is a bogus directory. Failed."
		exit 1
	fi
}

function draw_bar() {

	# $1 work_done
	# $2 work_total
	# $3 window_columns
	IFS=$OLDIFS

	x=$(($3-2))

	if [ $1 -eq $2 ];then
		printf "\r[%*s" "${x}" | tr ' ' '▇'
		printf "%*s]"
		printf "${SCOLOR}Operation completed ${1} scans.${CEND}\n"
		printf "${FCOLOR}${fint} broken releases.${CEND}\n"
		printf "${SCOLOR}${sint} intact releases.${CEND}\n"
	else
		
		# to account for the []	chars
		#percent=$(echo {1} ${2}| awk '{ print $1 / $2 }')

        i=$((${1}*${x}/${2})) # work_done * window_columns / work_total
        j=$((${x}-i)) # window_column - (work_done*window_columns / work_total)
    	printf "\r[%*s" "${i}" | tr ' ' '▇'
	    printf "%*s]\r" "${j}"
	fi
	IFS=$(echo -en "\n\b")
}

function listfiles() {
	if find $1 -maxdepth 1 -type f -name "*.sfv";then
		continue
	else
		printf "No SFV found."
	fi
}

function skapa_lista() {

	OLDIFS=$IFS
	IFS=$(echo -en "\n\b")

	# makes an array of directories
	dirlist=$(find $1 -mindepth 1 -maxdepth 1 -type d |sort -u)
	gfint=0
	for item in $dirlist;do
		nylista[gfint]=${item}
		gfint=$((gfint+1))
	done
	IFS=${OLDIFS}
}

if [[ -d $1 ]];then

	# gets all the magic going,	scans directories, creates list of sfv 
	# then runs it thru cksfv.

	sint=0 # success increment
	fint=0 # failed increment
	skapa_lista $1
	work_done=0

	for katalog in "${nylista[@]}";do
		for fil in $(listfiles $katalog);do  
			if [[ $fil == *.sfv ]];then # dubbelkontroll SO WHAT?
				if cksfv -g $fil -q &> /dev/null;then
					# array of successful items
					success[sint]=$katalog
					sint=$((sint+1))
					work_done=$((work_done+1))
					printf "$BCOLOR Success. SFV Passed. $CEND"
				else
					# array of failed items
					failed[fint]=$katalog
					fint=$((fint+1))			
					work_done=$((work_done+1))
					printf "$FCOLOR Failed. Added to blacklist.$CEND"
				fi
			fi
			cols=$(tput cols)
			draw_bar ${work_done} ${#nylista[@]} ${cols}
		done
	done
	make_list_of_failed ${failed[@]}
else 
	help
fi

# reset ifs ffs
IFS=$OLDIFS
