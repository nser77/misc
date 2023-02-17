#!/usr/bin/env bash

# single socket
# enable on lan (-M 1)
nc -4Dk -l 546 -I 2048 -M 1 | jq -r

exit 0
