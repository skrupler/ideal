#!/bin/bash

die() {
	printf >&2 '%s: %s\n' "$0" "$*"
	false; exit
}

shopt -s extglob
make_lists() {

	OLDIFS=$IFS
	IFS=$(echo -en "\n\b")

	evaluable_shopt_state=$(shopt -p nullglob extglob nocaseglob)
	if [[ $evaluable_shopt_state != *shopt*shopt*shopt* ]]; then
		die "your version of bash is not recent enough"
	fi

	directory_list=$(find "$1" -mindepth 1 -maxdepth 1 -type d)
	s_count=0
	f_count=0

	for directory in $directory_list;do

			if [[ $2 == mp3 ]];then

				__m3u=false
				__nfo=false
				__sfv=false
				__mp3=false

				shopt -s nullglob extglob nocaseglob
				files_found=("${directory}"/''*.@(sfv|nfo|m3u|mp3)'')

				eval "$evaluable_shopt_state"
				unset evaluable_shopt_state

				for xy in ${files_found[@]};do
					#printf '%s\n' "$xy"

					if ${xy##*.} = m3u;then
						if __m3u == true;then
							printf "Already got a m3u file."
							return
						else
							__m3u=true
						fi
					fi

					if ${xy##*.} = nfo;then
						if __nfo == true;then
							printf "Already got a nfo file."
						else
							__nfo=true
						fi
					fi

					if ${xy##*.} = nfo;then	

						if __sfv == true;then



					fi



				done
				sleep 15

				if [[ ${#files_found[@]} < 4 ]];then
					incomplete[$f_count]=${directory}
					f_count=$((f_count+1))
					printf '%s%s\t\n' "ERR: ${#files_found[@]} $directory"			
					sleep 2

				else
					pass_forward[s_count]=${directory}
					s_count=$((s_count+1))
					printf '%s\t\n' "PASS: ${#files_found[@]} $directory"
				fi

			elif [[ $2 == mov ]];then

				shopt -s nullglob extglob nocaseglob
				files_found=("$directory"/*.''@(sfv|nfo|rar)'')

				eval "$evaluable_shopt_state"
				unset evaluable_shopt_state	

				if [[ ${#files_found[@]} -lt 3 ]];then
					incomplete[$f_count]=${directory}
					f_count=$((f_count+1))
					printf '%s\n' "ERR: $directory"
				else
					pass_forward[s_count]=${directory}
					s_count=$((s_count+1))
					printf '%s\n' "PASS: $directory"
				fi
			fi
	done
	IFS=${OLDIFS}
}
shopt -u extglob
