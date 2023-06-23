#!/bin/bash
set -x
date
resultfile=/home/ansible/result-server-ping.csv
inputcsvfile=/home/ansible/devops/20May.txt
echo "Result is being updated in file '$resultfile' . Please wait...."
echo "Updated on $(date -Iseconds)" > $resultfile
echo "Server ip,  Server Name, cpu,  Total Memory, used Memory, Free Memory, Os Version,  inactive_users,  active_users, disk1,  disk2,  disk3,  disk4, Server state,   Server status" >> $resultfile 
echo $date >> $resultfile 
while IFS=, read -r ip  
do
 case $ip in
  "#"*|"")
  ;;
  *)
    ping -c2 $i "$ip" > /dev/null && hostname=$(ssh -o StrictHostKeyChecking=no ansible@"$ip" "hostname && lscpu | grep -v "NUMA" | grep -v "On-line" | grep CPU\(s\) | awk '{print \$2}' && awk '/^Mem/ {print \$2}' <(free -h) && awk '/^Mem/ {print \$3}' <(free -h) && awk '/^Mem/ {print \$4}' <(free -h) && uname -v | awk '{print $1}' && lastlog -u 1000-5000 --before 30 | awk '{print $1}' | cut -f 1 -d ' '| grep -v its | grep -v ashoka | grep -v ansible " < /dev/null) 
 

   if [ $? -eq 0 ] && [ "${hostname}" != xyz ]; then 

      
      disk1=$(ssh -o StrictHostKeyChecking=no ansible@"$ip" timeout 10s   "df -h | grep  /dev/dm-0 | grep -v "/boot" " < /dev/null)
      disk2=$(ssh -o StrictHostKeyChecking=no ansible@"$ip" timeout 10s "df -h | grep /dev/sda1 | grep -v "/boot" " < /dev/null)
      disk3=$(ssh -o StrictHostKeyChecking=no ansible@"$ip" timeout 10s "df -h | grep /dev/sdb1 | grep -v "/boot" " < /dev/null)
      disk4=$(ssh -o StrictHostKeyChecking=no ansible@"$ip" timeout 10s "df -h | grep /dev/mapper | grep -v "/boot" " < /dev/null)


jenkinsslave=$(ssh ansible@"$ip" 'bash -s' < test.sh)


     active_users=$(ssh -o StrictHostKeyChecking=no ansible@"$ip"   "lastlog -u 1000-5000 -t 30 | awk '{print $1}' | cut -f 1 -d ' '| grep -v its | grep -v ashoka | grep -v ansible | grep -v Username " < /dev/null)


      HOSTNAME=$(echo $hostname | awk '{print $1}')
      CPU=$(echo $hostname | awk '{print $2}')
      TotalMemory=$(echo $hostname | awk '{print $3}')
      UsedMemory=$(echo $hostname | awk '{print $4}')
      FreeMemory=$(echo $hostname | awk '{print $5}')
      Os_Version=$(echo $hostname | awk '{print $6}')
      inactive_users=$(echo $hostname | awk  '{ for (i = 15; i <= 500; ++i)  printf $i " "; print ""}' ) 
     

      echo "$ip,  "${HOSTNAME}", "${CPU}", "${TotalMemory}", "${UsedMemory}", "${FreeMemory}", "${Os_Version}", "${inactive_users}", "${active_users}", "${disk1}", "${disk2}", "${disk3}", "${disk4}",   "${jenkinsslave}",   OK" >> $resultfile 
      echo "$ip,  "${HOSTNAME}", "${CPU}",  "${TotalMemory}", "${UsedMemory}", "${FreeMemory}", "${Os_Version}", "${inactive_users}","${active_users}",   "${disk1}", "${disk2}", "${disk3}", "${disk4}",  "${jenkinsslave}",   OK"
    else
      echo "$ip,$servername,SERVERDOWN" >> $resultfile 
      echo "$ip,$servername,SERVERDOWN" 
    fi
    ;;
  esac
done < $inputcsvfile 
echo "Result is updated in file '$resultfile'"
