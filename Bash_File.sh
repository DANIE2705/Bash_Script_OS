#!/bin/bash

#OS task to be automated: Backup and Recovery Manager

#Brief Explanation: Our group plans to develop a bash script that will automate the process of creating compressed backups of selected 
#directories, checking backup integrity, creating logs of backups, and restoring files when needed.
#The script will also compare current files with previous backups t
o identify added, modified, or deleted files and support automated 
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

# Make sure that path for automated cron backups is realtive to where this script is stored.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Create paths for a backup directory and log file!
BACKUP_DIR="$SCRIPT_DIR/backups"
LOG_FILE="$BACKUP_DIR/backup.log"

if [[ "$option" = "-i" ]]; then      
	backupFile=$2				

	if [[ ! -f "$backupFile" ]]; then  
		echo "Error second arguement is not a file"
		echo "Please use the following syntax:"
		echo "./Bash_File.sh -i fileName.tar"
		exit 1
	elif [[ ! -r "$backupFile" ]]; then  
		echo "Error, unable to read given file."
		echo "Incorrect permissions with file."
		echo "Please use chmod to edit file permissions."
		exit 2
	elif [[ ! -s "$backupFile" ]]; then 
		echo "Error backup file is empty."
		echo "Exiting..."
		exit 3
	fi
elif [[ "$option" = "-c" || "$option" = "-r" || "$option" = "-u" || "$option" = "-s" ]]; then 
	directory=$2            

	if [[ -z "$directory" ]]; then 
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
else  
	echo "Error. Incorrect option provided. Please use one of five available options."
	echo "Exiting..."
	exit 7
fi


if [[ "$option" = "-c" || "$option" = "-s" ]]; then
	if [[ ! -d "$BACKUP_DIR" ]]; then
		if ! mkdir -p "$BACKUP_DIR"; then 
			echo "Error, unable to create backup directory"
			echo "Exiting..."
			exit 8
		fi
	fi
fi


case "$option" in 
	-c)
		timestamp=$(date +"%Y-%m-%d_%H%M%S")  
		directoryName=$(basename "$directory")   
		backupFile="${BACKUP_DIR}/${directoryName}_${timestamp}.tar.gz"
		echo "Compressing and archiving $directory ..."
		if tar --exclude="$BACKUP_DIR" -czvf "$backupFile" "$directory"; then
			echo "Backup created."
			echo "[$(date +"%Y-%m-%d %H:%M:%S")] SUCCESS: $backupFile archived successfully." >> "$LOG_FILE"
		else
			echo "[$(date +"%Y-%m-%d %H:%M:%S")] FAILED: Backup creation failed." >> "$LOG_FILE"
			echo "An error occurred while creating a backup."
			echo "Backup failed."
			rm -f "$backupFile"
		fi
		;;
	-i)
		echo "Checking archive integrity..."

		if [[ "$backupFile" == *.tar ]] ; then

			if tar -tf "$backupFile" > /dev/null 2>&1 ; then
				echo "Archive integrity check passed."
			else
				echo "Archive integrity check failed."
			fi

		elif [[ "$backupFile" == *.tar.gz ]] ; then

			if tar -tzf "$backupFile" > /dev/null 2>&1 ; then
				echo "Archive integrity check passed."
			else
				echo "Archive integrity check failed."
			fi

		elif [[ "$backupFile" == *.zip ]] ; then

			if unzip -t "$backupFile" > /dev/null 2>&1 ; then
				echo "Archive integrity check passed."
			else
				echo "Archive integrity check failed."
			fi

		else
			echo "Unsupported archive format."
			exit 9
		fi
		;;
	-r)
		directoryName=$(basename "$directory")

		backups=($(ls -1 "${BACKUP_DIR}/${directoryName}"_*.tar.gz | sort -r))

		if [[ ! -e "${backups[0]}" ]] ; then
			echo "No backups found for $directoryName"
			exit 10
		fi

		echo ""
		echo "Available backups:"
		echo ""

		for i in "${!backups[@]}"
		do
			echo "$((i+1))) $(basename "${backups[$i]}")"
		done

		echo ""
		read -p "Choose a backup version: " choice

		selectedBackup="${backups[$((choice-1))]}"

		if [[ -z "$selectedBackup" ]] ; then
			echo "Invalid backup selection."
			exit 11
		fi

		echo ""
		echo "Restoring $(basename "$selectedBackup")"

		mkdir -p restored_files
		if tar -xzf "$selectedBackup" -C restored_files; then
			echo "Restore complete."
		else
			echo "Restore failed."
			exit 12
		fi
		;;
	-u)
		directoryName=$(basename "$directory")

		backups=($(ls -1 "${BACKUP_DIR}/${directoryName}"_*.tar.gz | sort -r))

		if [[ ! -e "${backups[0]}" ]] ; then
			echo "No backups found for $directoryName"
			exit 13
		fi

		echo ""
		echo "Available backups:"
		echo ""

		for i in "${!backups[@]}"
		do
			echo "$((i+1))) $(basename "${backups[$i]}")"
		done

		echo ""

		read -p "Choose a backup version: " choice

		if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
			echo "Invalid selection."
			exit 14
		fi

		selectedBackup="${backups[$((choice-1))]}"
		
		if [[ -z "$selectedBackup" ]] ; then
			echo "Invalid backup selection."
			exit 15
		fi

		mkdir -p temp_compare

		echo ""
		echo "Comparing current directory against backup..."
		echo ""

		if ! tar -xzf "$selectedBackup" -C temp_compare; then
			echo "Unable to extract backup."
			rm -rf temp_compare
			exit 16
		fi

		comparison=$(diff -rq "$directory" "temp_compare/$directoryName")

		echo "===== Added Files ====="
		echo "$comparison" | grep "^Only in $directory" || echo "None"

		echo ""
		echo "===== Deleted Files ====="
		echo "$comparison" | grep "^Only in temp_compare" || echo "None"

		echo ""
		echo "===== Modified Files ====="
		echo "$comparison" | grep "^Files" || echo "None"

		rm -rf temp_compare
		;;
	-s) 
		echo "-----------------------------------------------------------"
		echo ""
		echo "                   BACKUP SCHEDULING                       "
		echo ""
		echo "-----------------------------------------------------------"
		echo ""
		echo "Please select the frequency at which you would like backups to be performed:"
		echo "" 
		echo "1. Hourly"
		echo "2. Daily"
		echo "3. Weekly"
		echo ""
		read -p "Enter your choice: " frequency

		case "$frequency" in 
		1)
			schedule="0 * * * *" 
			;;
		2)
			schedule="0 0 * * *" 
			;;
		3)
			schedule="0 0 * * 0" 
			;;
		*)
			echo "Invalid choice. Please enter 1, 2, or 3 next time"
			echo "Exiting"
			exit 17
			;;
		esac
		
		SCRIPT_PATH="$(realpath "$0")" 
		DIRECTORY_PATH="$(realpath "$directory")" 
		
		cronCommand="\"$SCRIPT_PATH\" -c \"$DIRECTORY_PATH\"" 
		existingJobs=$(crontab -l 2>/dev/null) 
		newJobs="$schedule $cronCommand" 
		
		
		if echo "$existingJobs" | grep -Fq "$cronCommand"; then
			echo "There is already a scheduled backup for this directory"
			echo "Exiting..."
			exit 18
		fi
		
		
		if {
			echo "$existingJobs" 
			echo "$newJobs"
		} | crontab -; then        
			echo "Backup successfully scheduled!"
		else
			echo "Error. Unable to schedule backup."
			echo "Exiting..."
			exit 19
		fi
		
		echo ""
		echo "Selected schedule: $schedule"
		echo "Script path: $SCRIPT_PATH"
		echo "Directory path: $DIRECTORY_PATH"
		echo "Cron command: $cronCommand"
		;;
	*)
		echo "Error. Incorrect option provided. Please use one of five available options."
		echo "Exiting..."
		exit 20
		;;
esac
