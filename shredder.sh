#!/bin/bash

# shredder.sh authored by jwal 09/29/2020

touch /root/shredder/shredded.log
for d in $(ls /dev/disk/by-path/pci-0000\:01\:00.0-sas-phy* | grep -v part); do
        OSdrive=$(udevadm info --query=all --name=$(df -h |grep -w /| awk '{ print $1 }' | sed -u 's/.$//g') | grep ID_SERIAL | grep -v SHORT | cut -d '=' -f2)
        serial=$(udevadm info --query=all --name=$d | grep ID_SERIAL | grep -v SHORT | cut -d '=' -f2)
        realpath=$(readlink -f $d | grep -o sd.)
        size=$(fdisk -l $d | awk 'NR==1{print $3$4}')
        grep "$serial" /root/shredder/shredded.log;
        rtrn_code=$?
        if [ $rtrn_code -eq 1 ] && [[ "$serial" != "$OSdrive" ]]
        then
                fdisk -l $d | grep 'unable to read'
                if [ $? -eq 1 ]
                then
                        ps aux | grep -v grep | grep "shred -vzn 0 $d"
                        if [ $? -eq 1 ]
                        then
                                cat /dev/null > /root/shredder/$realpath.log
                                shred -vzn 0 $d &>> /root/shredder/shred.log && \
                                        echo $(date '+%d/%m/%Y %H:%M:%S') $serial >> /root/shredder/shredded.log && \
                                        echo "$serial $size shred completed at $(date '+%d/%m/%Y %H:%M:%S')" > /root/shredder/$realpath.log &
                        fi
                elif [ $? -eq 0 ]
                then
                        echo "$serial is bad, input/output errors reported by fdisk and could not be shredded.  Drive should be destroyed." > /root/shredder/$realpath.log
                fi
        elif [[ "$serial" = "$OSdrive" ]]
        then
                :
        elif [ $rtrn_code -eq 0 ]
        then
                echo "$d $serial $size has already been shredded" >> /root/shredder/$realpath.log
        else
                echo "Error. exit code ($?)"
        fi
done
