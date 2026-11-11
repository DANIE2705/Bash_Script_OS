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

#Expected User CommandLine for option 3
# Using -r indicates a user wishes to restore to a prior backup of a certain directory

#Expected User CommandLine for option 4
# Using -

#Expected User CommandLine for option 5
# Using -s 