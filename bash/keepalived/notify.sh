#!/usr/bin/env bash

if [[ $1 = "" ]]; then exit 1; else action=$1; fi

case $action in
    on-backup)
        pass=0;;
    on-fault)
        pass=0;;
    on-master)
        pass=0;;
    on-shutdown)
        pass=0;;
    on-startup)
        pass=0;;
    on-stop)
        pass=0;;
    *)
        pass=1;;
esac

if [[ $pass != 0 ]]; then exit 1; fi
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [[ ! -d $SCRIPT_DIR/$action ]]; then exit 1; fi
scripts_d_path=$SCRIPT_DIR/$action

if [[ ! $(ls $scripts_d_path | wc -l) == 0 ]]; then
        echo "ok"
        for i in $scripts_d_path/*; do
                if [[ -f $i ]]; then
                        if [[ -x $i ]]; then
                                logger "[keepalived-script] Running script $i"
                                $i
                        fi
                fi
        done
fi

exit 0
