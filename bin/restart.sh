#!/bin/bash
function restart_dispatcher {
  echo 'Stop dispatcher ...'
  bundle exec /etc/init.d/vulcain-dispatcher restart
}

function kill_vulcains {
  echo 'Kill(SIGINT) Vulcains Processes ...'
  kill -2 $(ps aux | pgrep -f 'vulcain/bin/run.rb')
}

function reload_vulcains {
  echo 'Reloading Vulcains ...'
  kill -s USR2 $(ps aux | pgrep -f 'dispatcher')
}

if [ "$1" = "--hard" ]; then
  echo 'WARNING. This script will kill all vulcains processes. Be sure no one is running.'
  read -p 'Continue?(y/n)' choice

  if [ $choice = "y" ]; then
    kill_vulcains
    restart_dispatcher
  else
    exit
  fi
elif [ "$1" = "--soft" ]; then
  reload_vulcains
  restart_dispatcher
elif [ "$1" = "--help" ]; then
  echo ''
  echo 'Without args : reload vulcains'
  echo ''
  echo '--hard : /!\ Kill all vulcains and restart dispatcher'
  echo '--soft : Reload vulcains and restart dispatcher'
else
  reload_vulcains
fi





