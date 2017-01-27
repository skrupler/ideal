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
OLDIFS=$IFS
IFS=$(echo -en "\n\b")
FCOLOR="\033[31;1m"
PCOLOR="\033[32;1m"
CEND="\033[0m"

function draw_bar() {

	# hardcoding
	#bw=237
	if [ $1 -eq -1 ];then
		printf "\r %*s\r" "${3}"
	else
        i=$(($1*${3}/$2))
        j=$((${3}-i))
    	printf "\r[%*s" "$i" | tr ' ' '#'
	    printf "%*s]\r" "$j"
	fi

}

function listfiles() {
	if find $1 -type f -name "*.sfv";then
		continue
	else
		printf "No SFV found."
	fi
}

function skapa_lista() {

	# makes an array of directories
	dirlist=$(find $1 -maxdepth 1 -type d -print0 | xargs -0 -n 1|sort -u)
	gfint=0
	for item in $dirlist;do
		nylista[gfint]=$item
		gfint=$((gfint+1))
	done
}

if [[ -d $1 ]];then

	# gets all the magic going,	scans directories, creates list of sfv 
	# then runs it thru cksfv.

	sint=0 # success increment
	fint=0 # failed increment
	skapa_lista $1

	for katalog in "${nylista[@]}";do
	plist=0
		for fil in $(listfiles $katalog);do  
			if [[ $fil == *.sfv ]];then # dubbelkontroll SO WHAT?
				#draw_bar $plist ${#nylista[@]} $cols
				if cksfv -g $fil -q;then

					# array of successful items
					success[sint]=$katalog
					sint=$((sint+1))
					plist=$((plist+1))
					printf "$PCOLOR Success. SFV Passed. $CEND\n"
				else
					# array of failed items
					failed[fint]=$katalog
					printf "$FCOLOR Failed. Added to blacklist.$CEND\n"
					fint=$((fint+1))			
					plist=$((plist+1))
				fi
			fi
		cols=$(tput cols)
		draw_bar $plist ${#nylista[@]} $cols
			
		done
	done
else 
	echo "Wont do shit without params."
fi

# reset ifs ffs
IFS=$OLDIFS
