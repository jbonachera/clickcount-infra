#!/bin/bash
consul_hosts=""
count=0
while [ $count -lt 2 ]; do
  consul_hosts=$(getent hosts $DISCOVERY_DOMAIN | awk '{print $1}')
  count=$(echo $consul_hosts | wc -w)
  sleep 0.5
done
for host in $consul_hosts; do
        while ! consul join $host; do
          sleep 0.5
        done

done

