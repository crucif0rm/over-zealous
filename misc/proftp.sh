#!/bin/bash
#
# proftpd user management script for non system users.
#
# Requirements:
# AuthOrder mod_auth_file.c # enables the alternate auth config file
# AuthUserFile /etc/ftpasswd # sets the file you want to read from
# DefaultRoot ~ # lock user to their home directory
#
#
# How it works
#
# 1. Request the username, password, home dir
# 2. check the current custom Auth file for an existing entry
# 3. parse the most recently added users 'UID' and create the new one with a new increment of 1.
# 4. convert all the previously input information into 'passwd' format into the ftpasswd file.
# 5. Report if the user creation was successful, with a detailed report and also report if it failed.
if [ ! -f /etc/ftpasswd ];
    then
echo "No ftpasswd file found, creating a default."
        echo "ftptemplate:x:0:0:ftptemplate:/ftptemplte:/bin/bash" > /etc/ftpasswd
fi:

read -p "Enter username: " username
read -p "Enter password: " password
read -p "Enter home (/data/www/www.example.com): " ftpdir
read -p "Enter GID (home dir group)" gid

grep -q ^$username /etc/ftpasswd

if [ $? -eq 0 ]
    then
echo "$username exists!"
        exit 1
    else

uid="$(tail -1 /etc/ftpasswd | cut -d':' -f3 | awk '{printf $0+1}')"
part2="$(echo "$password" | ftpasswd -stdin -passwd -file=/etc/ftpasswd -name=$username -uid=$uid -gid=$gid -home=$ftpdir -shell=/bin/false 2>&1)"

if [ $? -eq 0 ]
    then
final="$(tail -1 /etc/ftpasswd)"
        echo -e "# Account created succesfully #\n\n Username: $username\n Password: $password\n UID/GID: $uid $gid\n home DIR: $ftpdir\n entry: $final"
    else
echo -e "ERROR:\n $part2"
    fi
fi
