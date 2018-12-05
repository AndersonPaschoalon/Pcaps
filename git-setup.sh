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
	echo "  -- What this script does --"
	echo ""
	echo "    This is a script file made to deal with large binary files on github. With "
	echo "this simple script, you will be able to push many files with sizes larger than "
	echo "100MB, and pull them back and use, without worrying of how how many larger files"
	echo "you currently have. Git have a really annoying... \"feature\". If you commit a "
	echo "larger than 100MB file, it will just say that you did, after it tries to pull it"
	echo "and fail... and for a larger file, it takes a lot of time... If you have a lot"
	echo "of files, it takes a LOT more, to just pull nothing. So you have all your"
	echo "morning wasted(more)."
	echo ""
	echo ""
	echo "  -- How to use it --"
	echo ""
	echo "  - Basic Usage -"
	echo ""
	echo "    Usually, you will need to use just two commands:"
	echo "./git-setup.sh --setup : this will create a gitignore file for files larger"
	echo "    49MB (Github advises for files smaller than 50MB), and will break all"
	echo "    these files on smaller than 49MB ones."
	echo "./git-setup.sh --merge: this command will combine all pieces, and recreate"
	echo "    the original files."
	echo ""
	echo "    For example, you just clonned this repository. Use --merge on the root, to"
	echo "recreate the original files:"
	echo "$ ./git-setup.sh --merge"
	echo "    After that, you runned some experiments, and some more larger files were "
	echo "generated. Use --setup to prepare the .gitignore, and break the larger files into"
	echo "pieces:"
	echo "$ ./git-setup.sh --setup"
	echo "    Now, you may procedure with the git commands on the root:"
	echo "git add ."
	echo "git commit -m \"some comment\""
	echo "git push"
	echo ""
	echo "  - Other commands-"
	echo ""
	echo "    You may want to clean up you local repository form the part-files. Use:"
	echo "$ ./git-setup.sh --rm"
	echo "    To restore the part files before commit, just use again: "
	echo "$ ./git-setup.sh --setup"
	echo "    To retrieve back from the repository the original part files (if you used"
	echo "the --merge first, for example) just use --checkout to rollback from the last"
	echo "commit:"
	echo "$ ./git-setup.sh --checkout"
	echo "    If, for any reason you just want to generate the gitignore file, use:"
	echo "$ ./git-setup.sh --init"
	echo "    Also, if you just want to break the files listed on .gitignore into pieces, "
	echo "but does not want to recreate it, use:"
	echo "$ ./git-setup.sh --split"
	echo "    In fact, --setup just execut an --init and than a --split."
	echo "    To display this help menu, use:"
	echo "$ ./git-setup.sh --help"
	echo "    Finally, to show the script version:"
	echo "$ ./git-setup.sh --version"
	echo ""
	echo ""
	echo "  -- Options --"
	echo ""
	echo "--init     : create the .gitignore file for files larger than 49MB."
	echo "--split    : break files on .gitignore files on pieces smaller than 49MB."
	echo "--merge    : combine all part-files (created by --split or --setup) on the "
	echo "             original ones."
	echo "--setup    : create the .gitignore file for files larger than 49MB, and than"
	echo "             break all."
	echo "             into part files smaller than 49MB."
	echo "--rm       : remove all part-files."
	echo "--checkout : retrieve from repository all part files."
	echo "--version  : display the script version."
	echo "--help     : show this help menu."
	echo ""
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


