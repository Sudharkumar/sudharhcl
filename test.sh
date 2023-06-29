#!/bin/bash
#username=ansible
#passwd=ansible
for i in `cat serverlist`;
do
        ping -c2 $i 2> /dev/null
        if [ "$?" != "0" ]
        then
		
                echo "$i" >> Nonping
        else
                echo "$i" >> Pinging
        fi
done
