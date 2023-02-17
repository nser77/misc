#!/usr/bin/env bash

if [ "$1" == "1" ]; then skip_first=1; else skip_first=0; fi
if [ ! -d ./logs ]; then mkdir ./logs; fi

tolerance=3
sleep=1
log=./logs/reboot.log
old_pwd=$(cat /root/.old_pwd)
new_pwd=$(cat /root/.new_pwd)

while read -r line; do
        if [ $skip_first -eq 0 ]; then
                skip_first=$(($skip_first + 1))
                continue
        fi

        ip=$(echo $line | cut -d"," -f1)
        unset line
        
        if ! ping -c$tolerance $ip &> /dev/null; then
                echo "$extension,$(date),Warning,Host $ip offline" >> $log
                continue
        fi

        sshpass -p $new_pwd ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$tolerance admin@$ip <<< exit &> /dev/null

        case $? in
                0)
                        echo "$extension,$(date),Success,Host $ip has been rebooted in the past" >> $log
                        ;;
                5)
                        sshpass -p $old_pwd ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$tolerance admin@$ip <<< reboot &> /dev/null

                        case $? in
                                0)
                                        echo "$extension,$(date),Success,Host $ip has been rebooted with the old password" >> $log
                                        ;;
                                5)
                                        echo "$extension,$(date),Critical,Host $ip has an unknown password." >> $log
                                        ;;
                                *)
                                        echo "$extension,$(date),Critical,Host $ip SSHPASS critial error" >> $log
                                        ;;
                        esac
                        ;;
                *)
                        echo "$extension,$(date),Critical,SSHPASS critial error" >> $log
                        ;;
        esac

        skip_first=$(($skip_first + 1))

        sleep $sleep

done < list

exit 0
