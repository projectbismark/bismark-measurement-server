#!/bin/bash

while true;
do
  if [ $(netstat -lntp | tail -n+3 | wc -l) != 8 ]; then
	  /etc/init.d/bismark-mserver restart
	  echo "Bismark MServer restarted."
  fi
  sleep 5
done
