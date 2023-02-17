#!/usr/bin/env bash

if [[ $1 = "" ]]; then exit 1; else db=$1; fi
if [[ $2 = "" ]]; then exit 1; else filter=$2; fi
if [[ $3 = "" ]]; then exit 1; else mkt=$3; fi
if [[ $4 = "" ]]; then exit 1; else list=$4; fi
if [[ $5 = "" ]]; then exit 1; else tmp_dir=$5; fi

rdir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ -d $tmp_dir ]]; then
        rm -f $tmp_dir/.curl.cfg
        rm -f $tmp_dir/filtered-$list

        timeout='7d'
        usr=geoip
        if [[ -f $rdir/.geoip ]]; then pwd=$(cat $rdir/.geoip); else pwd="admin"; fi
        content="content-type: application/json"

        echo "-u $usr:$pwd" > $tmp_dir/.curl.cfg

        sanity_check=$(curl -s -k -K $tmp_dir/.curl.cfg https://$mkt/rest/system/resource -H $content)
        if [[ $sanity_check == "" ]]; then exit 1; else sanity_response=$(jq -r '.error' <<< $sanity_check); fi
        if [[ $sanity_response == "401" ]]; then exit 1; fi
        unset sanity_check
        unset sanity_response

        grep $filter $db > $tmp_dir/filtered-$list

        while read -r line; do
                ip=$(echo $line | cut -d',' -f1 | sed "s/\/32//g")
                unset line

                get_obj=$(curl -s -k -K $tmp_dir/.curl.cfg https://$mkt/rest/ip/firewall/address-list?address=$ip -H $content)
                id=$(jq -r '.[0].".id"' <<< $get_obj)
                unset get_obj

                case $id in
                        ""|"null")
                                action=PUT
                                payload="{\"list\":\"$list\",\"address\":\"$ip\",\"timeout\":\"$timeout\"}"
                                request=$(curl -s -k -K $tmp_dir/.curl.cfg -X $action https://$mkt/rest/ip/firewall/address-list --data $payload -H $content)
                                logger "[geoip-script] $request"
                                ;;

                        *)
                                action=PATCH
                                payload="{\"timeout\":\"$timeout\",\"disabled\":\"false\"}"
                                request=$(curl -s -k -K $tmp_dir/.curl.cfg -X $action https://$mkt/rest/ip/firewall/address-list/$id --data $payload -H $content)
                                logger "[geoip-script] $request"
                                ;;
                esac
        done < $tmp_dir/filtered-$list

        rm -f $tmp_dir/.curl.cfg
        rm -f $tmp_dir/filtered-$list

        exit 0
else
        exit 1
fi
