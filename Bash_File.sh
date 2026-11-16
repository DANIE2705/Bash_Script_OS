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

# Make sure that path for automated cron backups is realtive to where this script is stored.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Create paths for a backup directory and log file!
BACKUP_DIR="$SCRIPT_DIR/backups"
LOG_FILE="$BACKUP_DIR/backup.log"

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
elif [[ "$option" = "-c" || "$option" = "-r" || "$option" = "-u" || "$option" = "-s" ]]; then # if option variable is any of the other options
	directory=$2              # set directory variable to user's second argument

	if [[ -z "$directory" ]]; then # if no directory provided use current working directory
		directory="."
	fi
	if [[ ! -d "$directory" ]]; then  # if provided path doesn't exist as a directory then exit
		echo "Error, provided directory doesn't exist."
		echo "Exiting."
		exit 4
	elif [[ ! -r "$directory" ]]; then   # if the directory doesn't have proper read permissions exit
		echo "Error, directory unreadable."
		echo "Incorrect directory permissions. Please use chmod to update directories permissions."
		exit 5
	elif [[ ! -x "$directory" ]]; then # if the directory doesn't have proper execute permissions that allow us to traverse then exit
		echo "Error, directory cannot be accessed."
		echo "Incorrect directory permissions. Please use chmod to update directories permissions."
		exit 6
	fi
else                      # if given input does not match any of the available ones then exit
	echo "Error. Incorrect option provided. Please use one of five available options."
	echo "Exiting..."
	exit 7
fi

# check if the backup directory exists. if it doesn't create it
if [[ "$option" = "-c" || "$option" = "-s" ]]; then
	if [[ ! -d "$BACKUP_DIR" ]]; then
		if ! mkdir -p "$BACKUP_DIR"; then # if mkdir does not run successfully, error at created the directory
			echo "Error, unable to create backup directory"
			echo "Exiting..."
			exit 8
		fi
	fi
fi


case "$option" in 
	-c) # create a compressed backup of directory
		timestamp=$(date +"%Y-%m-%d_%H%M%S")   #create a timestamp variable that we will use to date backup files
		directoryName=$(basename "$directory")     # get the basename of the directory the user provided
		backupFile="${BACKUP_DIR}/${directoryName}_${timestamp}.tar.gz"
		echo "Compressing and archiving $directory ..."
		if tar --exclude="./backups" -czvf "$backupFile" "$directory"; then
			echo "Backup created."
			echo "[$(date +"%Y-%m-%d %H:%M:%S")] SUCCESS: $backupFile archived successfully." >> "$LOG_FILE"
		else
			echo "An error occured while creating a backup."
			echo "Backup failed."
			rm -f "$backupFile"
		fi
		;;
	-i)
		
		;;
	-r)
		## remember to add write permissions check once the user gives destination to put restoration
		;;
	-u)
		
		;;
	-s) # allow user to schedule cron job to schedule backups!
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

		case "$frequency" in # based on which frequency the user chose create a schedule variable with cron execution string variables
		1)
			schedule="0 * * * *" # every hour
			;;
		2)
			schedule="0 0 * * *" # every day at midnight
			;;
		3)
			schedule="0 0 * * 0" # every sundary at midnight
			;;
		*)
			echo "Invalid choice. Please enter 1, 2, or 3 next time"
			echo "Exiting"
			exit 9
			;;
		esac
		
		SCRIPT_PATH="$(realpath "$0")" # get the absolute path of the script
		DIRECTORY_PATH="$(realpath "$directory")" # get the absolute path of the directory
		
		cronCommand="\"$SCRIPT_PATH\" -c \"$DIRECTORY_PATH\"" # create the cron command that we will ask cron to do on a schedule
		existingJobs=$(crontab -l 2>/dev/null) # get the existing cron jobs
		newJobs="$schedule $cronCommand" # create the new scheduled backup job
		
		# check whether the backup is already scheduled
		if echo "$existingJobs" | grep -Fq "$cronCommand"; then
			echo "There is already a scheduled backup for this directory"
			echo "Exiting..."
			exit 10
		fi
		
		# combine that new job with the preexisting jobs
		if {
			echo "$existingJobs" 
			echo "$newJobs"
		} | crontab -; then         # if no errors given while adding new job to existing jobs
			echo "Backup successfully scheduled!"
		else
			echo "Error. Unable to schedule backup."
			echo "Exiting..."
			exit 11
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
		exit 10
		;;
esac
