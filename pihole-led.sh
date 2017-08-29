#!/bin/bash

trap 'quit' SIGINT SIGQUIT SIGTERM

ACT='/sys/class/leds/led0'
PWR='/sys/class/leds/led1'

quit()
{
  reset_leds
  exit 1
}

init_leds()
{
  echo oneshot > ${ACT}/trigger
  echo oneshot > ${PWR}/trigger
  sleep 0.1
  echo 1 > ${ACT}/invert
  sleep 0.1
  echo 1 > ${ACT}/shot
  echo 1 > ${PWR}/shot
}

reset_leds()
{

  echo mmc0 > ${ACT}/trigger
  echo input > ${PWR}/trigger
}

if [[ "$(systemctl show dnsmasq --property=ActiveState)" != "ActiveState=active" ]]
then
  quit
fi

init_leds

tail -n1 -f /var/log/pihole.log | while read INPUT
do
  case $INPUT in

  *' /etc/pihole/gravity.list '*)
    echo 1 > ${PWR}/shot
    ;;

  *' forwarded '*)
    echo 1 > ${ACT}/shot
    ;;

  *)
    if [[ "$(systemctl show dnsmasq --property=ActiveState)" != "ActiveState=active" ]]
    then
      quit
    fi
    ;;

  esac
done
