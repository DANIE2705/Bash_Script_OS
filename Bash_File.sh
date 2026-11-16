!#/bin/bash

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

option=$1
backupFile=$2


if [[ "$option" == "-c" ]] ; then
	#Kate's Section 

elif [[ "$option" == "-i" ]] ; then
	if [[ -e "$backupFile" ]] ; then
			if [[ "$backupFile" == *.tar ]] ; then
				if tar -tf "$backupFile" > /dev/null 2>&1 ; then
					echo "Archive integrity check passed."
				else
					echo "Archive integrity check failed."
				fi
				exit 0
			elif [[ "$backupFile" == *.tar.gz ]] ; then
				if tar -tzf "$backupFile" > /dev/null 2>&1 ; then
					echo "Archive integrity check passed."
				else
					echo "Archive integrity check failed."
				fi
				exit 0
			elif [[ "$backupFile" == *.zip ]] ; then
				if unzip -t "$backupFile" > /dev/null 2>&1 ; then
					echo "Archive integrity check passed."
				else
					echo "Archive integrity check failed."
				fi
				exit 0
			else
				echo "Error. An archive was not provided..."
				echo "Exiting..."
				exit 2
			fi
	else
		echo "This archive does not exsist..."
		echo "Exiting..."
		exit 3
	fi
elif [[ "$option" == "-r" ]] ; then
	if [[ -e "$backupFile" ]] ; then
		backups=(backups/${backupFile}_backup*)

		if [[ ! -e "${backups[0]}" ]] ; then
			echo "No backups found for $backupFile"
			exit 4
		else
			echo "Available backups:"

			for i in "${!backups[@]}"
			do
				echo "$((i+1))) ${backups[$i]}"
			done

			read -p "Choose a backup version: " choice

			selectedBackup="${backups[$((choice-1))]}"
			if [[ -z "$selectedBackup" ]] ; then
				echo "Invalid backup selection."
				exit 7
			else
			echo "Restoring $selectedBackup..."
			
			echo "Restoring $selectedBackup..."

			if [[ "$selectedBackup" == *.tar.gz ]] ; then
				tar -xzf "$selectedBackup"
			elif [[ "$selectedBackup" == *.tar ]] ; then
				tar -xf "$selectedBackup"
			elif [[ "$selectedBackup" == *.zip ]] ; then
				unzip "$selectedBackup"
			else
				echo "Restore not complete...Terminating..."
				exit 8
			fi

			echo "Restore complete."
			exit 0
			fi
		fi
	else 
		echo "This archive does not exsist..."
		echo "Exiting..."
		exit 5
	fi
elif [[ "$option" == "-u" ]] ; then
	if [[ -e "$backupFile" ]] ; then
		backups=(backups/${backupFile}_backup*)
	 
		if [[ ! -e "${backups[0]}" ]] ; then
			echo "No backups found."
			exit 5
		else
			
			echo "Available backups:"
			
			for i in "${!backups[@]}" ; do
				echo "$((i+1))) ${backups[$i]}"
			done
				 
			read -p "Choose backup version: " choice
			selectedBackup="${backups[$((choice-1))]}"
			if [[ -z "$selectedBackup" ]] ; then
				echo "Invalid backup selection."
				exit 7
			fi
				 
			mkdir -p temp_compare
			if [[ "$selectedBackup" == *.tar.gz ]] ; then
				tar -xzf "$selectedBackup" -C temp_compare
			elif [[ "$selectedBackup" == *.tar ]] ; then
				tar -xf "$selectedBackup" -C temp_compare
			fi
				
			diff -rq "$backupFile" "temp_compare/$backupFile"
			# Verify archive extraction structure (I should see how Kate did hers)
			rm -rf temp_compare
			exit 0
		fi
	else
		echo "This archive does not exsist..."
		echo "Exiting..."
		exit 6
	fi
elif [[ "$option" == "-s" ]] ; then
	if [[ -e "$backupFile" ]] ; then
		
	else
		echo "This archive does not exsist..."
		echo "Exiting..."
		exit 9
	fi
else
	echo "Error. Incorrect option provided. Please use one of five available options."
	echo "Exiting..."
	exit 1
fi
exit 0
