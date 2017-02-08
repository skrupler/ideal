#!/bin/bash

shopt -s extglob
make_lists() {

	RESTORE_IFS=$IFS
	IFS=$(echo -en "\n\b")

	#set_shopt_state=$(shopt -s nullglob extglob nocaseglob)

	directory_list=$(find "$1" -mindepth 1 -maxdepth 1 -type d| sort -u)
	s_count=0
	f_count=0

	for directory in $directory_list;do

			local __m3u=false
			local __nfo=false
			local __sfv=false
			local __mp3=false
			local __rar=false
			
			if [[ $2 == mp3 ]];then

				shopt -s nullglob extglob nocaseglob
				files_found=("${directory}"/''*.@(sfv|nfo|m3u|mp3)'')
				shopt -u nullglob extglob nocaseglob

				for xy in "${files_found[@]}";do

					# m3u
					if [ "${xy##*.}" = "m3u" ];then
						if [[ $__m3u == true ]];then
							printf '%s\n' "Already got a M3U file."
							break
						else
							#printf '%s\n' "M3U = TRUE"
							__m3u=true
						fi
					fi

					# nfo
					if [ ${xy##*.} = "nfo" ];then
						if [[ $__nfo == true ]];then
							printf '%s\n' "Already got a NFO file."
							break
						else
							__nfo=true
							#printf '%s\n' "NFO = TRUE"
						fi
					fi

					# sfv
					if [ "${xy##*.}" = "sfv" ];then
						if [[ $__sfv == true ]];then
							printf '%s\n' "Already got a SFV file."
							break
						else
							#printf '%s\n' "SFV = TRUE"
							__sfv=true
						fi
					fi

					# mp3
					if [ "${xy##*.}" = "mp3" ];then
						if [[ $__mp3 == true ]];then
							printf '%s\n' "Already got a mp3 file."
							break
						else
							__mp3=true
							#printf '%s\n' "MP3 = TRUE"
						fi
					fi
				done
				if [[ $__m3u == true ]] && [[ $__sfv == true ]] && [[ $__nfo == true ]] && [[ $__mp3 == true ]];then
					pass_forward[s_count]=${directory}
					s_count=$((s_count+1))
					printf '%s\t\n' "PASS: $directory"
				else		
				# reached end of list in dir, set invalid
					incomplete[$f_count]=${directory}
					f_count=$((f_count+1))
					printf '%s\t\n' "ERR: $directory"
				fi
	
			elif [[ $2 == mov ]];then

				shopt -s nullglob extglob nocaseglob
				files_found=("$directory"/*.''@(sfv|nfo|rar)'')
				shopt -u nullglob extglob nocaseglob

				#for a in $directory_list;do
				#	printf '%s\n' "$a"
				#done


				for xy in "${files_found[@]}";do

					# nfo
					if [ "${xy##*.}" = "nfo" ];then
						if  [[ $__nfo == true ]];then
							#printf '%s\n' "Already got a NFO file."
							continue
						else
							__nfo=true
						fi
					fi

					# rar
					if [ "${xy##*.}" = "rar" ];then
						if [[ $__rar == true ]];then
							#printf '%s\n' "Already got a RAR file."
							continue
						else
							__rar=true
						fi
					fi

					# sfv
					if [ "${xy##*.}" = "sfv" ];then
						if [[ $__sfv == true ]];then
							#printf '%s\n' "Already got a SFV file."
							continue
						else
							__sfv=true
						fi
					fi
				done
				if [[ $__nfo == true ]] && [[ $__rar == true ]] && [[ $__sfv == true ]];then
					pass_forward[s_count]=${directory}
					s_count=$((s_count+1))
					printf '%s\t\n' "OK: $directory"
				else
					incomplete[$f_count]=${directory}
					f_count=$((f_count+1))
					printf '%s\t\n' "ERR: $directory"
				fi	
			fi
	done
	IFS=${RESTORE_IFS}
}
shopt -u extglob
