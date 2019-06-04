#!/bin/bash

while true;
do
  for port in 1100 1101 1102 1430 5001 9000 12865 55005; do
    ss -ltn | awk '{print $4}' | grep $port > /dev/null
    if [[ "$?" -ne "0" ]]; then
      /etc/init.d/bismark-mserver restart
      echo "Bismark MServer restarted."
      break
    fi
  done
  sleep 5
done
