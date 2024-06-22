#!/bin/bash

# Define variables
GROUPNAME="sftpusers"
HOMEDIR="/home"
USERFILE="users.txt"
PASSWORD_LENGTH=12

# Create group for SFTP users
groupadd $GROUPNAME

# Read usernames and passwords from input file
while read -r USERNAME
do
    PASSWORD=$(openssl rand -base64 12)
    useradd -g $GROUPNAME -d $HOMEDIR/$USERNAME -s /bin/false $USERNAME
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "$USERNAME:$PASSWORD" >> $USERFILE
    mkdir $HOMEDIR/$USERNAME
    chown root:$GROUPNAME $HOMEDIR/$USERNAME
    chmod 770 $HOMEDIR/$USERNAME
done < usernames.txt