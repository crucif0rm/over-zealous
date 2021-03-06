#!/bin/bash
#
#Generate server statistics


# Distro
function os() {
        if [ -e /etc/redhat-release ]; then
export flavor=`cat /etc/redhat-release`
        elif [ "$(lsb_release -d | awk '{print $2}')" == "Ubuntu" ]; then
export flavor=`lsb_release`
        else
echo -e "Could not detect distro name/type." && export flavor="Other"
        fi
}

function srvinfo() {
        echo -e "---- ---- ----"
        echo -e "Distro: $flavor"
        echo -e "Processor: `cat /proc/cpuinfo | grep 'model name' | sed -e 's/.*: //' | tail -1` `dmesg | grep -i -F 'processor.' | sed -e 's/.*] //' | tail -1 | awk '{print $2 "Mhz"}'`"
        echo -e "---- ---- ----"
        echo -e "`/sbin/ifconfig | awk '/^eth/ { printf("Interface: %s\t",$1) } /inet addr:/ { gsub(/.*:/,"",$2); if ($2 !~ /^127/) print $2; }'`"
        echo -e "---- ---- ----"
        echo -e "Time: `date +'%H:%M%p on %A, %m/%e/%Y'`"
        echo -e "Uptime: `uptime | awk '{sub(/,/,"",$3)} {sub(/:/," hours, ", $3)} {sub(/$/, " minutes", $3)} {print $3}'`"
        echo -e "`vmstat -a -S m|tail -n1|awk '{printf "Memory: Free\tUsed\tTotal\tPercent Free\nMemory: %sMB\t %sMB\t%sMB\t%s%\n",$4+$5,$6,$4+$5+$6,($4+$5)/($4+$5+$6)*100}'`"
        echo -e "---- ---- ----"
        echo -e "`df -h /`\n`df -hi /`"
        echo -e "---- ---- ----"

}

os
srvinfo
