#!/bin/bash

#	NAME:		ideal.sh
#	AUTHOR: 	SKRUPLER
#	LiCENSE:	GPLV2
#	DATE:		2017-01-26

# pretty colors
FC='\033[31;1m'
PC='\033[32;1m'
BC='\033[34;1m'
CEND='\033[0m'

source lib/helper.sh

menu(){

	target=""
	__move=""
	__write=false
	verbose=false

	while getopts ":t:r:m:wivh" opt; do
		case $opt in
		t)
			target="$OPTARG"
			;;
		r)
			rlstype="$OPTARG"
			;;
		m)
			__move="$OPTARG"
			;;
		w)
			if $OPT;then
				__write=true
				printf '%s\n' "Write mode: $__write"
			else
				__write=false
			fi
			;;
		i)
			if ! [[ $OPT ]];then
				__interactive=true
			elif [[ $OPT ]];then
				__interactive=false
			fi
			;;
		h)
			helpmsg
			exit 1
			;;
		v)
			verbose=true
			printf "Verbose mode: $verbose\n"
			;;
		\?)
			printf "Invalid option. -$OPTARG\n" >&2
			exit 1
			;;
		:)
			printf "Option -$OPTARG requires an argument.\n" >&2
			exit 1
			;;
		*)
			helpmsg
			exit 1
			;;
		esac
	done
}

helpmsg(){

	# just a simple help screen
	# not valid anymore anyways

	echo -e "\tideal.sh\n"
	echo -e "\tUsage:"
	echo -e "\t$0 -t /path/to/target -v\n"

	echo -e "\t-m" "\t"		"Directory to move broken releases into."
	echo -e "\t-w" "\t" 	"Writable mode, default doesnt touch anything."
	echo -e "\t-i" "\t"		"When flag is passed interactive mode will be disabled."
	echo -e "\t-v" "\t"		"Toggles verbose output aka also printing successful."
	echo -e "\t-r" "\t"		"Specify type of release. ie: mp3 or movie."
	echo -e "\t-h" "\t"		"Prints this message.\n"

}

make_list_of_failed(){

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
		
		printf '%s\n' "--------------------------------[ CORRUPT ]--------------------------------"
		for BROKEN in ${failed[@]};do
			if [ -d $BROKEN ];then
				echo -en "$BROKEN" "\n" >> $LOGPATH
				echo -ne "BROKEN: $BROKEN\n"
			else
				echo "Not a directory. Skipped."
			fi
		done

		printf '%s\n' "-------------------------------[ INCOMPLETE ]------------------------------"
		for INCOMPLETE in ${incomplete[@]};do
			if [ -d $INCOMPLETE ];then
				echo -en "$INCOMPLETE" "\n" >> $LOGPATH
				echo -ne "INCOMPLETE: $INCOMPLETE\n"
			else
				echo "Not a directory. Skipped."
			fi
		done

	fi
}

draw_bar() {

	# $1 work_done
	# $2 work_total
	# $3 window_columns

	x=$(($3-2))

	if [ $1 -eq $2 ];then

		total_rls=$((${4}+${2}))

		printf "\r[%*s" "${x}" | tr ' ' '#'  #'▇'
		printf "%*s]"
		printf "${SCOLOR}${total_rls} releases in directory $target.${CEND}\n"
		printf "${SCOLOR}${4} where incomplete and excluded from scan.${CEND}\n"
		printf "${SCOLOR}Operation completed ${1} scans.${CEND}\n"
		printf "${FCOLOR}${fint} broken releases.${CEND}\n"
		printf "${SCOLOR}${sint} intact releases.${CEND}\n"
	else
		i=$((${1}*${x}/${2})) # work_done * window_columns / work_total
        j=$((${x}-i)) # window_column - (work_done*window_columns / work_total)
    	printf "\r[%*s" "${i}" | tr ' ' '#'  # '▇'
	    printf "%*s]\r" "${j}"
	fi
}

listfiles() {
	if find $1 -maxdepth 1 -type f -name "*.sfv";then
		continue
	else
		printf "No SFV found."
	fi
}


create_temp_dir(){

	# takes $1 param as output directory
	# creates two sub dirs within that.

	printf '%s\n' "$1"

	if [[ ! -d "$1" ]];then
		mkdir -p "$1"
	fi

	if [[ ! -z "$1" ]] && [[ -d $1 ]];then
		output="$1"
	else
		printf '%s\n' "Something wrong with output directory. Quitting."
		exit 1
	fi

	if [[ ! -z $2 ]];then
		new="$output/$2"
	else
		printf '%s\n' "Seems to be missing an argument. Quitting."
		exit 1
	fi


	if [[ ! -d "$new" ]];then
		printf '%s\n' "$new does not exist, creating it."
		mkdir -p "$new"
	fi
	

}

move_broken(){

	OLDIFS=$IFS
	IFS=$(echo -en "\n\b")


	#mv_opt="-r"

	#if [[ "$3" == true ]];then
	#	mv_opt="-ri"
	#elif [[ "$3" == false ]];then
	#	mv_opt="-r"
	#fi

	# for all the corrupt releases
	if [[ ${#failed[@]} == 0 ]];then
		printf '%s\n' "broken rls: ${#failed[@]}"
	else
		for crpt in "${failed[@]}"; do	
			if [[ -d  "${crpt}" ]];then
				printf '%s\n' "Moved $crpt to $__move/broken/"
				mv "$crpt" "$__move/broken/"
			else
				printf '%s\n' "Failed to remove: $crpt"
				printf '%s\n' "Did the folder move?"
			fi
		done
	fi

	# for all the incomplete releases
	if [[ ${#incomplete[@]} == 0 ]];then
		printf '%s\n' "incomplete rls: ${#incomplete[@]}"	
	else
		for inco in "${incomplete[@]}"; do	
			if [[ -d  "${inco}" ]];then
				printf '%s%s\n' "Moved $inco to $__move/incomplete"
				mv "$inco" "$__move/incomplete/"
			else
				printf '%s\n' "Failed to remove: $inco"
				printf '%s\n' "Did the folder move?"
			fi
		done
	fi


	IFS=${OLDIFS}
}

runnable(){

	OLDIFS=$IFS
	IFS=$(echo -en "\n\b")

	if [[ -d $1 ]];then

		# gets all the magic going,	scans directories, creates list of sfv 
		# then runs it thru cksfv.

		sint=0 # success increment
		fint=0 # failed increment
		make_lists $1 $2
		work_done=0
		broken=false
		el=$(tput el) # this fixes the fucking return carriage
		for katalog in "${pass_forward[@]}";do
			for fil in $(listfiles $katalog);do 
				if [[ $fil == *.sfv ]];then # dubbelkontroll SO WHAT?
					broken=false
					if cksfv -g $fil -q &> /dev/null;then
						# array of successful items
						success[sint]=$katalog
						sint=$((sint+1))
						work_done=$((work_done+1))
						if [[ $verbose == true ]];then
							printf '%s %s%s\n' "[ SUCCESS ]" "$katalog" "$el"
						fi
					else
						# array of failed items
						failed[fint]=$katalog
						fint=$((fint+1))
						work_done=$((work_done+1))
						broken=true
						printf '%s %s%s\n' "[ FAILED  ]" "$katalog" "$el"
					fi
				fi
			done
			cols=$(tput cols)
			draw_bar ${work_done} ${#pass_forward[@]} ${cols} ${#failed[@]}
		done
		make_list_of_failed ${pass_forward[@]} ${failed[@]}
	else
		helpmsg
	fi
	IFS=${OLDIFS}
}

menu "$@"
runnable "$target" "$rlstype"
if [[ ! -z "$__move" ]] && [[ "$__write" == true ]];then
	printf '%s\n' "BEFORE $__move"

	if [[ ! ${#broken[@]} == 0 ]];then
		create_temp_dir "$__move" "broken"
	fi

	if [[ ! ${#incomplete[@]} == 0 ]];then
		create_temp_dir "$__move" "incomplete"
	fi

	move_broken "${failed[@]}" "${incomplete[@]}" "$__move"
else
	printf '%s\n' "Requirements not met."
fi
