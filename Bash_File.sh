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
	#
elif [[ "$option" == "-i" ]] ; then
	if (( -e "$backupFile" )) ; then
			#the archive has normal and possibly not normal
			# output then send it to the 
			#kali linux black hole where everything get's deleted,
			#(which is the /dev/null path in the system)
			#but if 2 (the error output) is present with 1 (regular
			#output) then the archive integrity is violated because 
			#there is an error output.
			if [[ "$backupFile" == *.tar ]] ; then
				if tar -tf "$backupfile" > /dev/null 2>&1 ; then
					echo "Archive integrity check passed."
				else
					echo "Archive integrity check failed."
				fi
				exit 0
			elif [[ "$backupFile" == *.gz ]] ; then
				if tar -tzf "$backupfile" > /dev/null 2>&1 ; then
					echo "Archive integrity check passed."
				else
					echo "Archive integrity check failed."
				fi
				exit 0
			elif [[ "$backupFile" == *.zip ]] ; then
				if unzip -t "$backupfile" > /dev/null 2>&1 ; then
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
	#if ( -e -d "") ; then
	#	backupfileUnzip =$(unzip -t "$backupFile")
	#	if "$opiton" = $backupfileUnzip; then
	#		echo "The current directory is the same as the back up...\n"
	#	else
	#		echo "Error occurred ... Exiting.."
	#		exit 3
	#	fi
	#else
	#	echo "Option specified is not a directory or does not... Exiting.."
	#	exit 4
	#fi
elif [[ "$option" == "-u" ]] ; then

elif [[ "$option" == "-s" ]] ; then

else
	echo "Error. Incorrect option provided. Please use one of five available options."
	echo "Exiting..."
	exit 1
fi

exit 0

#References

#For option -i (Checking the integrity of the backup file)
#-https://linuxvox.com/blog/what-does-dev-null-mean-at-the-end-of-shell-commands/
#-https://www.geeksforgeeks.org/linux-unix/tar-command-linux-examples/
#-https://stackoverflow.com/questions/10508843/what-is-dev-null-21 