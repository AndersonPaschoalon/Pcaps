#!/bin/bash

function init_gitignore
{
	echo "Creating .gitignore file for files larger than 49M"
	rm .gitignore
	find * -size +49M | cat >> .gitignore
}

function split_files_gitignore
{
	read_file=${1};
	echo "reading file: " ${read_file}
	cat ${read_file}| while read line
	do
	   echo "splitting file >> " $line;
	   filedirname=${line} # file
	   filedir=$(sed "s/\/[^\/]*$/\//g" <<< ${line} | sed "s/\ /\\\ /g"); # directory
	   filename=$(sed "s;${filedir};;g" <<< ${line}); 
	   split -b 49M "$filedirname"  ./"${filedir}""part:""$filename"".";
	done
}

function merge_files_gitignore
{
	read_file=${1};
	echo "reading file: " ${read_file}
	cat ${read_file}| while read line
	do
	   echo "merging file >> " $line;
	   filedirname=${line} # file
	   filedir=$(sed "s/\/[^\/]*$/\//g" <<< ${line} | sed "s/\ /\\\ /g"); # directory
	   filename=$(sed "s;${filedir};;g" <<< ${line});
	   cat ./"${filedir}""part:""$filename""."* > "$filedirname"
	done
}

function rm_files_gitignore
{
	read_file=${1};
	echo "reading file: " ${read_file}
	cat ${read_file}| while read line
	do
	   filedirname=${line} # file
	   filedir=$(sed "s/\/[^\/]*$/\//g" <<< ${line} | sed "s/\ /\\\ /g"); # directory
	   filename=$(sed "s;${filedir};;g" <<< ${line});
	   echo "rm ./""${filedir}""part:""$filename"".*"
	   rm ./"${filedir}""part:""$filename""."* 
	done
}

function checkout_files_gitignore
{
	read_file=${1};
	echo "reading file: " ${read_file}
	cat ${read_file}| while read line
	do
	   filedirname=${line} # file
	   filedir=$(sed "s/\/[^\/]*$/\//g" <<< ${line} | sed "s/\ /\\\ /g"); # directory
	   filename=$(sed "s;${filedir};;g" <<< ${line});
	   echo "git checkout ./""${filedir}""part:""$filename"".*"
	   git checkout ./"${filedir}""part:""$filename""."* 
	done
}

function print_version
{
	echo "version 0.1"
}

function help_menu
{
	echo "help menu"
}

function main
{
	option=${1}
	if [[ "$option" == "--init" ]]; then
		init_gitignore;
	elif [[ "$option" == "--split" ]]; then
		# split_files_gitignore test_file;
		split_files_gitignore .gitignore
	elif [[ "$option" == "--merge" ]]; then
		# merge_files_gitignore test_file;
		merge_files_gitignore .gitignore; 
	elif [[ "$option" == "--setup" ]]; then
		init_gitignore;
		split_files_gitignore .gitignore;
	elif [[ "$option" == "--rm" ]]; then
		rm_files_gitignore .gitignore;
	elif [[ "$option" == "--checkout" ]]; then
		checkout_files_gitignore .gitignore;
	elif [[ "$option" == "--version" ]]; then
		print_version;
	else
		help_menu;
	fi
}

if [[ "$1" != "--source" ]]
	then
	main ${1}
	# main "--init";
	# main "--split";
	# main "--merge";
	# read_line test_file;
fi


