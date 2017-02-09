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
	move="~/"
	write=false
	verbose=false

	while getopts ":t:r:mwvh" opt; do
		case $opt in
		t)
			target=$OPTARG
			;;
		r)
			rlstype=$OPTARG
			;;
		m)
			if [[ -d $OPTARG ]] && [[ ! -z $OPTARG ]];then
				move=$OPTARG
			else
				move=$move
			fi
			;;
		w)
			if $OPT;then
				write=true
			else
				write=false
			fi
			printf "Write mode: $write\n"
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

	echo -e "\n"
	echo -e "\tideal.sh\n"
	echo -e "\tUsage:"
	echo -e "\t$0 -t /path/to/target -v\n"

	echo -e "\t-m" "\t"		"Directory to move broken releases into."
	echo -e "\t-w" "\t" 	"Writable mode, default doesnt touch anything."
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
		for BROKEN in ${failed[@]};do
			if [ -d $BROKEN ];then
				echo -en "$BROKEN" "\n" >> $LOGPATH
				echo -ne "BROKEN: $BROKEN\n"
			else
				echo "Not a directory. Skipped."
			fi
		done

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

		printf "\r[%*s" "${x}" | tr ' ' '#'  #'▇'
		printf "%*s]"
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


runnable(){

	OLDIFS=$IFS
	IFS=$(echo -en "\n\b")

	if [[ -d $1 ]];then

		# gets all the magic going,	scans directories, creates list of sfv 
		# then runs it thru cksfv.

		sint=0 # success increment
		fint=0 # failed increment
		#. skapa_lista $1 $2
		#source scratchpad.sh
		#source test.sh
		make_lists $1 $2
		printf '%s\n' "After: ${#pass_forward[@]}"
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
						printf '%s %s%s\n' "[ SUCCESS ]" "$katalog" "$el"
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
			# DONT NEED THIS NO MORE
			#if [[ $broken == true ]];then
			#	printf '%s %s%s\n' "[ FAILED  ]" "$katalog" "$el"
			#elif [[ $verbose == true ]] && [[ $broken == false ]] && [[ $fil == *.sfv ]];then
			#	printf '%s %s%s\n' "[ SUCCESS ]" "$katalog" "$el"
			#fi
			cols=$(tput cols)
			draw_bar ${work_done} ${#pass_forward[@]} ${cols}
		done
		make_list_of_failed ${nylista[@]}
	else
		helpmsg
	fi
	IFS=${OLDIFS}
}

menu "$@"
runnable "$target" "$rlstype"
