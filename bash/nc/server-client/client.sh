#!/usr/bin/env bash

# using single socket
./client-core.sh | nc -4v 192.168.1.251 546

exit 0
