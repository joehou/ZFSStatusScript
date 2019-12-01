#!/bin/bash

sendEmail="false";

while [ -n "$1" ]; do
    case "$1" in
        -e) sendEmail="true";;
        *) echo "option not recognized"
    esac
    shift
done

mapfile -t poolDisks < <(zpool iostat -v | grep sd |awk '{print $1}')
poolResult="Passed"
for disk in "${poolDisks[@]}"
do
    diskResult=$(smartctl -H /dev/sda1 -f brief | tail -n 2  |head -n 1 | awk '{print $NF}';)
    message+=$disk
    message+=": "
    message+=$diskResult
    message+=" "

    if [ $diskResult != "PASSED" ]; then
        poolResult="Failed"
    fi
done

echo $message
echo $poolResult
if [ "$sendEmail" = "true" ]
then
    if [ "$poolResult" = "Passed" ]
    then
        echo $poolResult| mail -s "Zpool Status: Passed" tyranthou@gmail.com -r tyranthou@gmail.com
    else
        echo $poolResult| mail -s "Zpool Status: Failed" tyranthou@gmail.com -r tyranthou@gmail.com
    fi
fi
