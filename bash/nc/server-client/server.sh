#!/usr/bin/env bash

nc -4dDk -l 546 -I 2048 -M 1 | jq -r

exit 0
