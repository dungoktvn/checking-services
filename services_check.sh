#!/bin/bash

#read data from file
filename="list_host.txt"

while read line || [ -n "$line" ]; do
    echo $line
    site_name="$(cut -d';' -f1 <<<"$line")"
    be_host="$(cut -d';' -f2 <<<"$line")"
    teid="$(cut -d';' -f3 <<<"$line")"
    nos="$(cut -d';' -f4 <<<"$line")"

    #clear last checking_resuly.txt
    if [ -f "./results/$site_name.txt" ]; then
    echo "Clear last result file"
    cat /dev/null > ./results/$site_name.txt 
    fi

    #copy remote-box-command to remote host
    scp -i ./athena-devops.pem -o "StrictHostKeyChecking no" remote-box-commands.sh ubuntu@$be_host:/tmp/remote-box-commands.sh
    #excute commands to get information
    echo "chmod +x /tmp/remote-box-commands.sh && /bin/bash /tmp/remote-box-commands.sh -i $teid -n $nos && exit && rm /tmp/remote-box-commands.sh" | ssh -i ./athena-devops.pem -o "StrictHostKeyChecking no" ubuntu@$be_host > result_temp.txt

    #sleep 5
    ##Writing checking result
    echo "******************** $site_name ***********************" >> ./results/$site_name.txt
    echo " " >> ./results/$site_name.txt
    tail -n +32 result_temp.txt >> ./results/$site_name.txt
    echo " " >> ./results/$site_name.txt
done < $filename
