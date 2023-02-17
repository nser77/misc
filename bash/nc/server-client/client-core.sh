#!/usr/bin/env bash

lscpu=$(lscpu -J)
lsblk=$(lsblk -J)
lshw=$(lshw -json)
lsipc=$(lsipc -J)
lsmem=$(lsmem -J)
lslocks=$(lslocks -J)
lsns=$(lsns -J)

i=0
message="{\"hostname\":\"\",\"data\": [$lscpu,$lsblk,$lshw,$lsipc,$lsmem,$lslocks,$lsns]}"

while [ $i -le 0 ]; do
        echo $message | jq -rc
        #((i++))
        sleep 10
done

exit 0
