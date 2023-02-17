#!/usr/bin/env bash

hostname=$(hostname -f)
lscpu=$(lscpu -J)
lsblk=$(lsblk -J)
lshw=$(lshw -json)
lsipc=$(lsipc -J)
lsmem=$(lsmem -J)
lslocks=$(lslocks -J)
lsns=$(lsns -J)

i=0
message="{\"hostname\":\"$hostname\",\"data\": [$lscpu,$lsblk,$lshw,$lsipc,$lsmem,$lslocks,$lsns]}"

while [ $i -le 0 ]; do
        echo $message | jq -rc
        sleep 10
done

exit 0
