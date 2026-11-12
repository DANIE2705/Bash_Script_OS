#!/bin/bash

#OS task to be automated: Backup and Recovery Manager

#Brief Explanation: My group plans to develop a bash script that will automate the process of creating compressed backups of selected 
#directories, checking backup integrity, creating logs of backups, and restoring files when needed.
#The script will also compare current files with previous backups to identify added, modified, or deleted files and support automated 
#backup scheduling. Users that use this script are also able to specific which backup version they want to recover to. 
#This tool will help improve system reliability and data protection and simplifying backup management and recovery to reduce
#the manual workload of an admin.

#Planned options:
# 1) Create Compressed Backup of Directory
# 2) Check Backup integrity
# 3) Restore to prior backup 
# 4) Compare current directory with a backup of directory
# 5) Schedule Automated Backups

#Expected User CommandLine for option 1
# Using -c indicates that the user wants to create a compressed backup of the directory. Omitting the name or path of the directory they wish to compress, assumes they want to compress the current working directory
# ./Bash_File.sh -c 
# Or specify specific directory
# ./Bash_File.sh -c directoryName
 
#Expected User CommandLine for option 2
# Using -i indicates the user wishes to check the integrity of a given backup file.
# ./Bash_File.sh -i backupFile.tar

#Expected User CommandLine for option 3
# Using -r indicates a user wishes to restore to a prior backup of a certain directory
# ./Bash_File.sh -r directoryName
# Will prompt later which backup version of the directory they want to restore to

#Expected User CommandLine for option 4
# Using -u indicates a user wants to compare a directory with its backup
# ./Bash_File.sh -u directoryName
# Will prompt the user which backup version of the directory they want to compare the directory to

#Expected User CommandLine for option 5
# Using -s indicates a user wishes to schedule automated backups of a provided Directory
# ./Bash_File.sh -s directoryName

option=$1    # set user's first arguement to option variable

if [[ "$option" = "-i" ]]; then      # if option vairable is -i we are doing integrity check 
	backupFile=$2				# set backupFile variable to user's second argument

	if [[ ! -f "$backupFile" ]]; then  # check if the provided backup file is a file
		echo "Error second arguement is not a file"
		echo "Please use the following syntax:"
		echo "./Bash_File.sh -i fileName.tar"
		exit 1
	elif [[ ! -r "$backupFile" ]]; then  # check if the provided backup file is readable
		echo "Error, unable to read given file."
		echo "Incorrect permissions with file."
		echo "Please use chmod to edit file permissions."
		exit 2
	elif [[ ! -s "$backupFile" ]]; then  # check if backup file is empty
		echo "Error backup file is empty."
		echo "Exiting..."
		exit 3
	fi

elif [[ "$option" = "-c" | "$option" = "-r" | "$option" = "-u" | "$option" = "-s" ]]; then # if option variable is any of the other options
	directory=$2              # set directory variable to user's second argument

	if [[ -z "$directory" ]]; then # if no directory provided use current working directory
		directory="."
	fi

	if [[ ! -d "$directory" ]]; then
		echo "Error, provided directory doesn't exist."
		echo "Exiting."
		exit 4
	elif [[ ! -r "$directory" ]]; then
		echo "Error, directory unreadable."
		echo "Incorrect directory permissions. Please use chmod to update directories permissions."
		exit 5
	elif [[ ! -x "$directory" ]]; then
		echo "Error, directory cannot be accessed."
		echo "Incorrect directory permissions. Please use chmod to update directories permissions."
		exit 6
	fi


else; then                        # if given input does not match any of the available ones then exit
	echo "Error. Incorrect option provided. Please use one of five available options."
	echo "Exiting..."
	exit 4

fi

case "$option" in 
	-c)

		;;
	-i)

		;;
	-r)

		;;
	-u)

		;;
	-s)

		;;
	*)

		;;
esac