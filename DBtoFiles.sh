#DBtoFiles.sh
#MySQL Backup into Cloud Files container
#

LOGIN="" #Rackspace Cloud USERNAME
PASS="" #Rackspace Cloud API key
TOKEN=`curl -s -I -H "X-Auth-Key: $PASS" -H "X-Auth-User: $LOGIN" https://auth.api.rackspacecloud.com/v1.0|grep X-Auth-Token|awk {'print $2'}` #store Auth Key
CONTAINER="Backups" # Container Target for Backups
BASEURL="" # Cloud Files Internal URL
SQL_HOST="" # Database Hostname
SQL_USER="" #Database User Name
SQL_PASS="" #Database User Password
MYSQLDUMP=`which mysqldump` #Locate mysqldump binary
GZIP=`which gzip` #Locate gzip binary
TODAY=DB_`date +%m-%d-%Y`.sql.gz #Timestamp the backup file
LOGF="/var/log/DBbackup.log" #Log File location

## If todays backup exists EXIT. If todays backup is missing, mysqldump it, gzip it, upload it to cloud files.
if [ -f $TODAY ];
then
        exit 0
else
        START1=$(date +%s.%N)
        mysqldump -u$SQL_USER -p$SQL_PASS --all-databases -h $SQL_HOST --max_allowed_packet=500M | $GZIP --fast > $TODAY
        curl -X PUT -T $TODAY -H "X-Auth-Token: $TOKEN" $BASEURL/$CONTAINER/$TODAY
fi

## If todays backup was successful, echo into logfile backup duration time, then remove the file.
if [ -f $TODAY ];
then
        END1=$(date +%s.%N)
        echo $TODAY: Backup took $(echo "$END1 - $START1"|bc) seconds to complete. >> $LOGF
        rm -rf $TODAY
else
        exit 0
fi
